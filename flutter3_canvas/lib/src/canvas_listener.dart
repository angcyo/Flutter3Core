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

  /// [CanvasDelegate.dispatchCanvasSelectBoundsChanged]
  final void Function(Rect? bounds)? onCanvasSelectBoundsChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementPropertyChanged]
  final void Function(
    ElementPainter elementPainter,
    PaintProperty? old,
    PaintProperty? value,
  )? onCanvasElementPropertyChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementSelectChanged]
  final void Function(
    ElementSelectComponent elementSelect,
    List<ElementPainter>? from,
    List<ElementPainter>? to,
  )? onCanvasElementSelectChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementListChanged]
  final void Function(
    List<ElementPainter> from,
    List<ElementPainter> to,
  )? onCanvasElementListChangedAction;

  /// [CanvasDelegate.dispatchDoubleTapElement]
  final void Function(ElementPainter elementPainter)? onDoubleTapElementAction;

  CanvasListener({
    this.onCanvasViewBoxChangedAction,
    this.onCanvasSelectBoundsChangedAction,
    this.onCanvasElementPropertyChangedAction,
    this.onCanvasElementSelectChangedAction,
    this.onCanvasElementListChangedAction,
    this.onDoubleTapElementAction,
  });
}
