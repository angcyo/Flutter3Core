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

  CanvasListener({this.onCanvasViewBoxChangedAction});
}
