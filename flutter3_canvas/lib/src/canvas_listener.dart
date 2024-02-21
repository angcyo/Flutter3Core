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

  CanvasListener({
    this.onCanvasViewBoxChangedAction,
    this.onCanvasSelectBoundsChangedAction,
  });
}
