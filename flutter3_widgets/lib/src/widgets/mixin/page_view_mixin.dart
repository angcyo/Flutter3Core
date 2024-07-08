part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/08
///
mixin PageViewMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  /// [PageView]页面控制器, 用来切换页面
  PageController? get pageViewController;

  /// 用来配合[TabBar]实现指示器的滚动效果
  TabController? get tabController;

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

  /// 构建子页面
  /// [buildPageView]->[buildPageChildren]
  WidgetList buildPageChildren(BuildContext context) => [];

  /// 构建[PageView]
  Widget buildPageView(
    BuildContext context, {
    List<Widget>? children,
    ScrollPhysics? physics,
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
              if (notification is ScrollUpdateNotification &&
                  !tabController.indexIsChanging) {
                final bool pageChanged = (page - tabIndex).abs() > 1.0;
                if (pageChanged) {
                  tabController.index = page.round();
                }
                //指示器偏移
                tabController.offset = clampDouble(page - tabIndex, -1.0, 1.0);
              } else if (notification is ScrollEndNotification) {
                tabController.index = page.round();
                if (!tabController.indexIsChanging) {
                  //指示器偏移
                  tabController.offset =
                      clampDouble(page - tabIndex, -1.0, 1.0);
                }
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
          clipBehavior: clipBehavior,
          children: children ?? buildPageChildren(context),
        ),
      );

  void onSelfPageViewChanged(int index) {
    assert(() {
      l.d('onSelfPageViewChanged:$index');
      return true;
    }());
  }
}
