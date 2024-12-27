part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/12/27
///
/// 键盘事件监听
/// [HardwareKeyboard]
/// [KeyboardListener]
/// [ServicesBinding.instance.keyEventManager.keyMessageHandler]
mixin KeyEventMixin<T extends StatefulWidget> on State<T> {
  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(onKeyEventHandleMixin);
    super.dispose();
  }

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(onKeyEventHandleMixin);
    super.initState();
  }

  @overridePoint
  bool onKeyEventHandleMixin(KeyEvent event) {
    return false;
  }
}
