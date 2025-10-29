part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///

//region 帧相关

/// 当前是否处于调度阶段
/// [_LayoutBuilderElement._scheduleRebuild]
bool get isSchedulerPhase {
  /*final bool deferMarkNeedsLayout =
      switch (SchedulerBinding.instance.schedulerPhase) {
    SchedulerPhase.idle || SchedulerPhase.postFrameCallbacks => true,
    SchedulerPhase.transientCallbacks ||
    SchedulerPhase.midFrameMicrotasks ||
    SchedulerPhase.persistentCallbacks =>
      false,
  };
  return deferMarkNeedsLayout;*/
  return WidgetsBinding.instance.schedulerPhase ==
      SchedulerPhase.persistentCallbacks;
}

/// 当前是否处于空闲阶段
bool get isSchedulerIdle =>
    WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle;

/// 立即安排一帧
/// [scheduleTask]
/// [scheduleMicrotask]
void scheduleFrame() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.scheduleFrame();
}

/// 每一帧都会回调
/// [WidgetsFlutterBinding.cancelFrameCallbackWithId]
/// [Ticker.scheduleTick]
/// [once] 是否只处理一次?
/// @return id
int scheduleFrameCallback(
  FrameCallback callback, {
  bool rescheduling = false,
  bool once = false,
}) {
  WidgetsFlutterBinding.ensureInitialized();
  int? cancelId;
  final id = WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
    if (once && cancelId != null) {
      WidgetsBinding.instance.cancelFrameCallbackWithId(cancelId);
    }
    callback(timeStamp);
  }, rescheduling: rescheduling);
  cancelId = id;
  return id;
}

/// [postFrame]
/// [postFrameCallback]
void postCallback(VoidCallback callback, [String debugLabel = 'postCallback']) {
  postFrameCallback((_) => callback(), debugLabel);
}

/// 一帧后回调, 只会触发一次. 不会请求新的帧
/// [postFrameCallback]
/// [postCallback]
/// [postDelayCallback]
/// [delayCallback]
/// [scheduleMicrotask]
void postFrameCallback(
  FrameCallback callback, [
  String debugLabel = 'postFrameCallback',
]) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPostFrameCallback(
    callback,
    debugLabel: debugLabel,
  );
}

/// 下一针回调
/// [postFrameCallback]
void postFrame(VoidCallback? callback, [bool microtask = false]) {
  if (callback == null) {
    return;
  }
  if (microtask) {
    scheduleMicrotask(callback);
  } else {
    postFrameCallback((_) => callback());
  }
}

/// - [scheduleMicrotask]
/// - [postFrameCallback]
///
/// - [$next]
/// - [$nextFrame]
void $next(void Function()? callback, [bool microtask = true]) {
  postFrame(callback, microtask);
}

/// - [scheduleMicrotask]
/// - [postFrameCallback]
///
/// - [$next]
/// - [$nextFrame]
void $nextFrame(void Function()? callback, [bool microtask = false]) {
  postFrame(callback, microtask);
}

/// 如果正在布局阶段, 则立即安排一帧, 否则立即执行回调
void postFrameCallbackIfNeed(FrameCallback callback) {
  WidgetsFlutterBinding.ensureInitialized();
  if (isSchedulerPhase) {
    postFrameCallback(callback);
  } else {
    callback(Duration(milliseconds: nowTimestamp()));
  }
}

extension FrameFnEx on Function {
  /// [scheduleMicrotask]
  void nextMicrotask() {
    scheduleMicrotask(() => this.call());
  }

  /// [postFrameCallback]
  void nextFrame() {
    postFrame(() => this.call());
  }
}

extension FrameCallbackEx on int {
  /// 取消帧回调
  void cancelFrameCallbackWithId() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.cancelFrameCallbackWithId(this);
  }
}

//endregion 帧相关

//region 界面相关

typedef WidgetList = List<Widget>;
typedef WidgetIterable = Iterable<Widget>;
typedef WidgetNullList = List<Widget?>;
typedef WidgetNullIterable = Iterable<Widget?>;

/// [edgeInsets]
/// [edgeOnly]
/// [insets]
EdgeInsets? edgeOnly({
  //全部设置
  double? all,
  //水平垂直设置
  double? vertical,
  double? horizontal,
  //除了此方向, 其它都设置
  double? nLeft,
  double? nTop,
  double? nRight,
  double? nBottom,
  //单独设置
  double? left,
  double? top,
  double? right,
  double? bottom,
}) => EdgeInsets.only(
  left: left ?? nTop ?? nRight ?? nBottom ?? horizontal ?? all ?? 0,
  top: top ?? nLeft ?? nRight ?? nBottom ?? vertical ?? all ?? 0,
  right: right ?? nLeft ?? nTop ?? nBottom ?? horizontal ?? all ?? 0,
  bottom: bottom ?? nLeft ?? nTop ?? nRight ?? vertical ?? all ?? 0,
);

/// [edgeOnly]
/// [insets]
EdgeInsets? insets({
  //全部设置
  double? all,
  //水平垂直设置
  double? vertical,
  double? horizontal,
  //除了此方向, 其它都设置
  double? nLeft,
  double? nTop,
  double? nRight,
  double? nBottom,
  //单独设置
  double? left,
  double? top,
  double? right,
  double? bottom,
}) => edgeOnly(
  all: all,
  vertical: vertical,
  horizontal: horizontal,
  nLeft: nLeft,
  nTop: nTop,
  nRight: nRight,
  nBottom: nBottom,
  left: left,
  top: top,
  right: right,
  bottom: bottom,
);

/// 将当前的小部件, 包裹在一个[Padding]中
/// 根据html的padding属性, 生成padding
EdgeInsets? edgeInsets([double? v1, double? v2, double? v3, double? v4]) {
  //如果是4个参数
  if (v1 != null && v2 != null && v3 != null && v4 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v3, v4);
  }
  //如果是3个参数
  if (v1 != null && v2 != null && v3 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v3, v2);
  }
  //如果是2个参数
  if (v1 != null && v2 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v1, v2);
  }
  //如果是1个参数
  if (v1 != null) {
    return EdgeInsets.all(v1);
  }
  return null;
}

/// 通过[Builder]小部件, 获取当前元素的[BuildContext]
/// 然后当前[BuildContext]更新只会影响其子元素, 父元素不会受到影响
///
/// [statefulBuilder]
///
/// [WidgetBuilder]
/// [Builder]
Widget builder(WidgetBuilder builder, [Key? key]) =>
    Builder(builder: builder, key: key);

/// [builder]
/// [StateSetter]
///
/// [StatefulWidgetBuilder]
/// [StatefulBuilder]
Widget statefulBuilder(StatefulWidgetBuilder builder, [Key? key]) =>
    StatefulBuilder(builder: builder, key: key);

/// 可以在布局过程中拿到父组件传递的约束信息，然后我们可以根据约束信息动态的构建不同的布局。
/// [Element.mount].[Element.update] 在此回调用安排并触发布局回调
/// [RenderObject.invokeLayoutCallback] 触发布局回调和执行
///
/// [BuildOwner.buildScope] 安排布局
/// [Element.updateChild] 布局完成后, 更新子元素
///
/// [LayoutBuilder]
/// https://pub.dev/packages/value_layout_builder
///
/// [sliverLayout]
/// [_DeferredLayout] 延迟布局
Widget layout(
  Widget Function(BuildContext context, BoxConstraints constraints) builder, [
  Key? key,
]) => LayoutBuilder(builder: builder, key: key);

/// [SliverLayoutBuilder]
Widget sliverLayout(
  Widget Function(BuildContext context, SliverConstraints constraints)
  builder, [
  Key? key,
]) => SliverLayoutBuilder(builder: builder, key: key);

/// [List<Widget>]
extension WidgetListEx on WidgetNullList {
  /// 过滤空数据和填充间隙
  WidgetList filterAndFillGap({double? gap, Widget? gapWidget}) {
    WidgetList list = filterNull();
    WidgetList children = list;
    final length = list.length;
    if (length > 1 && (gap != null || gapWidget != null)) {
      children = <Widget>[];
      for (var i = 0; i < length; i++) {
        children.add(list[i]);
        if (i < length - 1) {
          if (gapWidget != null) {
            children.add(gapWidget);
          } else {
            children.add(Empty(size: Size(gap!, gap)));
          }
        }
      }
    }
    return children;
  }

  /// 将当前的小部件集合, 包裹在一个[Wrap]中
  /// [spacing] 元素之间的间隙
  /// [runSpacing] 换行后的间隙
  /// [alignment] 主轴对齐方式, 集体靠左/靠右/居中
  /// [crossAxisAlignment] 交叉轴对齐方式, 就是每一行的对齐方式
  Widget? wrap({
    Key? key,
    double spacing = kH,
    double runSpacing = kH,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
  }) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
    return Wrap(
      key: key,
      spacing: spacing,
      runSpacing: runSpacing,
      direction: direction,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
      children: list,
    );
  }

  /// 使用[Column]包裹
  /// [mainAxisAlignment] 主轴上的对齐方式, 水平方向, 水平左对齐, 水平居中, 水平右对齐
  /// [mainAxisSize] 主轴尺寸, 是要用最大尺寸, 还是要最小尺寸
  /// [crossAxisAlignment] 交叉轴上的对齐方式, 垂直方向, 垂直顶部对齐, 垂直居中对齐, 垂直底部对齐
  /// [gap] 间隙
  Widget? column({
    Key? key,
    MainAxisSize? mainAxisSize, //MainAxisSize.min
    MainAxisAlignment? mainAxisAlignment, //MainAxisAlignment.start
    CrossAxisAlignment? crossAxisAlignment, //CrossAxisAlignment.center
    TextDirection? textDirection,
    VerticalDirection? verticalDirection, //VerticalDirection.down
    TextBaseline? textBaseline,
    double? gap,
    Widget? gapWidget,
    String? debugLabel,
  }) {
    WidgetList children = filterAndFillGap(gapWidget: gapWidget);
    debugger(when: debugLabel != null);
    if (isNullOrEmpty(children)) {
      return null;
    }
    return Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      mainAxisSize: mainAxisSize ?? MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      textDirection: textDirection,
      verticalDirection: verticalDirection ?? VerticalDirection.down,
      textBaseline: textBaseline,
      spacing: gap ?? 0,
      children: children,
    );
  }

  /// 使用[Row]包裹
  /// [mainAxisAlignment] 主轴对齐方式, 水平方向, 水平左对齐, 水平居中, 水平右对齐
  /// [mainAxisSize] 主轴尺寸, 是要用最大尺寸, 还是要最小尺寸
  /// [crossAxisAlignment] 交叉轴对齐方式, 垂直方向, 垂直顶部对齐, 垂直居中对齐, 垂直底部对齐
  /// [gap] 间隙
  ///
  /// [LastExtendRow]
  ///
  Widget? row({
    Key? key,
    MainAxisSize? mainAxisSize, //MainAxisSize.max
    MainAxisAlignment? mainAxisAlignment, //MainAxisAlignment.start
    CrossAxisAlignment? crossAxisAlignment, //CrossAxisAlignment.center
    TextDirection? textDirection,
    VerticalDirection? verticalDirection, //VerticalDirection.down
    TextBaseline? textBaseline,
    double? gap,
    Widget? gapWidget,
    //--
    bool lastExtend = false,
  }) {
    WidgetList children = filterAndFillGap(gapWidget: gapWidget);
    if (isNullOrEmpty(children)) {
      return null;
    }
    return lastExtend
        ? LastExtendRow(
            key: key,
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
            mainAxisSize: mainAxisSize ?? MainAxisSize.max,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
            textDirection: textDirection,
            verticalDirection: verticalDirection ?? VerticalDirection.down,
            textBaseline: textBaseline,
            spacing: gap ?? 0,
            children: children,
          )
        : Row(
            key: key,
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
            mainAxisSize: mainAxisSize ?? MainAxisSize.max,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
            textDirection: textDirection,
            verticalDirection: verticalDirection ?? VerticalDirection.down,
            textBaseline: textBaseline,
            spacing: gap ?? 0,
            children: children,
          );
  }

  /// [Stack]
  Widget? stack({
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
    return Stack(
      key: key,
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
      children: list,
    );
  }

  /// [SingleChildScrollView]
  ///
  /// [physics] 滚动行为, 如果需要下拉返回功能, 这里就需要设置为null.
  /// 系统会通过[ScrollConfiguration]自动获取到[PullBackScrollPhysics]
  ///
  /// - [scroll]
  /// - [WidgetListEx.scrollVertical]
  /// - [WidgetListEx.scrollHorizontal]
  /// - [WidgetEx.scroll]
  Widget? scroll({
    Key? key,
    //--
    Axis axis = Axis.horizontal,
    ScrollPhysics? physics = kScrollPhysics,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
    //--
    MainAxisSize? mainAxisSize, //MainAxisSize.min
    MainAxisAlignment? mainAxisAlignment, //MainAxisAlignment.start
    CrossAxisAlignment? crossAxisAlignment, //CrossAxisAlignment.start
    double? gap,
    Widget? gapWidget,
  }) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
    Widget body;
    if (axis == Axis.vertical) {
      body = list.column(
        mainAxisSize: mainAxisSize ?? MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        gap: gap,
        gapWidget: gapWidget,
      )!;
    } else {
      body = list.row(
        mainAxisSize: mainAxisSize ?? MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        gap: gap,
        gapWidget: gapWidget,
      )!;
    }
    return body.scroll(
      key: key,
      scrollDirection: axis,
      physics: physics,
      controller: controller,
      padding: padding,
      primary: primary,
      reverse: reverse,
    );
  }

  /// 垂直滚动
  /// - [Row]
  /// - [Column]
  /// - [SingleChildScrollView]
  Widget? scrollVertical({
    Key? key,
    //--
    Axis axis = Axis.vertical,
    ScrollPhysics? physics = kScrollPhysics,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
    //--
    MainAxisSize? mainAxisSize = MainAxisSize.max,
    MainAxisAlignment? mainAxisAlignment, //MainAxisAlignment.start
    CrossAxisAlignment? crossAxisAlignment, //CrossAxisAlignment.start 交叉轴
    double? gap,
    Widget? gapWidget,
  }) => scroll(
    key: key,
    axis: axis,
    physics: physics,
    controller: controller,
    padding: padding,
    primary: primary,
    reverse: reverse,
    mainAxisSize: mainAxisSize,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    gap: gap,
    gapWidget: gapWidget,
  );

  /// 横向滚动
  /// - [Row]
  /// - [Column]
  /// - [SingleChildScrollView]
  Widget? scrollHorizontal({
    Key? key,
    //--
    Axis axis = Axis.horizontal,
    ScrollPhysics? physics = kScrollPhysics,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
    //--
    MainAxisSize? mainAxisSize = MainAxisSize.max,
    MainAxisAlignment? mainAxisAlignment, //MainAxisAlignment.start
    CrossAxisAlignment? crossAxisAlignment =
        CrossAxisAlignment.center, //CrossAxisAlignment.center
    double? gap,
    Widget? gapWidget,
  }) => scroll(
    key: key,
    axis: axis,
    physics: physics,
    controller: controller,
    padding: padding,
    primary: primary,
    reverse: reverse,
    mainAxisSize: mainAxisSize,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    gap: gap,
    gapWidget: gapWidget,
  );

  /// 绘制边界
  /// https://docs.flutter.dev/tools/devtools/inspector#highlight-repaints
  /// [WidgetEx.repaintBoundary]
  /// [debugRepaintRainbowEnabled]
  WidgetList repaintBoundary() => RepaintBoundary.wrapAll(filterNull());
}

