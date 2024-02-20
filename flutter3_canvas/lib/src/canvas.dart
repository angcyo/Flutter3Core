part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/01
///
/// 画布小部件
class CanvasWidget extends LeafRenderObjectWidget {
  final CanvasDelegate canvasDelegate;

  const CanvasWidget({
    super.key,
    required this.canvasDelegate,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      CanvasRenderBox(context, canvasDelegate..delegateContext = context);

  @override
  void updateRenderObject(BuildContext context, CanvasRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    canvasDelegate.delegateContext = context;
    renderObject
      ..context = context
      ..canvasDelegate = canvasDelegate;
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

/// 画布渲染
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
  }

  @override
  void detach() {
    super.detach();
    canvasDelegate.repaint.removeListener(_repaintListener);
  }

  /// 重绘
  void _repaintListener() {
    markNeedsPaint();
  }
}

/// 坐标系
class CanvasCoordinate {
  final String des;

  const CanvasCoordinate(this.des);
}

const viewCoordinate = CanvasCoordinate('视图坐标的值, 以屏幕左上角为原点');
const sceneCoordinate = CanvasCoordinate('场景坐标的值, 以内容坐标中心为原点');
