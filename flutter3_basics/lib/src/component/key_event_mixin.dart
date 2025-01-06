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

/// [KeyEventMixin]
mixin KeyEventRenderObjectMixin on RenderObject {
  @override
  void attach(PipelineOwner owner) {
    HardwareKeyboard.instance.addHandler(onKeyEventHandleMixin);
    super.attach(owner);
  }

  @override
  void detach() {
    HardwareKeyboard.instance.removeHandler(onKeyEventHandleMixin);
    _keyEventRegisterList.clear();
    super.detach();
  }

  //--

  /// 键盘事件监听
  final List<KeyEventRegister> _keyEventRegisterList = [];

  /// 注册一个键盘事件监听
  @api
  void registerKeyEvent(
    List<List<LogicalKeyboardKey>>? eventGroupKeys,
    ResultBoolAction? onKeyEventAction, {
    bool stopPropagation = true,
  }) {
    addKeyEventRegister(KeyEventRegister(
      eventGroupKeys,
      stopPropagation: stopPropagation,
      onKeyEventAction: onKeyEventAction,
    ));
  }

  /// 添加键盘事件监听
  @api
  void addKeyEventRegister(KeyEventRegister register) {
    _keyEventRegisterList.add(register);
  }

  /// 移除键盘事件监听
  @api
  void removeKeyEventRegister(KeyEventRegister register) {
    _keyEventRegisterList.remove(register);
  }

  /// 移除所有键盘事件监听
  @api
  void removeAllKeyEventRegister() {
    _keyEventRegisterList.clear();
  }

  @overridePoint
  bool onKeyEventHandleMixin(KeyEvent event) {
    bool handle = false;
    if (event.isKeyDownOrRepeat) {
      for (final register in _keyEventRegisterList) {
        final onKeyEvent = register.onKeyEventAction;
        if (onKeyEvent == null) {
          continue;
        }
        //--
        final eventGroupKeys = register.eventGroupKeys;
        if (eventGroupKeys != null) {
          //中断
          bool interrupt = false;
          for (final keys in eventGroupKeys) {
            if (isKeysPressedAll(keys)) {
              handle = onKeyEvent();
              if (handle && register.stopPropagation) {
                interrupt = true;
                break;
              }
            }
          }
          if (interrupt) {
            break;
          }
        }
      }
    }
    return handle;
  }
}

/// 键盘事件, 注册信息
class KeyEventRegister {
  /// 事件按键
  final List<List<LogicalKeyboardKey>>? eventGroupKeys;

  /// 回调
  final ResultBoolAction? onKeyEventAction;

  /// 事件被处理之后, 是否阻止冒泡
  final bool stopPropagation;

  const KeyEventRegister(
    this.eventGroupKeys, {
    this.onKeyEventAction,
    this.stopPropagation = true,
  });
}