/// [Widget]
extension WidgetEx on Widget {
  //region operator

  /// 使用[Row]横向包裹[count]个[Widget]
  Widget operator *(int? count) => (count ?? 0) > 1
      ? [
          for (int i = 0; i < count!; i++) this,
        ].row(mainAxisSize: MainAxisSize.min)!
      : this;

  /// 使用[Column]横向包裹[count]个[Widget]
  Widget operator /(int? count) => (count ?? 0) > 1
      ? [
          for (int i = 0; i < count!; i++) this,
        ].column(mainAxisSize: MainAxisSize.min)!
      : this;

  //endregion operator

  /// 为child添加一个key
  /// [KeyedSubtree]
  /// [repaintBoundary]
  Widget childKeyed(Key? key) =>
      key == null ? this : KeyedSubtree(key: key, child: this);

  /// [Tooltip] 提示
  Widget tooltip(String? tip, {InlineSpan? richMessage}) => tip == null
      ? this
      : Tooltip(message: tip, richMessage: richMessage, child: this);

  /// [Hero]
  /// hero动画不能在Dialog中使用
  Widget hero(Object? tag) => tag == null ? this : Hero(tag: tag, child: this);

  /// 将[BoxConstraints]约束转换成[SliverConstraints]约束
  /// [SliverToBoxAdapter]
  SliverToBoxAdapter toSliver([Key? key]) =>
      SliverToBoxAdapter(key: key, child: this);

  /// 监听手势
  /// [Listener]
  /// [click]
  ///
  /// [gesture]
  /// [listenerPointer]
  Widget listenerPointer({
    bool enable = true,
    Key? key,
    PointerDownEventListener? onPointerDown,
    PointerMoveEventListener? onPointerMove,
    PointerUpEventListener? onPointerUp,
    PointerHoverEventListener? onPointerHover,
    PointerCancelEventListener? onPointerCancel,
    PointerPanZoomStartEventListener? onPointerPanZoomStart,
    PointerPanZoomUpdateEventListener? onPointerPanZoomUpdate,
    PointerPanZoomEndEventListener? onPointerPanZoomEnd,
    PointerSignalEventListener? onPointerSignal,
    HitTestBehavior behavior = HitTestBehavior.translucent,
    //--
    void Function(PointerEvent event)? onPointerFinish /*手势结束事件*/,
  }) => enable
      ? Listener(
          key: key,
          onPointerDown: onPointerDown,
          onPointerMove: onPointerMove,
          onPointerUp:
              onPointerUp ??
              (onPointerFinish == null
                  ? null
                  : (event) => onPointerFinish(event)),
          onPointerHover: onPointerHover,
          onPointerCancel:
              onPointerCancel ??
              (onPointerFinish == null
                  ? null
                  : (event) => onPointerFinish(event)),
          onPointerPanZoomStart: onPointerPanZoomStart,
          onPointerPanZoomUpdate: onPointerPanZoomUpdate,
          onPointerPanZoomEnd: onPointerPanZoomEnd,
          onPointerSignal: onPointerSignal,
          behavior: behavior,
          child: this,
        )
      : this;

  /// 点击事件
  /// [enable] 是否启用点击事件
  /// [behavior] 点击事件的命中测试行为
  /// [HitTestBehavior.translucent] 后代和自己都可以命中
  /// [HitTestBehavior.opaque] 只有自己可以命中
  /// [HitTestBehavior.deferToChild] 只有后代可以命中
  ///
  /// [RenderPointerListener]->[RenderProxyBoxWithHitTestBehavior]
  ///
  /// [GestureDetector] 多个手势识别器, 才会有手势竞争
  /// [Listener] 监听手势, 不会有手势竞争
  /// [GestureRecognizer] 手势识别器base
  /// [TapGestureRecognizer] 单击手势识别器
  /// [DoubleTapGestureRecognizer] 双击手势识别器
  /// [LongPressGestureRecognizer] 长按手势识别器
  /// [DragGestureRecognizer] 拖动手势识别器
  /// [ScaleGestureRecognizer] 缩放手势识别器
  /// [PanGestureRecognizer] 拖动手势识别器
  /// [MultiTapGestureRecognizer] 多击手势识别器
  /// [EagerGestureRecognizer] 急切手势识别器
  /// [RotateGestureRecognizer] 旋转手势识别
  /// [RenderProxyBoxWithHitTestBehavior]
  /// [click]
  /// [doubleClick]
  ///
  /// 键盘监听
  /// ```
  /// ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
  /// ```
  ///
  /// 鼠标监听
  /// [Listener.onPointerSignal]
  Widget click(
    GestureTapCallback? onTap, {
    bool enable = true,
    GestureLongPressCallback? onLongPress,
    HitTestBehavior? behavior = HitTestBehavior.translucent,
  }) => onTap == null || !enable
      ? this
      : GestureDetector(
          onTap: onTap,
          behavior: behavior,
          onLongPress: onLongPress,
          child: this,
        );

  /// 双击事件
  /// [RenderProxyBoxWithHitTestBehavior]
  /// [click]
  /// [doubleClick]
  Widget doubleClick(
    GestureTapCallback? onDoubleTap, {
    bool enable = true,
    GestureTapCallback? onTap,
    HitTestBehavior? behavior = HitTestBehavior.translucent,
  }) => onDoubleTap == null || !enable
      ? this
      : GestureDetector(
          onDoubleTap: onDoubleTap,
          onTap: onTap,
          behavior: behavior,
          child: this,
        );

  /// 长按事件
  /// [behavior] 手势的命中测试行为, 父子都需要手势, 但是不想冲突, 可以设置[HitTestBehavior.opaque]
  /// [RenderProxyBoxWithHitTestBehavior]
  Widget longClick(
    GestureLongPressCallback? onLongPress, {
    bool enable = true,
    HitTestBehavior? behavior = HitTestBehavior.translucent,
    GestureTapCallback? onTap,
  }) => (onLongPress == null && onTap == null) || !enable
      ? this
      : GestureDetector(
          onLongPress: onLongPress,
          onTap: onTap,
          behavior: behavior,
          child: this,
        );

  /// 手势探测
  /// [onVerticalDragUpdate] 仅在垂直滑动时回调
  /// [onHorizontalDragUpdate] 仅在水平滑动时回调
  /// [onPanUpdate] 水平或垂直滑动时回调
  ///
  /// [GestureDetector]
  ///
  /// [gesture]
  /// [listenerPointer]
  Widget gesture({
    //--
    GestureDragStartCallback? onVerticalDragStart,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    GestureDragEndCallback? onVerticalDragEnd,
    //--
    GestureDragStartCallback? onHorizontalDragStart,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragEndCallback? onHorizontalDragEnd,
    //--
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
    //--
    GestureLongPressCallback? onLongPress,
    GestureTapCallback? onTap,
    //--
    HitTestBehavior? behavior = HitTestBehavior.translucent,
  }) {
    return GestureDetector(
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      //--
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      //--
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      //--
      onLongPress: onLongPress,
      onTap: onTap,
      //--
      behavior: behavior,
      child: this,
    );
  }

  /// 鼠标事件监听
  /// [MouseRegion] 鼠标区域
  /// [TapRegion]   手势区域
  ///
  /// [MouseTracker].[MouseTrackerAnnotation]
  /// 只要实现[MouseTrackerAnnotation], 并且[HitTestEntry]命中返回, 即可获取鼠标事件.
  /// 在参考[RenderMouseRegion]
  ///
  /// [onHover].来自[PointerHoverEvent]事件
  ///
  /// [_TransformedPointerEnterEvent]
  /// [_TransformedPointerHoverEvent]
  /// [_TransformedPointerExitEvent]
  ///
  Widget mouse({
    //--
    void Function(bool enter)? onMouseAction,
    //--
    Key? key,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    PointerHoverEventListener? onHover,
    MouseCursor cursor = MouseCursor.defer,
    bool opaque = true,
    HitTestBehavior? hitTestBehavior,
    bool enable = true,
  }) => enable
      ? MouseRegion(
          key: key,
          onEnter:
              onEnter ??
              (onMouseAction != null
                  ? (event) {
                      onMouseAction(true);
                    }
                  : null),
          onExit:
              onExit ??
              (onMouseAction != null
                  ? (event) {
                      onMouseAction(false);
                    }
                  : null),
          onHover: onHover,
          cursor: cursor,
          opaque: opaque,
          hitTestBehavior: hitTestBehavior,
          child: this,
        )
      : this;

  /// 焦点域
  /// - [FocusScope]
  Widget focusScope({
    //--
    bool enable = true,
    FocusScopeNode? node,
    //--
    Key? key,
    bool autofocus = true,
    FocusNode? focusNode,
    FocusNode? parentNode,
    ValueChanged<bool>? onFocusChange,
    FocusOnKeyEventCallback? onKeyEvent,
    //--
    bool? canRequestFocus,
    bool? skipTraversal,
  }) => enable
      ? FocusScope(
          node: node,
          parentNode: parentNode,
          autofocus: autofocus,
          onKeyEvent: onKeyEvent,
          canRequestFocus: canRequestFocus,
          skipTraversal: skipTraversal,
          onFocusChange:
              onFocusChange ??
              (isDebug
                  ? (value) {
                      l.i('[${classHash()}] focus change: $value');
                    }
                  : null),
          child: this,
        )
      : this;

  /// 焦点, 同一个焦点[FocusNode]不能重复使用,尤其是父子级使用.
  ///
  /// 如果内部包含了子焦点, 自子焦点失去焦点后, 当前焦点也会同样失去.
  ///
  /// ```
  /// Tried to make a child into a parent of itself.
  /// ```
  ///
  /// - [onKeyEvent] 具有焦点之后, 键盘事件会回调[onKeyEvent]
  ///
  /// - [Focus]
  /// - [FocusScope]
  ///
  /// - [KeyboardListener]
  Widget focus({
    //--
    bool enable = true,
    //--
    Key? key,
    bool autofocus = true,
    FocusNode? focusNode,
    FocusNode? parentNode,
    ValueChanged<bool>? onFocusChange,
    FocusOnKeyEventCallback? onKeyEvent,
    //--
    bool? canRequestFocus,
    bool? skipTraversal,
  }) => enable
      ? Focus(
          focusNode: focusNode,
          parentNode: parentNode,
          autofocus: autofocus,
          onKeyEvent: onKeyEvent,
          canRequestFocus: canRequestFocus,
          skipTraversal: skipTraversal,
          onFocusChange:
              onFocusChange ??
              (isDebug
                  ? (value) {
                      l.i('[${classHash()}] focus change $value');
                    }
                  : null),
          child: this,
        )
      : this;

  /// [KeyEventWidget]
  Widget keyEvent(
    List<KeyboardKey> keys,
    KeyEventHandleAction? onKeyEventAction, {
    //--
    bool enable = true,
    //--
    Key? key,
    List<List<KeyboardKey>>? eventGroupKeys,
    //--
    bool stopPropagation = true,
    bool matchKeyCount = true,
    bool keyDown = true,
    bool keyRepeat = false,
    bool keyUp = false,
  }) => enable
      ? KeyEventWidget(
          key: key,
          keyEventRegisterList: [
            KeyEventRegister(
              eventGroupKeys ?? [keys],
              onKeyEventAction: onKeyEventAction,
              stopPropagation: stopPropagation,
              matchKeyCount: matchKeyCount,
              keyDown: keyDown,
              keyRepeat: keyRepeat,
              keyUp: keyUp,
            ),
          ],
          child: this,
        )
      : this;

