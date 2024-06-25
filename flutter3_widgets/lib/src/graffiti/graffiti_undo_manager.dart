part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 回退栈管理
class GraffitiUndoManager extends UndoActionManager {
  final GraffitiDelegate graffitiDelegate;

  GraffitiUndoManager(this.graffitiDelegate);

  @override
  void notifyChange(UndoType fromType) {
    super.notifyChange(fromType);
    graffitiDelegate.dispatchGraffitiUndoChanged(this, fromType);
  }
}
