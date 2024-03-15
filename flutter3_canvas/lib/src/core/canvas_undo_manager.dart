part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/12
///
class CanvasUndoManager extends UndoManager {
  final CanvasDelegate canvasDelegate;

  CanvasUndoManager(this.canvasDelegate);

  @override
  void notifyChange(UndoType fromType) {
    super.notifyChange(fromType);
    canvasDelegate.dispatchCanvasUndoChanged(this, fromType);
  }
}