  /// 监听按键事件
  /// - [KeyEventWidget]
  Widget keyEventList(
    List<KeyEventRegister> keyEventRegisterList, {
    //--
    bool enable = true,
    //--
    Key? key,
  }) => enable
      ? KeyEventWidget(
          key: key,
          keyEventRegisterList: keyEventRegisterList,
          child: this,
        )
      : this;

  /// 按键事件监听, 同样需要在有焦点的时候才会触发回调
  ///
  /// ```
  /// # Escape 按下/抬起
  /// KeyDownEvent#b5fcc(physicalKey: PhysicalKeyboardKey#e41f8(usbHidUsage: "0x00070029", debugName: "Escape"), logicalKey: LogicalKeyboardKey#4eada(keyId: "0x10000001b", keyLabel: "Escape", debugName: "Escape"), character: "", timeStamp: 312:12:22.271771)
  /// KeyUpEvent#c2df8(physicalKey: PhysicalKeyboardKey#e41f8(usbHidUsage: "0x00070029", debugName: "Escape"), logicalKey: LogicalKeyboardKey#4eada(keyId: "0x10000001b", keyLabel: "Escape", debugName: "Escape"), character: null, timeStamp: 312:12:22.375289)
  ///
  /// # 回车键 按下/抬起
  /// KeyDownEvent#3c98c(physicalKey: PhysicalKeyboardKey#e14a9(usbHidUsage: "0x00070028", debugName: "Enter"), logicalKey: LogicalKeyboardKey#2604c(keyId: "0x10000000d", keyLabel: "Enter", debugName: "Enter"), character: "", timeStamp: 312:12:25.359871)
  /// KeyUpEvent#4bf94(physicalKey: PhysicalKeyboardKey#e14a9(usbHidUsage: "0x00070028", debugName: "Enter"), logicalKey: LogicalKeyboardKey#2604c(keyId: "0x10000000d", keyLabel: "Enter", debugName: "Enter"), character: null, timeStamp: 312:12:25.574965)
  /// ```
  ///
  ///
  /// -[pointerListener] 手势/鼠标事件监听
  /// -[keyboardListener] 键盘事件监听
  ///
  /// - [KeyboardListener]
  Widget keyboardListener(
    ValueChanged<KeyEvent>? onKeyEvent, {
    //--
    Key? key,
    FocusNode? focusNode,
    bool autofocus = true,
  }) {
    if (onKeyEvent == null) {
      return this;
    }
    focusNode ??= FocusNode();
    return KeyboardListener(
      key: key,
      onKeyEvent: (event) {
        if (autofocus) {
          focusNode?.unfocus();
        }
        onKeyEvent.call(event);
      },
      focusNode: focusNode,
      autofocus: autofocus,
      child: this,
    );
  }

