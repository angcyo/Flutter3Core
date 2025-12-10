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
  late ListObserverController observerListController = ListObserverController(
    controller: scrollControllerMixin,
  );

  /// [GridView]
  late GridObserverController observerGridController = GridObserverController(
    controller: scrollControllerMixin,
  );

  //MARK: - late

  /// 如果你的视图是 CustomScrollView，其 slivers 中包含了 SliverList 和 SliverGrid，这种情况也是支持的，
  /// 只不过需要使用 SliverViewObserver，并在调用滚动方法时传入对应的 BuildContext 以区分对应的 Sliver。
  late List<BuildContext> observerSliverContexts = [];

  /// [CustomScrollView]
  /// - [SliverObserverController.dispatchOnceObserve] 触发一次
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

  //MARK: - sliver

  /// 使用此方法创建[CustomScrollView], 再用[buildObserverSliverListBuilder]创建滚动内容
  /// 之后就可以使用[scrollObserverTo]滚动内容
  ///
  /// - [slivers]需要是使用[buildObserverSliverListBuilder]创建的滚动内容
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
    //--
    OnObserveAllCallback<ObserveModel>? onObserveAll,
    OnObserveCallback<ObserveModel>? onObserve,
  }) {
    return SliverViewObserver(
      controller: observerSliverController,
      sliverContexts: () => observerSliverContexts,
      onObserveAll: (resultMap) {
        //ListViewObserveModel
        //debugger();
        assert(() {
          //[_YDDesktopCreationSettingDialogState(b7a6689)]_Map<BuildContext, ObserveModel>[1]->ListViewObserveModel
          /*l.v(
            "[${classHash()}]${resultMap.runtimeType}[${resultMap.length}]->${resultMap.values.connect(",", (e) => e.runtimeType.toString())}",
          );*/
          return true;
        }());
        onObserveAll?.call(resultMap);
      },
      onObserve: (result) {
        //ListViewObserveModel
        //final m1 = scrollControllerMixin;
        //final c1 = observerSliverController;
        //l.d("maxScrollExtent->${m1.position.maxScrollExtent}");
        //debugger();
        assert(() {
          //[_YDDesktopCreationSettingDialogState(b7a6689)]ListViewObserveModel->[1, 2, 3]
          /*l.v(
            '[${classHash()}]${result.runtimeType}->${result.displayingChildIndexList}',
          );*/
          return true;
        }());
        onObserve?.call(result);
        onObserverVisibleItemChanged(result.displayingChildIndexList);
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

  /// 构建一个可以被观察的[SliverList.builder]
  Widget buildObserverSliverListBuilder(
    BuildContext context, {
    List<Widget>? children,
    NullableIndexedWidgetBuilder? itemBuilder,
  }) => SliverList.builder(
    itemBuilder: (BuildContext ctx, int index) {
      if (!observerSliverContexts.contains(ctx)) {
        observerSliverContexts.add(ctx);
      }
      final item = itemBuilder?.call(ctx, index) ?? children?.getOrNull(index);
      //l.d("build item->$index");
      return item;
    },
  );

  /// 当滚动时, 可见的item发生改变时回调
  @overridePoint
  void onObserverVisibleItemChanged(List<int> childIndexList) {
    //no op
  }

  //MARKl: - api

  /// 滚动到指定位置
  /// [alignment] 参数用于指定你期望定位到子部件的对齐位置，该值需要在 [0.0, 1.0] 这个范围之间。默认为 0，比如：
  ///
  /// - alignment: 0 : 滚动到子部件的顶部位置
  /// - alignment: 0.5 : 滚动到子部件的中间位置
  /// - alignment: 1 : 滚动到子部件的尾部位置
  ///
  /// https://github.com/fluttercandies/flutter_scrollview_observer/wiki/2%E3%80%81%E6%BB%9A%E5%8A%A8%E5%88%B0%E6%8C%87%E5%AE%9A%E4%B8%8B%E6%A0%87%E4%BD%8D%E7%BD%AE#25alignment-%E5%8F%82%E6%95%B0
  @api
  void scrollObserverTo(
    int index, {
    BuildContext? sliverContext,
    Duration? duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double alignment = 0,
  }) {
    if (duration == null) {
      observerSliverController.jumpTo(
        index: index,
        alignment: alignment,
        sliverContext: sliverContext ?? observerSliverContexts.firstOrNull,
      );
    } else {
      observerSliverController.animateTo(
        index: index,
        alignment: alignment,
        duration: duration,
        curve: curve,
        sliverContext: sliverContext ?? observerSliverContexts.firstOrNull,
      );
    }
  }

  /// 滚动到顶部
  @api
  void scrollObserverToTop({
    Duration? duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double offset = 0,
  }) {
    if (duration == null) {
      observerSliverController.controller?.scrollToTop(
        anim: false,
        offset: offset,
      );
    } else {
      observerSliverController.controller?.scrollToTop(
        anim: true,
        offset: offset,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// 滚动到底部
  @api
  void scrollObserverToBottom({
    Duration? duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    observerSliverController.controller?.scrollToBottom(
      anim: duration != null,
      duration: duration,
      curve: curve,
    );
  }

  //--
}
