part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/08
///
/// [PageView]
///
/// https://api.flutter.dev/flutter/widgets/PageView-class.html
///
mixin PageViewMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  /// [PageView]页面控制器, 用来切换页面
  PageController? get pageViewController;

  /// 用来配合[TabBar]实现指示器的滚动效果
  TabController? get tabController {
    if (this is TabLayoutMixin) {
      //自动挂载
      return (this as TabLayoutMixin).tabLayoutController;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageViewController?.dispose();
    tabController?.dispose();
    super.dispose();
  }

  //region --PageView--

  /// 构建子页面
  /// [buildPageView]->[buildPageChildren]
  @callPoint
  @overridePoint
  WidgetList buildPageChildren(BuildContext context) => [];

  /// 构建[PageView], 当切换界面后[children]并不会重新获取, 所以需要手动处理界面数据
  /// - [KeepAliveWrapper]
  /// - [KeepAliveWrapperExtension.keepAlive]
  @callPoint
  Widget buildPageView(
    BuildContext context, {
    List<Widget>? children,
    ScrollPhysics? physics,
    Axis axis = Axis.horizontal,
    Clip clipBehavior = Clip.hardEdge,
    bool pageSnapping = true,
    bool padEnds = true,
  }) =>
      NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          //l.d(_pageController.page);
          final tabController = this.tabController;
          final pageViewController = this.pageViewController;
          if (tabController != null && pageViewController != null) {
            final page = pageViewController.page;
            if (page == null) {
              assert(() {
                l.d('无效的page参数:$page');
                return true;
              }());
            } else {
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
                tabController.index = pageIndex;
                tabController.offset = 0;
                /*if (!tabController.indexIsChanging) {
                  //指示器偏移
                  tabController.offset =
                      clampDouble(page - tabIndex, -1.0, 1.0);
                  l.d("end offset:${tabController.offset}");
                }*/
              }
              return true;
            }
          }
          return false;
        },
        child: PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: pageViewController,
          onPageChanged: onSelfPageViewChanged,
          pageSnapping: pageSnapping,
          padEnds: padEnds,
          physics: physics,
          scrollDirection: axis,
          clipBehavior: clipBehavior,
          children: children ?? buildPageChildren(context),
        ),
      );

  /// 页面改变回调
  @overridePoint
  void onSelfPageViewChanged(int index) {
    assert(() {
      l.d('onSelfPageViewChanged:$index');
      return true;
    }());
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
    if (pageController != null) {
      final page = pageController.page;
      if (animate == true || (page != null && (page - index).abs() <= 1)) {
        //自动动画
        pageController.animateToPage(
          index,
          duration: duration ?? kTabScrollDuration,
          curve: curve,
        );
      } else {
        pageController.jumpToPage(index);
      }
    }
  }

//endregion --PageView--
}
