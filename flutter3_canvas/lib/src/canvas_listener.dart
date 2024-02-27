part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/19
///
/// 画布回调监听
class CanvasListener {
  /// [CanvasDelegate.dispatchCanvasViewBoxChanged]
  final void Function(CanvasViewBox canvasViewBox, bool isCompleted)?
      onCanvasViewBoxChangedAction;

  /// [CanvasDelegate.dispatchCanvasSelectBoundsChangedAction]
  final void Function(Rect? bounds)? onCanvasSelectBoundsChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementPropertyChanged]
  final void Function(
    ElementPainter elementPainter,
    PaintProperty? old,
    PaintProperty? value,
  )? onCanvasElementPropertyChangedAction;

  CanvasListener({
    this.onCanvasViewBoxChangedAction,
    this.onCanvasSelectBoundsChangedAction,
    this.onCanvasElementPropertyChangedAction,
  });
}
