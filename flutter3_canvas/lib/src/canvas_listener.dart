part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/19
///
/// 画布回调监听
class CanvasListener {
  /// [CanvasDelegate.dispatchCanvasPaint]
  final void Function(CanvasDelegate delegate, int paintCount)? onCanvasPaint;

  /// [CanvasDelegate.dispatchCanvasViewBoxChanged]
  final void Function(
    CanvasViewBox canvasViewBox,
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
    int propertyType,
  )? onCanvasElementPropertyChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementSelectChanged]
  final void Function(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? from,
    List<ElementPainter>? to,
  )? onCanvasElementSelectChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementListChanged]
  final void Function(
    List<ElementPainter> from,
    List<ElementPainter> to,
    List<ElementPainter> op,
    UndoType undoType,
  )? onCanvasElementListChangedAction;

  /// [CanvasDelegate.dispatchDoubleTapElement]
  final void Function(ElementPainter elementPainter)? onDoubleTapElementAction;

  /// [CanvasDelegate.dispatchCanvasUndoChanged]
  final void Function(CanvasUndoManager undoManager)? onCanvasUndoChangedAction;

  /// [CanvasDelegate.dispatchCanvasGroupChanged]
  final void Function(ElementGroupPainter group, List<ElementPainter> elements)?
      onCanvasGroupChangedAction;

  /// [CanvasDelegate.dispatchCanvasUngroupChanged]
  final void Function(ElementGroupPainter group)? onCanvasUngroupChangedAction;

  CanvasListener({
    this.onCanvasPaint,
    this.onCanvasViewBoxChangedAction,
    this.onCanvasUnitChangedAction,
    this.onCanvasSelectBoundsChangedAction,
    this.onCanvasElementPropertyChangedAction,
    this.onCanvasElementSelectChangedAction,
    this.onCanvasElementListChangedAction,
    this.onDoubleTapElementAction,
    this.onCanvasUndoChangedAction,
    this.onCanvasGroupChangedAction,
    this.onCanvasUngroupChangedAction,
  });
}
