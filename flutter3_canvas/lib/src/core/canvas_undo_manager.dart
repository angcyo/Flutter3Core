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

  /// 添加一个可以撤销的操作
  void addUntoState(ElementStateStack undoState, ElementStateStack redoState) {
    add(UndoItem(() {
      undoState.restore();
    }, () {
      redoState.restore();
    }));
  }
}
