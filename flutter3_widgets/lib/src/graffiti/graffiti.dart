part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 涂鸦小部件
class GraffitiWidget extends LeafRenderObjectWidget {
  final GraffitiDelegate graffitiDelegate;

  const GraffitiWidget(this.graffitiDelegate, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) => GraffitiRenderBox(
        context,
        graffitiDelegate..delegateContext = context,
      );

  @override
  void updateRenderObject(
      BuildContext context, GraffitiRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    graffitiDelegate.delegateContext = context;
    renderObject
      ..context = context
      ..graffitiDelegate = graffitiDelegate
      ..markNeedsPaint();
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('graffitiDelegate', graffitiDelegate));
  }
}

/// 涂鸦渲染
class GraffitiRenderBox extends RenderBox {
  BuildContext context;
  GraffitiDelegate graffitiDelegate;

  GraffitiRenderBox(
    this.context,
    this.graffitiDelegate,
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

    graffitiDelegate.layout(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    graffitiDelegate.paint(context, offset);
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
    graffitiDelegate.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    graffitiDelegate.repaint.addListener(_repaintListener);
    graffitiDelegate.attach();
  }

  @override
  void detach() {
    super.detach();
    graffitiDelegate.repaint.removeListener(_repaintListener);
    graffitiDelegate.detach();
  }

  /// 重绘
  void _repaintListener() {
    markNeedsPaint();
  }
}

/// 涂鸦回调监听
class GraffitiListener {
  /// [GraffitiDelegate.dispatchGraffitiPaint]
  final void Function(GraffitiDelegate delegate, int paintCount)?
      onGraffitiPaint;

  /// [GraffitiDelegate.dispatchGraffitiElementListChanged]
  final void Function(
    List<GraffitiPainter> from,
    List<GraffitiPainter> to,
    List<GraffitiPainter> op,
    UndoType undoType,
  )? onGraffitiElementListChangedAction;

  /// [GraffitiDelegate.dispatchGraffitiUndoChanged]
  final void Function(GraffitiUndoManager undoManager)?
      onGraffitiUndoChangedAction;

  /// [GraffitiDelegate.dispatchPointEventHandlerChanged]
  final void Function(PointEventHandler? from, PointEventHandler? to)?
      onPointEventHandlerChanged;

  GraffitiListener({
    this.onGraffitiPaint,
    this.onGraffitiUndoChangedAction,
    this.onPointEventHandlerChanged,
    this.onGraffitiElementListChangedAction,
  });
}