  /// 在桌面平台监听[LogicalKeyboardKey.escape]按键自动关闭窗口
  /// - [onlyDesktop] 是否只在桌面平台下监听, 否则全部监听
  ///
  /// - [Shortcuts] 也可以通过此小部件实现
  Widget autoCloseDialog(
    BuildContext? context, {
    bool onlyDesktop = true,
    KeyEventResult otherKeyEventResult = KeyEventResult.ignored,
    Key? key,
    //--
    dynamic result,
    //--
    bool autofocus = true,
    //--
    bool enable = true,
  }) => !enable
      ? this
      : focusScope(
          enable: onlyDesktop ? isDesktopOrWeb : true,
          autofocus: autofocus,
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (event.isKeyUp) {
                context?.maybePop(result);
                return KeyEventResult.handled;
              }
            }
            //如果处理了所有的键盘事件, 此时child内部有输入框, 则可以会拦截键盘事件.
            return otherKeyEventResult;
          },
        );

  /// -[pointerListener] 手势/鼠标事件监听
  /// -[keyboardListener] 键盘事件监听
  ///
  /// - [PointerListenerWidget]
  /// - [Listener]
  Widget pointerListener(
    PointerEventListener? onPointer, {
    HitTestBehavior behavior = HitTestBehavior.deferToChild,
  }) => PointerListenerWidget(
    onPointer: onPointer,
    behavior: behavior,
    child: this,
  );

  /// [CustomPaint]
  /// [paint] 背景绘制
  /// [foregroundPaint] 前景绘制
  /// [isComplex] 是否是复杂的
  /// [willChange] 是否会在下一帧改变
  CustomPaint paint(
    PaintFn paint, {
    PaintFn? foregroundPaint,
    Size size = Size.zero,
    bool isComplex = false,
    bool willChange = false,
  }) => CustomPaint(
    painter: CustomPaintWrap(paint),
    foregroundPainter: foregroundPaint == null
        ? null
        : CustomPaintWrap(foregroundPaint),
    size: size,
    isComplex: isComplex,
    willChange: willChange,
    child: this,
  );

  /// 监听一个通知
  ///
  /// - [onNotification] 通知回调, 返回true表示消费通知, 否则继续冒泡
  ///
  /// [ContextEx.postNotification]
  /// [Notification]
  Widget listenerNotification<T extends Notification>(
    NotificationListenerCallback<T> onNotification, {
    Key? key,
  }) => NotificationListener<T>(
    key: key,
    onNotification: onNotification,
    child: this,
  );

  /// 为[child]小部件提供一个数据
  Widget dataProvider([Object? data]) =>
      DataProviderScope(data: data, child: this);

  /// 当child的大小发生改变时, 自动触发动画
  Widget animatedSize({
    Key? key,
    AlignmentGeometry alignment = Alignment.bottomCenter,
    Curve curve = Curves.linear,
    Duration? duration = kDefaultAnimationDuration,
    Duration? reverseDuration,
    Clip clipBehavior = Clip.hardEdge,
    VoidCallback? onEnd,
  }) => duration == null
      ? this
      : AnimatedSize(
          key: key,
          alignment: alignment,
          curve: curve,
          duration: duration,
          reverseDuration: reverseDuration,
          clipBehavior: clipBehavior,
          onEnd: onEnd,
          child: this,
        );

  /// [AnimatedBuilder]
  Widget animatedBuilder(Listenable? animation, [TransitionBuilder? builder]) =>
      animation == null
      ? this
      : AnimatedBuilder(
          animation: animation,
          builder:
              builder ??
              (context, child) {
                return child ?? this;
              },
          child: this,
        );

  //region ---Padding---

  /// 将当前的小部件, 包裹在一个[Padding]中
  /// [EdgeInsets]
  /// [EdgeInsetsGeometry]
  Widget paddingInsets(EdgeInsetsGeometry? insets) {
    return insets == null || insets == EdgeInsets.zero
        ? this
        : Padding(padding: insets, child: this);
  }

  /// 将当前的小部件, 包裹在一个[Padding]中
  /// 根据html的padding属性, 生成padding
  @Deprecated("请使用[paddingOnly]")
  Widget padding([double? v1, double? v2, double? v3, double? v4]) {
    final insets = edgeInsets(v1, v2, v3, v4);
    return paddingInsets(insets);
  }

  @Deprecated("请使用[paddingOnly]")
  Widget paddingCss([double? v1, double? v2, double? v3, double? v4]) =>
      padding(v1, v2, v3, v4);

  /// 将当前的小部件, 包裹在一个[Padding]中
  @Deprecated("请使用[paddingOnly]")
  Widget paddingAll(double value) => paddingInsets(EdgeInsets.all(value));

  @Deprecated("请使用[paddingOnly]")
  Widget paddingLTRB(double left, double top, double right, double bottom) =>
      paddingInsets(EdgeInsets.fromLTRB(left, top, right, bottom));

  /// 对称
  /// [paddingSymmetric]
  @Deprecated("请使用[paddingOnly]")
  Widget paddingItem({double vertical = kXh / 2, double horizontal = kXh}) {
    return paddingSymmetric(vertical: vertical, horizontal: horizontal);
  }

  /// 对称, 左右大一点, 上下小一点
  @Deprecated("请使用[paddingOnly]")
  Widget paddingSym({
    double? vertical,
    double? horizontal,
    double left = kX,
    double top = kH,
    double right = kX,
    double bottom = kH,
  }) => paddingOnly(
    left: horizontal ?? left,
    top: vertical ?? top,
    right: horizontal ?? right,
    bottom: vertical ?? bottom,
  );

  /// 对称, 左右上下一样大
  @Deprecated("请使用[paddingOnly]")
  Widget paddingSymmetric({
    double? vertical,
    double? horizontal,
    double left = kX,
    double top = kX,
    double right = kX,
    double bottom = kX,
  }) => paddingOnly(
    left: horizontal ?? left,
    top: vertical ?? top,
    right: horizontal ?? right,
    bottom: vertical ?? bottom,
  );

  /// [edgeInsets]
  /// [edgeOnly]
  /// [insets]
  ///
  /// [paddingOnly]
  /// [paddingInsets]
  Widget insets({
    //全部设置
    double? all,
    //水平垂直设置
    double? vertical,
    double? horizontal,
    //除了此方向, 其它都设置
    double? nLeft,
    double? nTop,
    double? nRight,
    double? nBottom,
    //单独设置
    double? left,
    double? top,
    double? right,
    double? bottom,
    //替换设置
    EdgeInsetsGeometry? insets,
  }) => paddingInsets(
    insets ??
        EdgeInsets.only(
          left: left ?? nTop ?? nRight ?? nBottom ?? horizontal ?? all ?? 0,
          top: top ?? nLeft ?? nRight ?? nBottom ?? vertical ?? all ?? 0,
          right: right ?? nLeft ?? nTop ?? nBottom ?? horizontal ?? all ?? 0,
          bottom: bottom ?? nLeft ?? nTop ?? nRight ?? vertical ?? all ?? 0,
        ),
  );

  /// [insets]
  /// [paddingOnly]
  /// [paddingInsets]
  @Alias("insets")
  Widget paddingOnly({
    //全部设置
    double? all,
    //水平垂直设置
    double? vertical,
    double? horizontal,
    //除了此方向, 其它都设置
    double? nLeft,
    double? nTop,
    double? nRight,
    double? nBottom,
    //单独设置
    double? left,
    double? top,
    double? right,
    double? bottom,
    //替换设置
    EdgeInsetsGeometry? insets,
  }) => this.insets(
    all: all,
    vertical: vertical,
    horizontal: horizontal,
    nLeft: nLeft,
    nTop: nTop,
    nRight: nRight,
    nBottom: nBottom,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    insets: insets,
  );

  /*Widget paddingFromWindowPadding() {
    return Padding(
      padding: EdgeInsets.fromWindowPadding(WidgetsBinding.instance!.window.viewInsets, WidgetsBinding.instance!.window.devicePixelRatio),
      child: this,
    );
  }*/

  //endregion ---Padding---

  //region ---Flexible---

  /// 占满剩余空间的多少比例, 弹性系数
  /// [Flex]
  ///  - [Row]
  ///  - [Column]
  /// [Flexible]
  ///  - [Expanded]
  /// [Spacer] 空白占位 `const SizedBox.shrink()`
  Widget expanded({
    int flex = 1,
    FlexFit fit = FlexFit.tight,
    bool enable = true,
  }) {
    if (!enable) {
      return this;
    }
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// 对齐
  /// [Align]
  /// [Center]
  /// [Alignment.center]
  /// [AlignmentDirectional.center]
  Widget align(
    AlignmentGeometry alignment, {
    double? widthFactor,
    double? heightFactor,
    //--
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
  }) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    ).constrainedMin(
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// 居中对齐
  /// [Align]
  /// [Center]
  Widget center({double? widthFactor, double? heightFactor}) {
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  /// 用来决定在[Stack]中的位置
  /// [Positioned].[ParentDataWidget]
  /// [PositionedDirectional]
  /// [AnimatedPositioned]
  Widget position({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    //--
    bool? alignLeft,
    bool? alignTop,
    bool? alignRight,
    bool? alignBottom,
    bool? match = true,
  }) {
    if (alignLeft == true) {
      left ??= 0;
      if (match == true) {
        top ??= 0;
        bottom ??= 0;
      }
    }
    if (alignTop == true) {
      top ??= 0;
      if (match == true) {
        left ??= 0;
        right ??= 0;
      }
    }
    if (alignRight == true) {
      right ??= 0;
      if (match == true) {
        top ??= 0;
        bottom ??= 0;
      }
    }
    if (alignBottom == true) {
      bottom ??= 0;
      if (match == true) {
        left ??= 0;
        right ??= 0;
      }
    }
    return Positioned(
      left: all ?? left,
      top: all ?? top,
      right: all ?? right,
      bottom: all ?? bottom,
      width: width,
      height: height,
      child: this,
    );
  }

  /// 旋转元素, 无动画
  /// [radians] 旋转角度, 顺时针为正, 弧度单位
  /// [RotateAnimation] 旋转动画
  /// [RotationTransition] 旋转变换
  Widget rotate(
    double radians, {
    AlignmentGeometry alignment = Alignment.center,
    Offset? origin,
    bool transformHitTests = true,
  }) {
    return Transform.rotate(
      alignment: alignment,
      angle: radians,
      origin: origin,
      transformHitTests: transformHitTests,
      child: this,
    );
  }

  //endregion ---Flexible---

  //region ---SafeArea---

  /// 离屏渲染
  /// - 没有大小
  /// - 不触发绘制
  ///
  /// - [invisible]
  /// - [offstage]
  Widget offstage([bool offstage = true, bool always = false]) =>
      (offstage || always) ? Offstage(offstage: offstage, child: this) : this;

  /// 脚手架, 会消耗手势事件
  /// 脚手架并不会处理[SafeArea]区域的内容.
  Widget scaffold({
    bool enable = true,
    BuildContext? context,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
    //--
    PreferredSizeWidget? appBar,
    bool? useSliverAppBar,
    Widget? title,
    Color? foregroundColor,
    double? elevation,
    bool? centerTitle,
    bool? automaticallyImplyLeading,
    Widget? leading,
    Widget? trailing,
    PreferredSizeWidget? bottom,
    List<Widget>? actions,
    //--
  }) {
    if (!enable) {
      return this;
    }
    if (context == null) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor ?? Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: this,
      );
    }
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    return Scaffold(
      appBar:
          appBar ??
          globalConfig.appBarBuilder(
            context,
            this,
            useSliverAppBar: useSliverAppBar,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            title: title,
            centerTitle: centerTitle,
            actions: actions,
            bottom: bottom,
            elevation: elevation,
            scrolledUnderElevation: elevation,
            foregroundColor:
                foregroundColor ?? globalTheme.appBarForegroundColor,
            backgroundColor:
                backgroundColor ?? globalTheme.appBarBackgroundColor,
            //阴影高度
            shadowColor: globalTheme.appBarShadowColor,
            flexibleSpace: null, //渐变背景
          ),
      backgroundColor: backgroundColor ?? globalTheme.surfaceBgColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: this,
    );
  }

  /// 移除MediaQuery的padding
  Widget removePadding(
    BuildContext context, {
    bool removeAll = false,
    bool removeTop = false,
    bool removeBottom = false,
    bool removeLeft = false,
    bool removeRight = false,
  }) {
    final mediaData = MediaQuery.of(context).removePadding(
      removeLeft: removeAll || removeLeft,
      removeTop: removeAll || removeTop,
      removeRight: removeAll || removeRight,
      removeBottom: removeAll || removeBottom,
    );
    return MediaQuery(data: mediaData, child: this);
  }

  /// 将当前的小部件, 包裹在一个[SafeArea]中
  /// [safeBottomArea] 底部安全区域
  Widget safeArea({
    bool useSafeArea = true,
    bool useSliverSafeArea = false,
    bool left = true,
    bool top = true,
    bool right = true,
    bool? bottom,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) {
    return useSafeArea
        ? (useSliverSafeArea
              ? SliverSafeArea(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom ?? maintainBottomViewPadding,
                  minimum: minimum,
                  sliver: this,
                )
              : SafeArea(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom ?? maintainBottomViewPadding,
                  minimum: minimum,
                  maintainBottomViewPadding: maintainBottomViewPadding,
                  child: this,
                ))
        : this;
  }

  /// 底部安全区域
  /// [safeArea]
  Widget safeBottomArea({
    bool useSafeArea = true,
    bool useSliverSafeArea = false,
    bool left = false,
    bool top = false,
    bool right = false,
    bool? bottom,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = true,
  }) {
    return useSafeArea
        ? (useSliverSafeArea
              ? SliverSafeArea(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom ?? maintainBottomViewPadding,
                  minimum: minimum,
                  sliver: this,
                )
              : SafeArea(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom ?? maintainBottomViewPadding,
                  minimum: minimum,
                  maintainBottomViewPadding: maintainBottomViewPadding,
                  child: this,
                ))
        : this;
  }

  /// 状态栏亮色模式
  /// 背景白色, 状态栏图标/文本为黑色
  Widget lightStatusBar() => systemUiOverlay(
    style: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  /// 状态栏暗色模式
  /// 背景黑色, 状态栏图标/文本为白色
  Widget darkStatusBar() => systemUiOverlay(
    style: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  /// 系统ui覆盖
  /// 状态栏/导航栏样式覆盖, 支持自动恢复
  /// [SystemUiOverlayStyle.dark]
  /// [SystemUiOverlayStyle.light]
  ///
  /// ```
  /// .systemUiOverlay(statusBarColor: Colors.redAccent) //设置状态栏的颜色
  /// ```
  Widget systemUiOverlay({
    BuildContext? context,
    SystemUiOverlayStyle? style,
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    bool? systemStatusBarContrastEnforced,
    Color? systemNavigationBarColor,
    Color? systemNavigationBarDividerColor,
    Brightness? systemNavigationBarIconBrightness,
    bool? systemNavigationBarContrastEnforced,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          style ??
          SystemUiOverlayStyle(
            systemNavigationBarColor:
                systemNavigationBarColor ??
                globalTheme.systemNavigationBarColor,
            systemNavigationBarDividerColor: systemNavigationBarDividerColor,
            systemNavigationBarIconBrightness:
                systemNavigationBarIconBrightness,
            systemNavigationBarContrastEnforced:
                systemNavigationBarContrastEnforced,
            statusBarColor: statusBarColor ?? globalTheme.systemStatusBarColor,
            statusBarBrightness: statusBarBrightness,
            statusBarIconBrightness: statusBarIconBrightness,
            systemStatusBarContrastEnforced: systemStatusBarContrastEnforced,
          ),
      child: this,
    );
  }

  //endregion ---SafeArea---

  //region ---Single Widget---

  /// 禁用当前的小部件
  Widget disable(
    bool disable, {
    //--
    ColorFilter? colorFilter,
    Color? color = Colors.grey,
    //--
    MouseCursor cursor = SystemMouseCursors.forbidden,
  }) {
    if (disable) {
      return ignorePointer()
          .colorFiltered(colorFilter: colorFilter, color: color)
          .mouse(cursor: cursor);
    } else {
      return this;
    }
  }

  /// 忽略小部件内的所有手势
  /// [IgnorePointer]
  Widget ignorePointer([bool ignoring = true]) {
    return IgnorePointer(ignoring: ignoring, child: this);
  }

  /// 忽略小部件内的所有手势
  /// [IgnoreSelfPointer]
  Widget ignoreSelfPointer({
    IgnorePointerType? ignoreType = IgnorePointerType.self,
  }) {
    return ignoreType == null
        ? this
        : IgnoreSelfPointer(ignoreType: ignoreType, child: this);
  }

  /// 支持监听动画改变
  /// [IgnoreSelfPointer]
  Widget ignoreSelfPointerListener({
    IgnorePointerType? ignoreType = IgnorePointerType.self,
  }) {
    return ignoreType == null
        ? this
        : IgnoreSelfPointerListener(this, ignoreType: ignoreType);
  }

  /// 消耗小部件内的所有手势
  Widget absorbPointer({bool absorbing = true}) {
    return AbsorbPointer(absorbing: absorbing, child: this);
  }

  /// 圆角
  /// [ClipRect]
  /// [ClipOval]
  /// [ClipRRect]
  /// [ClipPath]
  Widget clip({
    BorderRadiusGeometry? borderRadius,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return borderRadius == null
        ? this
        : ClipRRect(
            borderRadius: borderRadius,
            clipper: clipper,
            clipBehavior: clipBehavior,
            child: this,
          );
  }

  /// 圆角
  /// [topRadius] 如果配置了, 则只有顶部有圆角
  /// [bottomRadius] 如果配置了, 则只有底部有圆角
  ///
  /// [clipRadius]无效果的时候, 可能需要在包裹一层[material]
  Widget clipRadius({
    bool enable = true,
    double? radius = kDefaultBorderRadiusXX,
    double? topRadius,
    double? bottomRadius,
    BorderRadiusGeometry? borderRadius,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    if (!enable) {
      return this;
    }
    BorderRadiusGeometry? borderRadiusGeometry;
    if (borderRadius != null) {
      borderRadiusGeometry = borderRadius;
    } else if (topRadius != null || bottomRadius != null) {
      borderRadiusGeometry = BorderRadius.only(
        topLeft: Radius.circular(topRadius ?? 0),
        topRight: Radius.circular(topRadius ?? 0),
        bottomLeft: Radius.circular(bottomRadius ?? 0),
        bottomRight: Radius.circular(bottomRadius ?? 0),
      );
    } else if (radius != null) {
      borderRadiusGeometry = BorderRadius.circular(radius);
    }
    if (borderRadiusGeometry == null) {
      return this;
    }
    return clip(
      borderRadius: borderRadiusGeometry,
      clipper: clipper,
      clipBehavior: clipBehavior,
    );
  }

  /// 椭圆形
  Widget clipOval({
    CustomClipper<Rect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return ClipOval(clipper: clipper, clipBehavior: clipBehavior, child: this);
  }

  /// 圆角
  Widget radiusAll(double radius) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  }

  /// 添加一个高度阴影
  /// [PhysicalModel]
  /// [kBoxShadow]
  Widget elevation(double elevation, {Color? color, Color? shadowColor}) {
    return PhysicalModel(
      color: color ?? Colors.transparent,
      shadowColor: shadowColor ?? Colors.black12,
      elevation: elevation,
      child: this,
    );
  }

  /// 使用一个容器包裹当前的小部件
  /// [Container]
  /// [AnimatedSize] 动画容器
  /// [AnimatedContainer] 动画容器
  /// [AnimatedCrossFade] 交叉淡入淡出动画容器
  ///
  /// [color] 背景颜色
  /// [borderColor] 边框颜色, 如果有
  /// [borderWidth] 边框宽度
  /// [radius] 圆角, 决定[BorderRadius]
  /// [borderRadius] 圆角, 决定[decoration]
  /// [decoration] 背景装饰
  /// [shadowBlurRadius] 阴影模糊半径, 同时决定是否启用阴影 推荐值[kDefaultBlurRadius]
  /// [shadowColor] 阴影颜色
  /// [shadowSpreadRadius] 阴影扩散半径
  /// [decorationImage] 背景装饰图片
  /// [fillDecoration]
  Widget container({
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? radius,
    BorderRadius? borderRadius,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    double? width,
    double? height,
    double? minWidth,
    double? minHeight,
    Color? borderColor,
    double borderWidth = 1,
    BoxShape shape = BoxShape.rectangle,
    double? shadowBlurRadius,
    Color? shadowColor,
    double shadowSpreadRadius = 1,
    DecorationImage? decorationImage,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
    Key? key,
  }) {
    borderRadius ??= radius == null ? null : BorderRadius.circular(radius);
    decoration ??= borderRadius == null
        ? null
        : BoxDecoration(
            borderRadius: borderRadius,
            color: color,
            shape: shape,
            gradient: gradient,
            boxShadow:
                boxShadow ??
                (shadowBlurRadius == null
                    ? null
                    : [
                        BoxShadow(
                          color: shadowColor ?? Colors.grey.withOpacity(0.1),
                          offset: const Offset(2, 2), //阴影y轴偏移量
                          blurRadius: shadowBlurRadius, //阴影模糊程度
                          spreadRadius: shadowSpreadRadius, //阴影扩散程度
                        ),
                      ]),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor, width: borderWidth),
            image: decorationImage,
          );
    if (constraints == null) {
      if (minWidth != null || minHeight != null) {
        constraints = BoxConstraints(
          minWidth: minWidth ?? 0,
          minHeight: minHeight ?? 0,
        );
        //需要清空width/height
        width = null;
        height = null;
      }
    }
    return Container(
      key: key,
      alignment: alignment,
      padding: padding,
      color: decoration == null ? color : null,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      width: width,
      height: height,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  ///[Transform]
  ///[PaintingContext.pushTransform]
  ///[TransformLayer]
  Widget matrix(
    Matrix4 transform, {
    Offset? origin,
    AlignmentGeometry? alignment = Alignment.center,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) => this.transform(
    transform,
    origin: origin,
    alignment: alignment,
    transformHitTests: transformHitTests,
    filterQuality: filterQuality,
  );

  /// 应用一个变换[Matrix4].[Transform]
  Widget transform(
    Matrix4 transform, {
    Offset? origin,
    AlignmentGeometry? alignment = Alignment.center,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) => Transform(
    transform: transform,
    origin: origin,
    alignment: alignment,
    transformHitTests: transformHitTests,
    filterQuality: filterQuality,
    child: this,
  );

  /// [Card]
  /// [color] 卡片的颜色
  /// [elevation] 阴影的高度, 默认1.0
  /// [CardTheme]
  /// [ThemeData.cardTheme]
  Widget card({
    @defInjectMark Color? color,
    @defInjectMark Color? shadowColor,
    Color? surfaceTintColor,
    @defInjectMark double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    Clip? clipBehavior = Clip.antiAlias,
    bool borderOnForeground = true,
  }) => Card(
    color: color,
    shadowColor: shadowColor,
    surfaceTintColor: surfaceTintColor,
    elevation: elevation,
    shape: shape,
    borderOnForeground: borderOnForeground,
    margin: margin,
    clipBehavior: clipBehavior,
    child: this,
  );

  /// 圆形阴影包裹
  /// [shadowColor] 阴影颜色
  /// [shadowBlurRadius] 阴影模糊半径
  /// [shadowOffset] 阴影偏移
  /// [shadowSpreadRadius] 阴影扩散半径
  /// [decorationColor] 背景颜色
  ///
  /// [shadowCircle]
  /// [shadowRadius]
  /// [shadowDecorated]
  Widget shadowCircle({
    Color shadowColor = kShadowColor,
    Offset shadowOffset = Offset.zero,
    double shadowBlurRadius = kDefaultBlurRadius,
    double shadowSpreadRadius = kS,
    bool clipContent = true,
    Color? decorationColor = Colors.white,
    Color? color,
    AlignmentGeometry? alignment = Alignment.center,
    EdgeInsetsGeometry? padding,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    double? width,
    double? height,
  }) {
    return (clipContent ? clipOval() : this).container(
      alignment: alignment,
      padding: padding,
      color: color,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      width: width,
      height: height,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: decorationColor,
        boxShadow: [
          BoxShadow(
            offset: shadowOffset,
            color: shadowColor,
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
          ),
        ],
      ),
    );
  }

  /// 圆角矩形阴影包裹
  /// [radius] 圆角
  /// [clipContent] 是否裁剪内容
  /// [decorationColor] 装饰的颜色, 通常是背景的颜色
  ///
  /// [shadowCircle]
  /// [shadowRadius]
  /// [shadowDecorated]
  Widget shadowRadius({
    bool clipContent = true,
    Color? decorationColor = Colors.white,
    Color shadowColor = kShadowColor,
    Offset shadowOffset = Offset.zero,
    double blurRadius = kDefaultBlurRadius,
    double? radius = kDefaultBorderRadiusXXX,
    BorderRadiusGeometry? borderRadius,
    Color? color,
    AlignmentGeometry? alignment = Alignment.center,
    EdgeInsetsGeometry? padding,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    double? width,
    double? height,
  }) {
    borderRadius ??= BorderRadius.all(Radius.circular(radius ?? 0));
    return (clipContent ? clip(borderRadius: borderRadius) : this).container(
      alignment: alignment,
      padding: padding,
      color: color,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      width: width,
      height: height,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
        color: decorationColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: shadowOffset,
            blurRadius: blurRadius,
          ),
        ],
      ),
    );
  }

  /// 装饰[DecoratedBox]
  Widget decoration(Decoration? decoration) {
    if (decoration == null) {
      return this;
    }
    return DecoratedBox(decoration: decoration, child: this);
  }

  /// 阴影装饰
  /// [radius] 圆角半径
  /// [decorationColor] 装饰的颜色, 通常是背景的颜色
  ///
  /// [BoxDecoration]
  /// [shadowCircle]
  /// [shadowRadius]
  /// [shadowDecorated]
  Widget shadowDecorated({
    Offset shadowOffset = Offset.zero,
    Color? shadowColor = kShadowColor,
    double? radius = kDefaultBorderRadiusXXX,
    double shadowBlurRadius = kDefaultBlurRadius,
    double shadowSpreadRadius = kS,
    //--
    List<BoxShadow>? boxShadow,
    //--
    BoxShape shape = BoxShape.rectangle,
    BorderRadiusGeometry? borderRadius,
    Color? decorationColor = Colors.white,
  }) {
    if (shadowColor == null) {
      return this;
    }
    borderRadius ??= BorderRadius.all(Radius.circular(radius ?? 0));
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: borderRadius,
        color: decorationColor,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: shadowColor,
                offset: shadowOffset,
                blurRadius: shadowBlurRadius,
                spreadRadius: shadowSpreadRadius,
              ),
            ],
      ),
      child: this,
    );
  }

  /// 模糊背景
  /// [ColorFiltered]
  /// 将所有绘制放在一个模糊的[Layer]上, 以实现模糊的效果
  /// [BackdropFilterLayer]
  /// [BackdropFilterLayer.blendMode]
  /// [PaintingContext.pushLayer]
  Widget blur({
    double? sigma = kM,
    UiImageFilter? filter,
    BlendMode blendMode = BlendMode.srcOver,
    bool enable = true,
  }) => enable && ((sigma ?? 0) > 0 || filter != null)
      ? BackdropFilter(
          filter:
              filter ??
              ui.ImageFilter.blur(
                sigmaX: sigma!,
                sigmaY: sigma,
                tileMode: TileMode.clamp,
              ),
          blendMode: blendMode,
          child: this,
        )
      : this;

  /// 着色, 可以实现线性着色效果, 高光效果, 微光效果.
  /// [ShaderMask]->[ShaderMaskLayer]
  /// [ColorFiltered]
  /// - [BlendMode.modulate] 颜色分量相乘
  /// - [BlendMode.srcATop] 源图在目标图上
  /// https://pub.dev/packages/shimmer
  Widget shaderMask(
    ui.Shader? shader, {
    ShaderCallback? shaderCallback,
    BlendMode blendMode = BlendMode.srcATop,
  }) => (shader == null && shaderCallback == null)
      ? this
      : ShaderMask(
          shaderCallback:
              shaderCallback ??
              (Rect bounds) {
                return shader!;
                /*return RadialGradient(
            center: Alignment.topLeft,
            radius: 1.0,
            colors: <Color>[Colors.yellow, Colors.deepOrange.shade900],
            tileMode: TileMode.mirror,
          ).createShader(bounds);*/
              },
          blendMode: blendMode,
          child: this,
        );

  /// 可以实现灰度效果,灰度化app
  /// [ColorFiltered]
  /// 将所有绘制放在一个颜色过滤的[Layer]上, 以实现颜色过滤的效果
  /// [ColorFilterLayer]
  /// [ColorFilterLayer.colorFilter]
  /// [PaintingContext.pushLayer]
  /// [ShaderMask]
  /// [shaderMask]
  Widget colorFiltered({
    ColorFilter? colorFilter,
    Color? color = Colors.grey,
    BlendMode blendMode = BlendMode.srcIn,
    bool enable = true,
  }) => (!enable || (colorFilter == null && color == null))
      ? this
      : ColorFiltered(
          colorFilter: colorFilter ?? ColorFilter.mode(color!, blendMode),
          child: this,
        );

  /// 在暗色模式下才会过滤颜色
  Widget darkColorFiltered({
    BuildContext? context,
    ColorFilter? darkColorFilter,
    Color? darkColor,
    BlendMode blendMode = BlendMode.srcIn,
    bool enable = true,
  }) => colorFiltered(
    colorFilter: darkColorFilter,
    color: (context ?? GlobalConfig.def.globalContext)?.isThemeDark == true
        ? (darkColor ?? GlobalTheme.of(context).icoNormalColor)
        : null,
    blendMode: blendMode,
    enable: enable,
  );

  /// 绘制边界
  /// https://docs.flutter.dev/tools/devtools/inspector#highlight-repaints
  /// [WidgetListEx.repaintBoundary]
  /// [debugRepaintRainbowEnabled]
  Widget repaintBoundary({int? childIndex}) => childIndex == null
      ? RepaintBoundary(child: this)
      : RepaintBoundary.wrap(this, childIndex);

  /// 文本样式包裹
  /// [DefaultTextStyle]
  /// [AnimatedDefaultTextStyle]
  /// [textStyle]
  /// [wrapTextStyle]
  Widget wrapTextStyle({
    TextStyle? style,
    TextAlign? textAlign,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    ui.TextHeightBehavior? textHeightBehavior,
    bool animate = false,
  }) {
    style ??=
        GlobalConfig.def.themeData?.primaryTextTheme.bodyMedium ??
        GlobalConfig.def.globalTheme.textGeneralStyle;
    if (animate) {
      return AnimatedDefaultTextStyle(
        style: style,
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: overflow,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        duration: kDefaultAnimationDuration,
        child: this,
      );
    }
    return DefaultTextStyle(
      style: style,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      child: this,
    );
  }

  /// [DefaultTextStyle]
  /// [textStyle]
  /// [wrapTextStyle]
  Widget textStyle(TextStyle? style, {bool animate = false}) =>
      style == null ? this : wrapTextStyle(style: style, animate: animate);

  /// 拦截路由的弹出, 返回键.
  /// [PopScope]
  /// [WillPopScope.onWillPop]
  /// [popScope]
  /// `typedef WillPopCallback = Future<bool> Function();`
  Widget willPop([WillPopCallback? onWillPop]) {
    return WillPopScope(onWillPop: onWillPop ?? () async => false, child: this);
  }

  /// `typedef PopInvokedCallback = void Function(bool didPop);`
  /// [willPop]
  /// [canPop] 当前的路由是否可以弹出
  /// [onPopInvoked] 当路由想要弹出时调用: didPop=true 路由已经弹出; didPop=false 路由没有弹出.
  Widget popScope([
    bool canPop = false,
    PopInvokedCallback? onPopInvoked,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
  ]) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: onPopInvoked,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: this,
    );
  }

  /// 拦截[maybePop]操作
  Widget interceptPop([bool intercept = true]) {
    return intercept ? popScope(false, (didPop) {}) : this;
  }

  /// 拦截[maybePop]操作, 并实现自定义的操作
  /// 但是无法拦截[pop]操作
  /// 如果[action]中不执行任何操作, 则窗口无法被back按键关闭.
  /// 请在[action]中执行[pop]操作.才能关闭界面.
  /// [action] `navigatorOf(rootNavigator).pop(result);`
  /// [action] 返回false, 则自动[pop]操作. 此操作可能需要传入[context]参数
  Widget interceptPopResult(
    FutureOr Function() action, {
    BuildContext? context,
    dynamic result,
    bool enable = true,
  }) {
    return enable
        ? popScope(false, (didPop) async {
            //debugger();
            if (!didPop && !$isShowLoading) {
              final result = await action();
              if (result is bool && !result) {
                (context ?? GlobalConfig.def.globalContext)?.pop(result);
              }
            }
          })
        : this;
  }

  /// 当当前的路由[maybePop]时回调
  Widget onPop(Action action) {
    return popScope(true, (didPop) {
      if (didPop) {
        action();
      }
    });
  }

  /// 取消父组件对子组件的约束信息
  /// [UnconstrainedBox]
  Widget unconstrained({
    TextDirection? textDirection,
    AlignmentGeometry alignment = Alignment.center,
    Axis? constrainedAxis,
    Clip clipBehavior = Clip.none,
  }) {
    return UnconstrainedBox(
      textDirection: textDirection,
      alignment: alignment,
      constrainedAxis: constrainedAxis,
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  /// 约束当前小部件的大小
  /// [ConstrainedBox]
  /// [constrainedMin]
  /// [constrainedMax]
  Widget constrainedBox(BoxConstraints? constraints) {
    return constraints == null
        ? this
        : ConstrainedBox(constraints: constraints, child: this);
  }

  /// 约束大小
  /// [enableRatio] 是否激活百分比, 则小小于1的值会被当做比例处理
  /// [constrainedBox]
  Widget constrained({
    double? width,
    double? height,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
    bool enableRatio = true,
  }) {
    minWidth = width ?? minWidth;
    maxWidth = width ?? maxWidth;
    minHeight = height ?? minHeight;
    maxHeight = height ?? maxHeight;
    //--
    if (enableRatio) {
      if (minWidth > 0 && minWidth < 1) {
        minWidth = screenHeight * minWidth;
      }
      if (maxWidth > 0 && maxWidth < 1) {
        maxWidth = screenHeight * maxWidth;
      }
      if (minHeight > 0 && minHeight < 1) {
        minHeight = screenHeight * minHeight;
      }
      if (maxHeight > 0 && maxHeight < 1) {
        maxHeight = screenHeight * maxHeight;
      }
    }
    //--
    return constrainedBox(
      BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
    );
  }

  /// 固定大小约束
  /// [constrainedBox]
  Widget constrainedFixed(Size size) {
    return constrainedBox(BoxConstraints.tight(size));
  }

  /// 最小约束
  Widget min({
    double? minSize,
    double? minWidth = kInteractiveHeight,
    double? minHeight = kMinInteractiveHeight,
    EdgeInsetsGeometry? margin = const EdgeInsets.symmetric(
      horizontal: kX,
      vertical: kH,
    ),
    EdgeInsetsGeometry? padding,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return paddingInsets(margin)
        .align(alignment)
        .constrainedBox(
          BoxConstraints(
            minWidth: minSize ?? minWidth ?? 0,
            minHeight: minSize ?? minHeight ?? 0,
          ),
        )
        .paddingInsets(padding);
  }

  /// 最小宽高约束桌面端对话框布局
  /// - 限制显示的最小宽度/或者固定宽度
  /// - 限制显示的最大高度/或者固定高度
  ///
  /// - [fitDialog] 自动适配对话框中的样式
  /// - [fitDesktop] 自动适配桌面端
  ///
  /// - [fixedWidth] 是否固定宽度
  Widget desktopConstrained({
    //
    bool fitDialog = true,
    @defInjectMark bool? fitDesktop,
    @defInjectMark bool? fixedWidth,
    bool? fixedHeight,
    //
    double? minSize,
    double? minWidth,
    double? minHeight,
    //
    double? maxSize,
    double? maxWidth,
    double? maxHeight,
  }) {
    minWidth ??= minSize;
    minHeight ??= minSize;
    maxWidth ??= maxSize;
    maxHeight ??= maxSize;

    //--
    fitDesktop ??= isDesktopOrWeb;
    fixedWidth ??= fitDesktop;
    if (fitDialog) {
      //debugger();
      if (fitDesktop) {
        minWidth ??= minOf($screenMinSize, kDesktopDialogMinWidth);
        maxHeight ??= minOf(minWidth, $screenHeight * 3 / 4); //最大是正方向
        //maxHeight ??= $screenHeight;
      } else {
        minWidth ??= minOf($screenMinSize, kDialogMinWidth);
        maxHeight ??= $screenHeight; //最大是长方形
      }
    }

    //--
    if (fixedWidth == true) {
      maxWidth ??= minWidth;
    }
    if (fixedHeight == true) {
      minHeight ??= maxHeight;
      maxHeight ??= minHeight;
    }
    return constrainedMin(
      minSize: minSize,
      minWidth: minWidth,
      minHeight: minHeight,
      maxSize: maxSize,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// 约束最小宽高
  /// [constrainedBox]
  /// [ConstrainedBox]
  Widget constrainedMin({
    //
    double? minSize,
    double? minWidth,
    double? minHeight,
    //
    double? maxSize,
    double? maxWidth,
    double? maxHeight,
  }) {
    minWidth ??= minSize;
    minHeight ??= minSize;
    maxWidth ??= maxSize;
    maxHeight ??= maxSize;
    if (maxWidth == null &&
        maxHeight == null &&
        minWidth == null &&
        minHeight == null) {
      return this;
    }
    return constrainedBox(
      BoxConstraints(
        minWidth: minWidth ?? 0,
        minHeight: minHeight ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
    );
  }

  /// 约束最大宽高
  /// [constrainedBox]
  /// [ConstrainedBox]
  Widget constrainedMax({
    double? minWidth,
    double? minHeight,
    double? maxWidth = double.infinity,
    double? maxHeight = double.infinity,
  }) {
    if (maxWidth == null &&
        maxHeight == null &&
        minWidth == null &&
        minHeight == null) {
      return this;
    }
    return constrainedBox(
      BoxConstraints(
        minWidth: minWidth ?? 0.0,
        minHeight: minHeight ?? 0.0,
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
    );
  }

  /// 指定大小
  /// [SizedBox]
  Widget size({double? size, double? width, double? height}) =>
      box(size: size, width: width, height: height);

  /// 指定大小
  /// [SizedBox]
  Widget box({double? size, double? width, double? height}) {
    {
      width ??= size;
      height ??= size;
      if (width == null && height == null) {
        return this;
      }
      return SizedBox(width: width, height: height, child: this);
    }
  }

  /// [size]
  Widget wh([double? width, double? height]) {
    if (width == null && height == null) {
      return this;
    }
    return SizedBox(width: width, height: height, child: this);
  }

  /// 使用[child]固有的宽度, 在系统的[AlertDialog]中使用
  /// [IntrinsicWidth] 固有的宽度
  Widget iw({double? stepWidth, double? stepHeight}) =>
      IntrinsicWidth(stepWidth: stepWidth, stepHeight: stepHeight, child: this);

  /// 使用[child]固有的高度
  Widget ih([bool enable = true]) =>
      enable ? IntrinsicHeight(child: this) : this;

  /// [FittedBox]
  Widget fittedBox({
    BoxFit? fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Clip clipBehavior = Clip.none,
  }) {
    if (fit == null) {
      return this;
    }
    return FittedBox(
      fit: fit,
      alignment: alignment,
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  /// 首选大小
  /// [PreferredSizeWidget]
  /// [PreferredSize]
  /// [TabBar]
  PreferredSizeWidget sizePreferred({
    double? width,
    double? height = kTabHeight,
  }) {
    return PreferredSize(
      preferredSize: Size(width ?? double.infinity, height ?? double.infinity),
      child: this,
    );
  }

  /// 比例box [AspectRatio]
  /// 纵横比表示为宽度与高度的比率。例如，16:9宽高比的值为16.0/9.0。
  Widget ratio(double aspectRatio) =>
      AspectRatio(aspectRatio: aspectRatio, child: this);

  /// [Material]组件会影响[ModalRoute.barrierDismissible]属性
  /// 此组件在[OverlayEntry]中可能会影响手势传递.
  ///
  /// [color] 背景颜色
  /// [surfaceTintColor]
  ///
  Widget material({
    Key? key,
    ShapeBorder? shape,
    Color? color = Colors.transparent,
    Color? shadowColor,
    Color? surfaceTintColor,
    double elevation = 0,
    MaterialType type = MaterialType.canvas,
    Clip clipBehavior = Clip.none,
    BorderRadiusGeometry? borderRadius,
    double? radius,
    TextStyle? textStyle,
  }) => Material(
    key: key,
    borderOnForeground: true,
    color: color,
    shadowColor: shadowColor,
    elevation: elevation,
    type: type,
    surfaceTintColor: surfaceTintColor,
    clipBehavior: clipBehavior,
    borderRadius: borderRadius ?? radius?.toBorderRadius(),
    textStyle: textStyle,
    shape: shape,
    child: this,
  );

  /// 有大小, 有圆形波纹, 有提示
  /// [highlightColor] 按下时, 高亮的波纹颜色
  /// [visualDensity]
  ///  - VisualDensity(vertical: VisualDensity.minimumDensity, horizontal: VisualDensity.minimumDensity) 最小
  ///  - VisualDensity.compact 紧凑型
  ///  - VisualDensity.standard 标准
  Widget icon(
    GestureTapCallback? onTap, {
    bool enable = true,
    bool? enableFeedback,
    String? tooltip,
    Color? color,
    Color? disabledColor,
    Color? highlightColor,
    Color? splashColor,
    Color? hoverColor,
    Color? focusColor,
    double? iconSize /*系统默认 24*/,
    double? splashRadius,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding /*系统默认 const EdgeInsets.all(8.0)*/,
    VisualDensity? visualDensity,
    BoxConstraints? constraints,
    ButtonStyle? style,
    bool? isSelected,
    Widget? selectedIcon,
  }) {
    return IconButton(
      onPressed: enable ? onTap : null,
      icon: this,
      tooltip: tooltip,
      enableFeedback: enableFeedback,
      color: color,
      disabledColor: disabledColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      hoverColor: hoverColor,
      focusColor: focusColor,
      iconSize: iconSize,
      splashRadius: splashRadius,
      alignment: alignment,
      padding: padding,
      visualDensity:
          visualDensity ??
          (iconSize == null
              ? null
              : VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity,
                )),
      constraints:
          constraints ??
          (iconSize == null
              ? null
              : BoxConstraints.tightFor(width: iconSize, height: iconSize)),
      style: style,
      isSelected: isSelected,
      selectedIcon: selectedIcon,
    );
  }

  /// 默认块状波纹效果
  /// 支持圆角波纹效果, 有的时候可能需要包裹在[Material]部件中才有预期效果
  /// [radius] 背景/波纹圆角大小, 圆角足够大时, 可以实现圆形效果. [kDefaultBorderRadiusXXX]
  /// [shape] 形状, [BoxShape.circle]并不能实现圆形效果, 需要设置圆角[radius].
  /// [backgroundColor] 背景颜色, 此时波纹依旧有效. 用[container]的背景颜色则波纹效果无效.
  /// [highlightColor] 高亮的颜色, 波纹扩散结束之后可见的颜色
  /// [splashColor] 波纹颜色, 动画扩散时的颜色
  /// [decoration] 强行指定装饰
  ///
  /// [material]
  /// [inkWellCircle]
  Widget ink(
    GestureTapCallback? onTap, {
    bool enable = true,
    //--
    double radius = 0,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Decoration? decoration,
    //--
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? highlightColor /*按下高亮的颜色*/,
    Color? splashColor /*涟漪的颜色*/,
    GestureLongPressCallback? onLongPress,
  }) {
    if (!enable) {
      //禁用组件
      if (isDesktopOrWeb || mouseIsConnected) {
        return mouse(cursor: SystemMouseCursors.forbidden);
      }
      return this;
    }
    final isCircle = shape == BoxShape.circle;
    if (isCircle) {
      radius = Material.defaultSplashRadius;
    }
    final bRadius = borderRadius ?? BorderRadius.all(Radius.circular(radius));
    decoration ??= BoxDecoration(
      /*shape: shape,*/
      color: backgroundColor,
      borderRadius: bRadius,
    );
    return Ink(
      padding: padding,
      decoration: decoration,
      /*color: backgroundColor,*/
      width: width,
      height: height,
      child: inkWell(
        onTap,
        onLongPress: onLongPress,
        borderRadius: bRadius,
        radius: radius,
        customBorder: /*isCircle ? const CircleBorder() : */ null,
        /*highlightShape: shape,*/
        highlightColor: highlightColor,
        splashColor: splashColor,
      ),
    );
  }

  /// 默认块状波纹效果
  /// 使用涟漪动画包裹, 无法控制背景颜色, 波纹会超出范围. [ink]
  /// https://api.flutter.dev/flutter/material/InkWell-class.html
  /// - [splashColor] 涟漪颜色, 手势按住时的涟漪颜色, 不指定此颜色可能无效果[Colors.black12]
  /// - [highlightColor] 高亮颜色, 手势按下时的高亮颜色
  /// - [hoverColor] 鼠标悬停时的颜色
  /// - [onLongPressPeriodic] 周期性的长按回调事件
  ///
  /// - [disableColor] 是否要禁用所有颜色效果
  ///
  /// - [InkWell]
  /// - [InkResponse]
  /// - [CircleBorder]
  ///
  /// - [inkWellCircle]
  Widget inkWell(
    GestureTapCallback? onTap, {
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
    BoxShape highlightShape = BoxShape.rectangle,
    double? radius /*飞溅的半径*/,
    ShapeBorder? customBorder,
    GestureLongPressCallback? onLongPress,
    bool enable = true,
    //--
    bool disableColor = false,
    Color? hoverColor,
    //--
    Duration? periodicDuration,
    GestureLongPressCallback? onLongPressPeriodic,
  }) {
    if (!enable) {
      //禁用组件
      return this;
    }
    if (disableColor) {
      splashColor = Colors.transparent;
      highlightColor = Colors.transparent;
      hoverColor = Colors.transparent;
    }
    Timer? periodicTimer;
    Widget body = InkResponse(
      onTap: onTap,
      onLongPress: onLongPressPeriodic != null
          ? () {
              onLongPress?.call();
              periodicTimer = Timer.periodic(
                periodicDuration ?? Duration(milliseconds: 160),
                (timer) {
                  onLongPressPeriodic();
                },
              );
            }
          : onLongPress,
      onTapUp: onLongPressPeriodic != null
          ? (details) {
              periodicTimer?.cancel();
              periodicTimer = null;
            }
          : null,
      onTapCancel: onLongPressPeriodic != null
          ? () {
              periodicTimer?.cancel();
              periodicTimer = null;
            }
          : null,
      radius: radius,
      splashColor: splashColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      //overlayColor: MaterialStateProperty.all(Colors.blue),
      borderRadius: borderRadius,
      customBorder: customBorder,
      //边框裁剪
      highlightShape: highlightShape,
      containedInkWell: true,
      child: this,
    );
    if (onLongPressPeriodic != null) {
      body = body.listenerPointer(
        onPointerFinish: (event) {
          periodicTimer?.cancel();
          periodicTimer = null;
        },
      );
    }
    return body;
  }

  /// [enable] 是否启用
  /// [disableColor] 禁用时的颜色, 不指定不处理
  /// [splashColor] 涟漪颜色 不指定此颜色可能无效果[Colors.black12]
  ///
  /// [ink]
  /// [inkWell]
  /// [InkWell]
  ///
  /// [Material] 有些时候, 可能需要使用此部件包裹一下
  Widget inkWellCircle(
    GestureTapCallback? onTap, {
    Color? splashColor,
    Color? disableColor,
    Color? highlightColor,
    double? radius,
    bool enable = true,
    GestureLongPressCallback? onLongPress,
    //--
    Duration? periodicDuration,
    GestureLongPressCallback? onLongPressPeriodic,
  }) => !enable
      ? colorFiltered(color: disableColor)
      : inkWell(
          onTap,
          //borderRadius: BorderRadius.circular(999),
          customBorder: const CircleBorder(),
          splashColor: splashColor,
          highlightColor: highlightColor,
          highlightShape: BoxShape.rectangle,
          radius: radius,
          onLongPress: onLongPress,
          periodicDuration: periodicDuration,
          onLongPressPeriodic: onLongPressPeriodic,
        );

  /// 将[this]和[other] 使用[Column]包裹
  Widget columnOf(
    Widget? other, {
    Key? key,
    MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize? mainAxisSize, //MainAxisSize.min
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    double? gap,
    Widget? gapWidget,
  }) => other == null
      ? this
      : [this, other].column(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          gap: gap,
          gapWidget: gapWidget,
        )!;

  /// 将[this]和[other] 使用[Row]包裹
  Widget rowOf(
    Widget? other, {
    Key? key,
    MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize? mainAxisSize, //MainAxisSize.max
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    double? gap,
    Widget? gapWidget,
    //--
    bool lastExtend = false,
  }) => other == null
      ? this
      : [this, other].row(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          gap: gap,
          gapWidget: gapWidget,
          lastExtend: lastExtend,
        )!;

  /// 将[before].[this]和[after] 使用[Stack]包裹
  Widget stackOf(
    Widget? after, {
    Widget? before,
    //--
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.center,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) => after == null && before == null
      ? this
      : [before, this, after].stack(
          key: key,
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
          clipBehavior: clipBehavior,
        )!;

  /// 简单的滚动小组件[SingleChildScrollView]
  /// [WidgetListEx.scroll]
  /// [padding] 滚动小部件内边距
  /// [reverse] 是否反向滚动
  Widget scroll({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics = kScrollPhysics,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
  }) => SingleChildScrollView(
    key: key,
    scrollDirection: scrollDirection,
    physics: physics,
    controller: controller,
    padding: padding,
    primary: primary,
    reverse: reverse,
    child: this,
  );

  /// [ScrollOverlayHintWidget]
  /// [StretchingOverscrollIndicator]
  /// [GlowingOverscrollIndicator]
  @implementation
  Widget overscrollIndicator({
    Color color = Colors.redAccent,
    bool showLeading = true,
    bool showTrailing = true,
    AxisDirection axisDirection = AxisDirection.up,
  }) => GlowingOverscrollIndicator(
    showLeading: showLeading,
    showTrailing: showTrailing,
    axisDirection: axisDirection,
    color: color,
    child: this,
  );

  /// 控制当前的[Widget]可见性
  /// [AnimatedContainer]
  /// [AnimatedOpacity]
  Widget visible({required bool visible, bool anim = false}) {
    Widget result = Visibility(visible: visible, child: this);
    if (anim) {
      result = AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: kDefaultAnimationDuration,
        child: result,
      );
    }
    return result;
  }

  /// 使一个[Widget]不可见, 但是仍然占据空间, 并且忽略手势
  /// - [enable] 是否激活组件
  /// - [invisible] 是否可见, 默认不可见
  /// - [replacement] 不占空间时需要替换的小部件
  ///
  /// - [invisible]
  /// - [offstage]
  Widget invisible({
    bool enable = true,
    //--
    bool invisible = false,
    bool maintainSize = true,
    bool maintainState = true,
    bool maintainAnimation = true,
    bool maintainInteractivity = false,
    Widget replacement = const SizedBox.shrink(),
  }) {
    return enable
        ? Visibility(
            visible: !invisible,
            maintainSize: maintainSize,
            maintainState: maintainState,
            maintainAnimation: maintainAnimation,
            maintainInteractivity: maintainInteractivity,
            replacement: replacement,
            child: this,
          )
        : this;
  }

  //endregion ---Single Widget---

  //region ---Button Theme---

  //--theme---

  /// [ButtonStyle]
  /// [FilledButton]
  /// [FilledButtonTheme]
  Widget filledButtonTheme({
    ButtonStyle? style,
    FilledButtonThemeData? theme,
  }) => FilledButtonTheme(
    data: theme ?? FilledButtonThemeData(style: style),
    child: this,
  );

  /// [ElevatedButton]
  Widget elevatedButtonTheme({
    ButtonStyle? style,
    ElevatedButtonThemeData? theme,
  }) => ElevatedButtonTheme(
    data: theme ?? ElevatedButtonThemeData(style: style),
    child: this,
  );

  /// [OutlinedButton]
  Widget outlinedButtonTheme({
    ButtonStyle? style,
    OutlinedButtonThemeData? theme,
  }) => OutlinedButtonTheme(
    data: theme ?? OutlinedButtonThemeData(style: style),
    child: this,
  );

  /// [TextButton]
  Widget textButtonTheme({ButtonStyle? style, TextButtonThemeData? theme}) =>
      TextButtonTheme(
        data: theme ?? TextButtonThemeData(style: style),
        child: this,
      );

  //endregion ---Button Theme---

  /// 平板适配
  Widget adaptiveTablet([
    BuildContext? context,
    AlignmentGeometry alignment = Alignment.bottomCenter,
  ]) {
    //debugger();
    final globalConfig = GlobalConfig.of(context);
    if (globalConfig.isInTabletModel || isDesktopOrWeb) {
      //平板模式
      final globalTheme = GlobalTheme.of(context);
      return constrainedBox(
        globalTheme.tabletDialogConstraints,
      ).align(alignment);
      //return size(size: 200);
    }
    return this;
  }
}

/// [State]
extension StateEx on State {
  /// [dart.js.context]
  BuildContext? get buildContext => isMounted ? context : null;

  /// 元素是否还在树中
  bool get isMounted => context.mounted;

  /// 标记当前状态脏, 会在下一帧重建
  /// ```
  /// setState() or markNeedsBuild() called when widget tree was locked.
  /// ```
  /// [Element.markNeedsBuild]
  /// [ContextEx.tryUpdateState]
  bool updateState({bool post = false, String? debugLabel}) {
    try {
      if (isMounted) {
        assert(() {
          if (debugLabel != null) {
            l.i("请求更新界面:$debugLabel");
          }
          return true;
        }());
        if (post) {
          postFrame(() {
            setState(() {});
          });
        } else {
          postFrameCallbackIfNeed((_) {
            setState(() {});
          });
        }
        return true;
      }
      return false;
    } catch (e) {
      assert(() {
        l.w(
          '当前页面可能已被销毁, 无法更新! (渲染调度中[${SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks}])',
        );
        printError(e);
        return true;
      }());
      return false;
    }
  }
}

/// [ConditionalElementVisitor] 返回false 可以停止遍历
/// [depth] 从0开始的递归深度
typedef ConditionalElementVisitorDepth =
    bool Function(Element element, int depth, int childIndex);

/// [ConditionalRenderObjectVisitorDepth] 返回false 可以停止遍历
/// [depth] 从0开始的递归深度
typedef ConditionalRenderObjectVisitorDepth =
    bool Function(RenderObject renderObject, int depth, int childIndex);

/// [BuildContext.findRenderObject]
/// [RenderObject.showOnScreen]
extension ContextEx on BuildContext {
  /// 震动反馈
  void longPressFeedback() => Feedback.forLongPress(this);

  /// [BuildContext]
  BuildContext? get buildContext => isMounted ? this : null;

  /// 此上下文关联的Widget当前是否已安装在 Widget 树中
  bool get isMounted => mounted;

  /// 系统当前的亮度模式
  /// [Brightness]
  bool get isSystemDark =>
      platformMediaQueryData.platformBrightness == Brightness.dark;

  /// 系统当前的亮度模式
  /// [Brightness]
  bool get isSystemLight =>
      platformMediaQueryData.platformBrightness == Brightness.light;

  /// 当前主题是否是暗黑模式
  bool get isThemeDark {
    final theme = GlobalConfig.def.themeData ?? Theme.of(this);
    return theme.brightness == Brightness.dark;
  }

  /// 当前主题是否是亮色模式
  bool get isThemeLight {
    final theme = GlobalConfig.def.themeData ?? Theme.of(this);
    return theme.brightness == Brightness.light;
  }

  /// 系统当前的语言环境
  /// [platformLocale]
  /// [platformLocales]
  bool get isSystemZh {
    return platformLocale.isZh;
  }

  /// 当前主题是否是中文语言
  bool get isThemeZh {
    final locale = maybeLocale;
    return locale?.isZh == true;
  }

  /// 如果当前是暗色主题, 则返回[dark]否则返回[light]
  T? darkOr<T>([T? dark, T? light]) => isThemeDark ? dark : light;

  /// 中英文字符选择
  /// 如果是中文环境, 则返回中文字符串, 否则返回默认字符串
  /// 同时如果中文字符串为null, 则也返回默认字符串
  String? zhStrOrDef(String? zhStr, String? defStr) {
    return isThemeZh ? (zhStr ?? defStr) : defStr;
  }

  /// 根据中英环境自动选择数据
  T? zhOrDef<T>([T? zh, T? def]) {
    return isThemeZh ? (zh ?? def) : def;
  }

  /// 尝试更新状态, 如果可以
  /// [StateEx.updateState]
  void tryUpdateState() {
    final el = this;
    if (el is Element) {
      if (el.mounted) {
        el.markNeedsBuild();
      }
    }
  }

  /// 尝试重绘对象, 如果可以
  void tryUpdatePaint() {
    final el = this;
    if (el is Element) {
      if (el.mounted) {
        el.findRenderObject()?.markNeedsPaint();
      }
    }
  }

  /// 当前语言环境
  /// [Locale.languageCode] zh
  /// [Locale.countryCode] CN
  /// [Locale.scriptCode] Hans
  /// ```
  /// When an inherited widget changes, for example if the value of Theme.of() changes,
  /// its dependent widgets are rebuilt.
  /// If the dependent widget's reference to the inherited widget is in a constructor or an initState() method,
  /// then the rebuilt dependent widget will not reflect the changes in the inherited widget.
  /// ```
  Locale get locale => Localizations.localeOf(this);

  /// [locale]
  Locale? get maybeLocale => Localizations.maybeLocaleOf(this);

  /// 如果仅是想获取[MediaQueryData]而不想监听变化, 则使用此方法. 否则使用[MediaQuery.of]
  /// 通过[MediaQuery.of]方法获取到的[MediaQueryData]会通知监听变化
  /// [dependOnInheritedWidgetOfExactType]
  /// [getInheritedWidgetOfExactType]
  /// [platformMediaQueryData]
  /// [MediaQuery.of]
  MediaQueryData get mediaQueryData =>
      getInheritedWidgetOfExactType<MediaQuery>()!.data;

  /// 分发一个通知, 可以通过[NotificationListener]小部件接收通知
  /// [dispatchNotification]
  void postNotification(Notification notification) =>
      notification.dispatch(this);

  /// 清除焦点, 隐藏键盘
  void unfocus() {
    // 检查当前输入框的焦点
    final focusScope = FocusScope.of(this);
    if (focusScope.hasFocus) {
      focusScope.unfocus(); // 隐藏键盘
    }
  }

  /// 请求焦点, 传null, 可以弹出键盘. 如果界面上有输入框.
  /// [node] 指定需要获取焦点的节点
  void requestFocus([FocusNode? node]) {
    FocusScope.of(this).requestFocus(node);
  }

  /// 显示一个 [SnackBar]
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    SnackBar snackBar,
  ) {
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// 遍历所有的子元素[Element]
  /// [visitor] 返回值表示是否继续遍历; true: 继续深度遍历; false: 停止深度遍历;
  /// ```
  /// The BuildContext.visitChildElements() method can't be called during build because the child list is
  /// still being updated at that point, so the children might not be constructed yet, or might be old
  /// children that are going to be replaced.
  /// ```
  /// 此方法不能在build阶段调用
  /// [RenderObjectEx.eachVisitChildRenderObject]
  eachVisitChildElements(
    ConditionalElementVisitorDepth visitor, {
    int depth = 0,
  }) {
    if (owner == null || debugDoingBuild) {
      return;
    }
    int childIndex = 0;
    //此方法不能再build期间调用
    visitChildElements((element) {
      bool interrupt = !visitor(element, depth, childIndex++);
      if (!interrupt) {
        element.eachVisitChildElements(visitor, depth: depth + 1);
      }
    });
  }

  /// 从上往下查找, 查找到非系统的元素[Widget]
  /// 查找第一个非系统元素[Widget]的[Element]
  Element? findFirstNotSystemElement() {
    const systemWidgetList = [
      Actions,
      Align,
      AnimatedDefaultTextStyle,
      AspectRatio,
      AnimatedPhysicalModel,
      AnimatedBuilder,
      Builder,
      BoxConstraints,
      ButtonStyleButton,
      BottomSheet,
      Center,
      ColoredBox,
      ConstrainedBox,
      ClipPath,
      ClipRect,
      CustomPaint,
      CustomMultiChildLayout,
      Card,
      DualTransitionBuilder,
      DisplayFeatureSubScreen,
      DefaultTextStyle,
      DefaultSelectionStyle,
      ElevatedButton,
      FadeTransition,
      FractionalTranslation,
      IgnorePointer,
      IntrinsicWidth,
      IntrinsicHeight,
      Ink,
      InkWell,
      InkResponse,
      KeyedSubtree,
      ListenableBuilder,
      LimitedBox,
      LayoutId,
      Listener,
      Material,
      MediaQuery,
      NotificationListener,
      Offstage,
      OutlinedButton,
      PrimaryScrollController,
      PageStorage,
      Padding,
      Positioned,
      PhysicalModel,
      PhysicalShape,
      RepaintBoundary,
      RawMaterialButton,
      RotationTransition,
      RawGestureDetector,
      RichText,
      Scaffold,
      Semantics,
      SnapshotWidget,
      ScaleTransition,
      SlideTransition,
      SafeArea,
      Stack,
      Size,
      SizedBox,
      ScrollNotificationObserver,
      Transform,
      TextButton,
      Text,
      UnconstrainedBox,
    ];
    const prefixWidgetList = ["Notification"];
    Element? result;
    eachVisitChildElements((element, depth, childIndex) {
      final runtimeType = element.widget.runtimeType;
      //debugger();
      if ("$runtimeType".startsWith("_") ||
          systemWidgetList.contains(runtimeType) ||
          prefixWidgetList.findFirst((e) => "$runtimeType".startsWith(e)) !=
              null) {
        return true;
      }
      result = element;
      return false;
    });
    return result;
  }

  /// 通过指定的[Widget]类型查找对应的[Element]
  Element? findElementOfWidget<T extends Widget>() {
    Element? result;
    eachVisitChildElements((element, depth, childIndex) {
      if (element.widget is T) {
        result = element;
        return false;
      }
      return true;
    });
    return result;
  }

  /// 通过指定的[State]类型查找对应的[State]
  T? findState<T extends State>() {
    T? result;
    eachVisitChildElements((element, depth, childIndex) {
      if (element is StatefulElement && element.state is T) {
        result = element.state as T;
        return false;
      }
      return true;
    });
    return result;
  }

  //--

  /// [MediaQueryData]
  /// [EdgeInsets]
  EdgeInsets get mediaPadding => MediaQuery.paddingOf(this);
}

extension RenderObjectEx on RenderObject {
  /// 是否有[RenderBox]的[size]
  /// 一般在[RenderObject.layout]后, 才有大小
  bool get hasBoxSize => this is RenderBox && (this as RenderBox).hasSize;

  /// 获取[RenderObject]的大小
  Size? getSizeOrNull() {
    final box = this;
    if (box is RenderBox) {
      if (box.hasSize) {
        return box.size;
      } else {
        return box.getDryLayout(const BoxConstraints());
      }
    }
    return null;
  }

  /// 获取[RenderObject]的在父节点中的位置
  Offset? getOffsetInParentOrNull() {
    final parentData = this.parentData;
    if (parentData is BoxParentData) {
      return parentData.offset;
    }
    return null;
  }

  /// 获取[RenderObject]的在父节点中的位置
  Rect? getBoundsInParentOrNull() {
    final offset = getOffsetInParentOrNull();
    final size = getSizeOrNull();
    if (offset != null && size != null) {
      return offset & size;
    }
    return null;
  }

  /// 获取[RenderObject]的全局绘制位置和坐标大小
  /// [ancestor] 祖先节点, 如果为null, 则为根节点
  /// [RenderBox.localToGlobal]
  /// [RenderObjectEx.getGlobalLocation]
  Rect? getGlobalBounds([RenderObject? ancestor, Offset? point]) {
    final offset = getGlobalLocation(ancestor, point);
    final size = getSizeOrNull();
    if (offset != null && size != null) {
      return offset & size;
    }
    return null;
  }

  /// 获取[RenderObject]的位置信息
  /// - [ancestor] 祖先节点, 如果为null, 则为根节点
  /// - [point] 参考点
  /// - [RenderBox.localToGlobal]
  /// ```
  /// Scrollable.of(context).context.findRenderObject();
  /// ```
  /// - [RenderBox.globalToLocal]
  ///
  /// 在布局阶段不允许获取box的大小
  ///
  /// ```
  /// RenderBox.size accessed beyond the scope of resize, layout, or permitted parent access.
  /// RenderBox can always access its own size, otherwise, the only object that is allowed to read RenderBox.size is its parent,
  /// if they have said they will. It you hit this assert trying to access a child's size,
  /// pass "parentUsesSize: true" to that child's layout() in _ColorFilterRenderObject.performLayout.
  /// ```
  ///
  Offset? getGlobalLocation([RenderObject? ancestor, Offset? point]) {
    final box = this;
    if (box is RenderProxyBox) {
      return box.child?.getGlobalLocation(ancestor, point);
    }
    if (box is RenderBox && box.hasSize && box.parent?.hasBoxSize == true) {
      final location = box.localToGlobal(
        point ?? box.paintBounds.topLeft,
        ancestor: ancestor,
      );
      return location;
    }
    return null;
  }

  ///一直往上查找, 直到找到[SliverConstraints]为止
  SliverConstraints? findSliverConstraints() {
    final box = this;
    if (box is RenderSliver) {
      return box.constraints;
    }
    return parent?.findSliverConstraints();
  }

  /// 标记下一帧需要重绘
  /// [markNeedsPaint]
  void postMarkNeedsPaint() {
    postFrameCallback((timeStamp) {
      markNeedsPaint();
    });
  }

  /// 获取盒子的位置
  /// [RenderBoxContainerDefaultsMixin.defaultPaint]
  /// [RenderBoxContainerDefaultsMixin.defaultHitTestChildren]
  Offset getBoxOffset() {
    final pd = parentData;
    if (pd is BoxParentData) {
      return pd.offset;
    }
    return Offset.zero;
  }

  /// 设置盒子的位置
  /// [BoxParentData]
  void setBoxOffset({Offset? offset, double? dx, double? dy}) {
    final pd = parentData;
    if (pd is BoxParentData) {
      dx ??= offset?.dx ?? 0;
      dy ??= offset?.dy ?? 0;
      pd.offset = Offset(dx, dy);
    }
  }

  /// 父布局的约束
  BoxConstraints? get parentBoxConstraints {
    final parentConstraints = parent?.constraints;
    if (parentConstraints is BoxConstraints) {
      return parentConstraints;
    }
    return parent?.parentBoxConstraints;
  }

  /// 遍历所有的子节点[RenderObject]
  /// [visitor] 返回值表示是否继续遍历; true: 继续深度遍历; false: 停止深度遍历;
  /// [ContextEx.eachVisitChildElements]
  eachVisitChildRenderObject(
    ConditionalRenderObjectVisitorDepth visitor, {
    int depth = 0,
  }) {
    int childIndex = 0;
    //此方法不能再build期间调用
    visitChildren((renderObject) {
      bool interrupt = !visitor(renderObject, depth, childIndex++);
      if (!interrupt) {
        renderObject.eachVisitChildRenderObject(visitor, depth: depth + 1);
      }
    });
  }

  /// 相对自身的动画变换矩阵
  /// [RenderTransform]
  Matrix4? getEffectiveTransform(
    Matrix4 transform, {
    AlignmentGeometry? alignment = Alignment.center,
    Offset? origin,
    TextDirection? textDirection,
  }) {
    final size = getSizeOrNull() ?? Size.zero;
    final Alignment? resolvedAlignment = alignment?.resolve(textDirection);
    if (origin == null && resolvedAlignment == null) {
      return transform;
    }
    final Matrix4 result = Matrix4.identity();
    if (origin != null) {
      result.translate(origin.dx, origin.dy);
    }
    Offset? translation;
    if (resolvedAlignment != null) {
      translation = resolvedAlignment.alongSize(size);
      result.translate(translation.dx, translation.dy);
    }
    result.multiply(transform);
    if (resolvedAlignment != null) {
      result.translate(-translation!.dx, -translation.dy);
    }
    if (origin != null) {
      result.translate(-origin.dx, -origin.dy);
    }
    return result;
  }
}

extension ElementEx on Element {}

extension GlobalKeyEx on GlobalKey {
  /// 对应的渲染对象
  RenderObject? get renderObject => currentContext?.findRenderObject();

  /// 获取当前渲染对象对应的全局位置
  /// [ancestor] 祖先
  Rect? getGlobalBounds([RenderObject? ancestor, Offset? point]) {
    final box = renderObject;
    if (box != null) {
      return box.getGlobalBounds(ancestor, point);
    }
    return null;
  }
}

extension LocaleEx on Locale {
  /// 系统当前的语言环境
  /// [platformLocale]
  /// [platformLocales]
  bool get isZh {
    return languageCode == 'zh';
  }
}

//endregion 界面相关

//region 渐变相关

/// 获取渐变颜色指定进度对应的颜色值
/// [progress] 进度[0~1]
/// [colors] 颜色渐变的值
/// [colorStops] 渐变颜色分段比例, 不指定默认平分
Color getGradientColor(
  double progress,
  List<Color> colors, {
  List<double>? colorStops,
}) {
  //debugger();
  colorStops ??= [
    for (var i = 0; i < colors.size(); i++) i * (1 / (colors.size() - 1)),
  ];

  //计算输出的颜色
  Color color = colors.first;
  for (int i = 0; i < colorStops.length; i++) {
    if (progress <= colorStops[i]) {
      final index = math.max(0, i - 1);
      final startColor = colors[index];
      final endColor = colors[math.min(index + 1, colors.length)];
      final startProgress = colorStops[index];
      final endProgress = colorStops[math.min(index + 1, colorStops.length)];

      final t = (progress - startProgress) / (endProgress - startProgress);
      color = Color.lerp(startColor, endColor, t)!;
      break;
    }
  }
  return color;
}

/// 线性渐变 [Shader]
/// [rect] 请指定渐变的范围, 否则可能没有渐变效果
UiGradient? linearGradientShader(
  List<Color>? colors, {
  Rect? rect,
  Offset? from,
  Offset? to,
  //--
  List<double>? colorStops,
  TileMode tileMode = TileMode.clamp,
  Float64List? matrix4,
}) => colors == null || colors.isEmpty
    ? null
    : UiGradient.linear(
        from ?? rect?.lt ?? Offset.zero,
        to ?? rect?.rt ?? Offset.zero,
        colors,
        colorStops ??
            [for (var i = 0; i < colors.size(); i++) i / colors.size()],
        tileMode,
        matrix4,
      );

/// 径向渐变 [Shader]
UiGradient? radialGradientShader(
  double radius,
  List<Color>? colors, {
  Rect? rect,
  Offset? center,
}) => colors == null || colors.isEmpty
    ? null
    : UiGradient.radial(center ?? rect?.center ?? Offset.zero, radius, colors);

/// 扫描渐变 [Shader]
/// 如果未指定[colorStops]时, 则[colors]的长度只能有2个
/// 如果指定了[colorStops], 则长度必须与[colors]相同
/// [_validateColorStops]
UiGradient? sweepGradientShader(
  List<Color>? colors, {
  Rect? rect,
  Offset? center,
  List<double>? colorStops,
}) => colors == null || colors.isEmpty
    ? null
    : UiGradient.sweep(
        center ?? rect?.center ?? Offset.zero,
        colors,
        colorStops,
      );

/// [Gradient]
/// [Gradient.createShader]通过此方法, 创建一个[Shader], 然后作用给[Paint.shader]
/// [UiGradient]
LinearGradient linearGradient(
  List<Color> colors, {
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
  List<double>? stops,
}) => LinearGradient(
  colors: colors.ensureLength(2),
  begin: begin,
  end: end,
  stops: stops,
  tileMode: tileMode,
  transform: transform,
);

/// 径向渐变
RadialGradient radialGradient(
  List<Color> colors, {
  AlignmentGeometry center = Alignment.center,
  double radius = 0.5,
  List<double>? stops,
  TileMode tileMode = TileMode.clamp,
  AlignmentGeometry? focal,
  double focalRadius = 0.0,
  GradientTransform? transform,
}) => RadialGradient(
  colors: colors.ensureLength(2),
  radius: radius,
  center: center,
  stops: stops,
  tileMode: tileMode,
  focal: focal,
  focalRadius: focalRadius,
  transform: transform,
);

/// 扫描渐变
SweepGradient sweepGradient(
  List<Color> colors, {
  AlignmentGeometry center = Alignment.center,
  double startAngle = 0.0,
  double endAngle = math.pi * 2,
  List<double>? stops,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
}) => SweepGradient(
  colors: colors.ensureLength(2),
  center: center,
  startAngle: startAngle,
  endAngle: endAngle,
  stops: stops,
  tileMode: tileMode,
  transform: transform,
);

/// 返回一个线性渐变的小部件
/// [colors] 渐变颜色, 必须要2个颜色
/// [gradientDirection] 渐变方向, 默认水平方向, 此属性只是用来设置[begin]和[end]的
Widget linearGradientWidget(
  List<Color> colors, {
  double? width,
  double? height,
  BoxConstraints? constraints,
  Key? key,
  Widget? child,
  Axis? gradientDirection = Axis.horizontal,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
}) {
  if (gradientDirection == Axis.horizontal) {
    begin = Alignment.centerLeft;
    end = Alignment.centerRight;
  } else if (gradientDirection == Axis.vertical) {
    begin = Alignment.topCenter;
    end = Alignment.bottomCenter;
  }
  return Container(
    key: key,
    width: width,
    height: height,
    constraints: constraints,
    decoration: BoxDecoration(
      gradient: linearGradient(
        colors.ensureLength(2),
        begin: begin,
        end: end,
        tileMode: tileMode,
        transform: transform,
      ),
    ),
    child: child,
  );
}

/// 从底部到顶部透明的渐变阴影
Widget btt({double? height = 10}) => linearGradientWidget(
  [Colors.transparent, Colors.black12],
  height: height,
  gradientDirection: Axis.vertical,
);

/// 从顶部到底部透明的渐变阴影
Widget ttb({double? height = 10}) => linearGradientWidget(
  [Colors.black12, Colors.transparent],
  height: height,
  gradientDirection: Axis.vertical,
);

/// 从左到右透明的渐变阴影
Widget ltr({double? width = 10}) => linearGradientWidget(
  [Colors.black12, Colors.transparent],
  width: width,
  gradientDirection: Axis.horizontal,
);

/// 从右到到透明的渐变阴影
Widget rtl({double? width = 10}) => linearGradientWidget(
  [Colors.transparent, Colors.black12],
  width: width,
  gradientDirection: Axis.horizontal,
);

//endregion 渐变相关

extension TextStyleEx on TextStyle {
  /// 给[TextStyle]添加阴影
  TextStyle shadow({
    Color? color = Colors.black,
    double blurRadius = 2,
    Offset offset = const Offset(2.0, 2.0),
    List<Shadow>? shadows,
  }) {
    if (color == null && isNil(shadows)) {
      return this;
    }
    return copyWith(
      shadows: [
        if (color != null)
          BoxShadow(color: color, blurRadius: blurRadius, offset: offset),
        ...?shadows,
      ],
    );
  }
}
