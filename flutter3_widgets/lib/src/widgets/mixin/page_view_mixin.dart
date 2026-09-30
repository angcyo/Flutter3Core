part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/08
///
/// [PageView]
/// 直接调用[buildPageView]
///
/// https://api.flutter.dev/flutter/widgets/PageView-class.html
///
/// [PageViewMixin]
/// [TabLayoutMixin]
///
mixin PageViewMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  /// [PageController]
  late final PageController _pageViewControllerMixin = PageController();

  /// [PageView]的滚动物理
  ScrollPhysics? pageViewScrollPhysicsMixin;

  /// 无动画切换页面
  bool get isPageViewNoAnimate =>
      pageViewScrollPhysicsMixin is NeverScrollableScrollPhysics;

  /// [PageView]页面控制器, 用来切换页面
  PageController? get pageViewController => _pageViewControllerMixin;

  /// 当前页面索引
  int? get currentPageIndex => _pageViewControllerMixin.hasClients == true
      ? _pageViewControllerMixin.page?.round()
      : null;

  /// 用来配合[TabBar]实现指示器的滚动效果
  TabController? get tabController {
    if (this is TabLayoutMixin) {
      //自动挂载
      return (this as TabLayoutMixin).tabLayoutController;
    }
    return null;
  }

  /// page切换之后的更新信号
  /// - [onSelfPageViewChanged] 中调用
  final pageChangedUpdateSignal = UpdateSignalNotifier<int?>(null);

  /// 每个页面对应的焦点域, 用来切换界面后恢复, 恢复对应页面的焦点
  final List<FocusScopeNode> pageFocusScopeNodeList = [];

  @override
  void initState() {
    super.initState();
    postFrame(() {
      requestPageFocusMixin(context, currentPageIndex);
    });
  }

  @override
  void dispose() {
    _pageViewControllerMixin.dispose();
    if (pageViewController != _pageViewControllerMixin) {
      pageViewController?.dispose();
    }
    pageChangedUpdateSignal.dispose();
    // 记得释放 FocusScopeNode，避免内存泄漏
    for (final node in pageFocusScopeNodeList) {
      node.dispose();
    }
    super.dispose();
  }

  //region --PageView--

  /// 构建子页面
  /// [buildPageView]->[buildPageChildren]
  @callPoint
  @overridePoint
  WidgetList buildPageChildren(BuildContext context) => [];

  /// 构建[PageView], 当切换界面后[children]并不会重新获取, 所以需要手动处理界面数据
  ///
  /// [disableScroll] 是否禁用[PageView]的滚动
  /// [padEnds] 每个页面都填满页面, 否则可以使用[PageController.viewportFraction]实现非全屏页面
  ///
  /// [keepAlive] 是否自动保活
  /// - [KeepAliveWrapper]
  /// - [KeepAliveWrapperExtension.keepAlive]
  /// [useLifecycle] 是否为child提供生命周期感知能力[LifecycleAware]
  /// [useChildLifecycle] child是否需要生命周期感知能力[LifecycleAware], 需要先开启[useLifecycle]
  ///
  /// [NeverScrollableScrollPhysics]
  /// [BouncingScrollPhysics]
  ///
  /// [BasePageChildLifecycleState]
  ///
  @callPoint
  Widget buildPageView(
    BuildContext context, {
    List<Widget>? children,
    ScrollPhysics? physics,
    Axis axis = Axis.horizontal,
    Clip clipBehavior = Clip.hardEdge,
    //--
    bool pageSnapping = true,
    bool padEnds = true,
    //--
    bool disableScroll = false,
    //--
    bool useLifecycle = false,
    bool? useChildLifecycle,
    bool? keepAlive,
    //--
    void Function(int index)? onPageChangedAction,
  }) {
    //debugger();
    keepAlive ??= useLifecycle;
    useChildLifecycle ??= useLifecycle;

    WidgetList body = children ?? buildPageChildren(context);
    if (physics != null) {
      pageViewScrollPhysicsMixin = physics;
    }
    if (disableScroll) {
      pageViewScrollPhysicsMixin = const NeverScrollableScrollPhysics();
    }

    if (useChildLifecycle) {
      body = body.mapIndex((e, index) {
        return e.pageChildLifecycle(index: index, wantKeepAlive: keepAlive);
      }).toList();
    } else if (keepAlive) {
      body = body.map((e) {
        return e.keepAlive(keepAlive: keepAlive!);
      }).toList();
    }

    //焦点
    pageFocusScopeNodeList.fillToCount(body.length, (_) => FocusScopeNode());
    body = body.mapIndex((e, index) {
      return e.focusScope(
        node: pageFocusScopeNodeList[index],
        onFocusChange: (focused) {
          assert(() {
            l.v('[${classHash()}]页面[$index]焦点变化为:$focused');
            return true;
          }());
        },
      );
    }).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        //l.d(_pageController.page);
        final tabController = this.tabController;
        final pageViewController = this.pageViewController;
        if (tabController != null &&
            pageViewController != null &&
            pageViewController.hasClients) {
          final page = pageViewController.page;
          if (page == null) {
            assert(() {
              l.d('无效的page参数:$page');
              return true;
            }());
          } else {
            try {
              final tabIndex = tabController.index;
              final pageIndex = page.round();
              if (notification is ScrollUpdateNotification &&
                  !tabController.indexIsChanging) {
                final bool pageChanged = (page - tabIndex).abs() > 1.0;
                if (pageChanged) {
                  tabController.index = pageIndex;
                  //l.d("update index:${tabController.index}");
                }
                //指示器偏移
                tabController.offset = clampDouble(page - tabIndex, -1.0, 1.0);
                //l.d("update offset:${tabController.offset}");
              } else if (notification is ScrollEndNotification) {
                //l.d("end index:${tabController.index}->$pageIndex");
                if (!tabController.indexIsChanging) {
                  tabController.offset = 0;
                }
                tabController.index = pageIndex;
                /*if (!tabController.indexIsChanging) {
                                //指示器偏移
                                tabController.offset =
                                    clampDouble(page - tabIndex, -1.0, 1.0);
                                l.d("end offset:${tabController.offset}");
                              }*/
              }
            } catch (e, s) {
              assert(() {
                printError(e, s);
                return true;
              }());
            }
            return true;
          }
        }
        return false;
      },
      child: PageView(
        // [PageView.scrollDirection] defaults to [Axis.horizontal].
        // Use [Axis.vertical] to scroll vertically.
        controller: pageViewController,
        onPageChanged: (index) {
          onSelfPageViewChanged(context, index);
          onPageChangedAction?.call(index);
        },
        pageSnapping: pageSnapping,
        padEnds: padEnds,
        physics: physics ?? pageViewScrollPhysicsMixin,
        scrollDirection: axis,
        clipBehavior: clipBehavior,
        children: body,
      ).pageLifecycle(useLifecycle),
    );
  }

  /// 页面改变回调
  @overridePoint
  void onSelfPageViewChanged(BuildContext context, int index) {
    //hideKeyboard(); //隐藏键盘, 但是不获取焦点, 之前的输入框依旧具有焦点
    pageChangedUpdateSignal.updateValue(index);
    assert(() {
      l.v('onSelfPageViewChanged:$index');
      return true;
    }());
    if (this is NavigationBarMixin) {
      (this as NavigationBarMixin).currentNavigateIndexMixin = index;
      context.tryUpdateState();
    }
    //恢复焦点
    requestPageFocusMixin(context, index);
  }

  /// 切换页面
  @api
  void switchPageMixin(
    int index, {
    bool? animate,
    Duration? duration,
    Curve curve = Curves.ease,
  }) {
    final pageController = pageViewController;
    if (pageController != null && pageController.hasClients) {
      final page = pageController.page;
      bool isNoAnimate = false;
      if (animate == false || isPageViewNoAnimate) {
        //无动画
        isNoAnimate = true;
      } else if (animate == true ||
          (page != null && (page - index).abs() <= 1)) {
        //自动动画
      } else {
        isNoAnimate = true;
      }
      //--
      if (isNoAnimate) {
        pageController.jumpToPage(index);
      } else {
        pageController.animateToPage(
          index,
          duration: duration ?? kTabScrollDuration,
          curve: curve,
        );
      }
    }
  }

  /// 请求对应页面的焦点
  @api
  void requestPageFocusMixin(BuildContext context, int? index) {
    final pageScopeNode = pageFocusScopeNodeList.getOrNull(index);
    if (pageScopeNode != null) {
      FocusScope.of(context).requestFocus(pageScopeNode);
    }
  }

  //endregion --PageView--
}
