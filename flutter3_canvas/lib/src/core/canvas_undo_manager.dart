part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/12
///
class CanvasUndoManager extends UndoActionManager {
  final CanvasDelegate canvasDelegate;

  CanvasUndoManager(this.canvasDelegate);

  @override
  void notifyChanged(UndoType fromType) {
    super.notifyChanged(fromType);
    canvasDelegate.dispatchCanvasUndoChanged(this, fromType);
  }

  /// 添加一个可以撤销的操作
  @api
  void addUntoState(
    ElementStateStack? undoState,
    ElementStateStack? redoState,
  ) {
    if (undoState == null || redoState == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    add(UndoActionItem(() {
      undoState.restore();
    }, () {
      redoState.restore();
    }));
  }
}
