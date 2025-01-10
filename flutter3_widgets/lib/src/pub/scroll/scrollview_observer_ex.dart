part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/30
///
/// Flutter ScrollView Observer
/// https://github.com/fluttercandies/flutter_scrollview_observer/blob/main/README-zh.md
///
/// 滚动观察者混入, 监听滚动事件, 滚动到指定位置
mixin ScrollObserverMixin<T extends StatefulWidget> on State<T> {
  /// 创建对应的滚动控制器
  late ScrollController scrollControllerMixin = ScrollController();

  /// 不一样的[Widget]请使用不一样的控制器
  /// [ListView]
  late ListObserverController observerListController =
      ListObserverController(controller: scrollControllerMixin);

  /// [GridView]
  late GridObserverController observerGridController =
      GridObserverController(controller: scrollControllerMixin);

  //--

  /// 如果你的视图是 CustomScrollView，其 slivers 中包含了 SliverList 和 SliverGrid，这种情况也是支持的，
  /// 只不过需要使用 SliverViewObserver，并在调用滚动方法时传入对应的 BuildContext 以区分对应的 Sliver。
  late List<BuildContext> observerSliverContexts = [];

  /// [CustomScrollView]
  late SliverObserverController observerSliverController =
      SliverObserverController(controller: scrollControllerMixin)
        ..cacheJumpIndexOffset = false;

/*late SliverViewObserver observerSliverController =
      SliverViewObserver(controller: scrollControllerMixin, child: null,);*/

  @override
  void dispose() {
    scrollControllerMixin.dispose();
    super.dispose();
  }

  //--sliver

  /// 使用此方法创建[CustomScrollView]
  @callPoint
  Widget buildObserverCustomScrollView(
    BuildContext context,
    List<Widget> slivers, {
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    bool? primary,
    bool shrinkWrap = false,
    double anchor = 0,
    double? cacheExtent,
    Key? center,
    ScrollPhysics? physics,
    ScrollBehavior? scrollBehavior,
  }) {
    return SliverViewObserver(
      controller: observerSliverController,
      sliverContexts: () => observerSliverContexts,
      onObserveAll: (resultMap) {
        //ListViewObserveModel
        l.d(resultMap.values.join());
      },
      child: CustomScrollView(
        controller: scrollControllerMixin,
        scrollDirection: scrollDirection,
        reverse: reverse,
        primary: primary,
        shrinkWrap: shrinkWrap,
        anchor: anchor,
        cacheExtent: cacheExtent,
        center: center,
        physics: physics,
        scrollBehavior: scrollBehavior,
        slivers: slivers,
      ),
    );
  }

  /// [SliverList.builder]
  Widget buildObserverSliverListBuilder(
    BuildContext context,
    NullableIndexedWidgetBuilder itemBuilder,
  ) =>
      SliverList.builder(
        itemBuilder: (BuildContext context, int index) {
          if (!observerSliverContexts.contains(context)) {
            observerSliverContexts.add(context);
          }
          return itemBuilder(context, index);
        },
      );

  /// 滚动到指定位置
  void scrollObserverTo(
    int index, {
    Duration? duration = const Duration(milliseconds: 300),
    BuildContext? sliverContext,
  }) {
    if (duration == null) {
      observerSliverController.jumpTo(
        index: index,
        sliverContext: sliverContext ?? observerSliverContexts.firstOrNull,
      );
    } else {
      observerSliverController.animateTo(
        index: index,
        duration: duration,
        curve: Curves.easeInOut,
        sliverContext: sliverContext ?? observerSliverContexts.firstOrNull,
      );
    }
  }

//--
}
