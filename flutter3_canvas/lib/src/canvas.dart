part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/01
///
/// 画布小部件代理核心类
class CanvasWidget extends LeafRenderObjectWidget {
  final CanvasDelegate canvasDelegate;

  const CanvasWidget(this.canvasDelegate, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) => CanvasRenderBox(
        context,
        canvasDelegate..delegateContext = context,
      );

  @override
  void updateRenderObject(BuildContext context, CanvasRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    canvasDelegate.delegateContext = context;
    renderObject
      ..context = context
      ..canvasDelegate = canvasDelegate
      ..markNeedsPaint();
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('canvasDelegate', canvasDelegate));
  }
}

/// 画布渲染核心类
/// 负责画布的绘制入口
/// 负责画布的手势入口
class CanvasRenderBox extends RenderBox {
  BuildContext context;
  CanvasDelegate canvasDelegate;

  CanvasRenderBox(
    this.context,
    this.canvasDelegate,
  );

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    double? width =
        constraints.maxWidth == double.infinity ? null : constraints.maxWidth;
    double? height =
        constraints.maxHeight == double.infinity ? null : constraints.maxHeight;
    size =
        Size(width ?? height ?? screenWidth, height ?? width ?? screenHeight);

    canvasDelegate.layout(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    canvasDelegate.paint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    var hitInterceptBox = GestureHitInterceptScope.of(context);
    hitInterceptBox?.interceptHitBox = this;
    canvasDelegate.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    canvasDelegate.repaint.addListener(_repaintListener);
    canvasDelegate.attach();
  }

  @override
  void detach() {
    super.detach();
    canvasDelegate.repaint.removeListener(_repaintListener);
    canvasDelegate.detach();
  }

  /// 重绘
  void _repaintListener() {
    markNeedsPaint();
  }
}

/// 画布回调监听
class CanvasListener {
  /// [CanvasDelegate.dispatchCanvasPaint]
  final void Function(
    CanvasDelegate delegate,
    int paintCount,
  )? onCanvasPaintAction;

  /// [CanvasDelegate.dispatchCanvasIdle]
  final void Function(
    CanvasDelegate delegate,
    Duration lastRefreshTime,
  )? onCanvasIdleAction;

  /// [CanvasDelegate.dispatchCanvasViewBoxChanged]
  final void Function(
    CanvasViewBox canvasViewBox,
    bool isInitialize,
    bool isCompleted,
  )? onCanvasViewBoxChangedAction;

  /// [CanvasDelegate.dispatchCanvasUnitChanged]
  final void Function(
    IUnit from,
    IUnit to,
  )? onCanvasUnitChangedAction;

  /// [CanvasDelegate.dispatchCanvasSelectBoundsChanged]
  final void Function(Rect? bounds)? onCanvasSelectBoundsChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementPropertyChanged]
  final void Function(
    ElementPainter elementPainter,
    dynamic from,
    dynamic to,
    PainterPropertyType propertyType,
    UndoType? fromUndoType,
  )? onCanvasElementPropertyChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementSelectChanged]
  final void Function(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? from,
    List<ElementPainter>? to,
    ElementSelectType selectType,
  )? onCanvasElementSelectChangedAction;

  /// [CanvasDelegate.dispatchCanvasSelectElementList]
  final void Function(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? list,
    ElementSelectType selectType,
  )? onCanvasSelectElementListAction;

  /// [CanvasDelegate.dispatchCanvasElementListChanged]
  final void Function(
    List<ElementPainter> from,
    List<ElementPainter> to,
    List<ElementPainter> op,
    UndoType undoType,
  )? onCanvasElementListChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementListAddChanged]
  final void Function(
    List<ElementPainter> list,
    List<ElementPainter> op,
  )? onCanvasElementListAddChanged;

  /// [CanvasDelegate.dispatchCanvasElementListRemoveChanged]
  final void Function(
    List<ElementPainter> list,
    List<ElementPainter> op,
  )? onCanvasElementListRemoveChanged;

  /// [CanvasDelegate.dispatchDoubleTapElement]
  final void Function(ElementPainter elementPainter)? onDoubleTapElementAction;

  /// [CanvasDelegate.dispatchTranslateElement]
  final void Function(
    ElementPainter? targetElement,
    bool isFirstTranslate,
    bool isEnd,
  )? onTranslateElementAction;

  /// [CanvasDelegate.dispatchPointerDown]
  final void Function(
    @viewCoordinate Offset position,
    ElementMenu? downMenu,
    List<ElementPainter>? downElementList,
    bool isRepeat,
  )? onPointerDownAction;

  /// [CanvasDelegate.dispatchTapMenu]
  final void Function(ElementMenu menu)? onTapMenuAction;

  /// [CanvasDelegate.dispatchControlStateChanged]
  final void Function({
    required BaseControl control,
    ElementPainter? controlElement,
    required ControlState state,
  })? onControlStateChangedAction;

  /// [CanvasDelegate.dispatchCanvasUndoChanged]
  final void Function(CanvasUndoManager undoManager)? onCanvasUndoChangedAction;

  /// [CanvasDelegate.dispatchCanvasGroupChanged]
  final void Function(
    ElementGroupPainter group,
    List<ElementPainter> elements,
  )? onCanvasGroupChangedAction;

  /// [CanvasDelegate.dispatchCanvasUngroupChanged]
  final void Function(ElementGroupPainter group)? onCanvasUngroupChangedAction;

  /// [CanvasDelegate.dispatchCanvasContentChanged]
  final void Function()? onCanvasContentChangedAction;

  /// [CanvasDelegate.dispatchCanvasMultiStateChanged]
  final void Function(CanvasStateData canvasStateData, CanvasStateType type)?
      onCanvasMultiStateChanged;

  /// [CanvasDelegate.dispatchCanvasMultiStateListChanged]
  final void Function(List<CanvasStateData> to)? onCanvasMultiStateListChanged;

  /// [CanvasDelegate.dispatchCanvasSelectedStateChanged]
  final void Function(CanvasStateData? from, CanvasStateData? to)?
      onCanvasSelectedStateChanged;

  /// [CanvasDelegate.dispatchElementAttachToCanvasDelegate]
  final void Function(CanvasDelegate delegate, ElementPainter painter)?
      onElementAttachToCanvasDelegate;

  /// [CanvasDelegate.dispatchElementAttachToCanvasDelegate]
  final void Function(CanvasDelegate delegate, ElementPainter painter)?
      onElementDetachToCanvasDelegate;

  CanvasListener({
    this.onCanvasPaintAction,
    this.onCanvasIdleAction,
    this.onCanvasViewBoxChangedAction,
    this.onCanvasUnitChangedAction,
    this.onCanvasSelectBoundsChangedAction,
    this.onCanvasElementPropertyChangedAction,
    this.onCanvasElementSelectChangedAction,
    this.onCanvasSelectElementListAction,
    this.onCanvasElementListChangedAction,
    this.onCanvasElementListAddChanged,
    this.onCanvasElementListRemoveChanged,
    this.onDoubleTapElementAction,
    this.onTranslateElementAction,
    this.onPointerDownAction,
    this.onTapMenuAction,
    this.onCanvasUndoChangedAction,
    this.onCanvasGroupChangedAction,
    this.onCanvasUngroupChangedAction,
    this.onControlStateChangedAction,
    this.onCanvasContentChangedAction,
    this.onCanvasMultiStateChanged,
    this.onCanvasMultiStateListChanged,
    this.onCanvasSelectedStateChanged,
    this.onElementAttachToCanvasDelegate,
    this.onElementDetachToCanvasDelegate,
  });
}
