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
///
/// [KeyEventStateMixin]
/// [KeyEventRenderObjectMixin]
///
mixin KeyEventStateMixin<T extends StatefulWidget> on State<T>, KeyEventMixin {
  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(onHandleKeyEventMixin);
    super.initState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(onHandleKeyEventMixin);
    _keyEventRegisterList.clear();
    super.dispose();
  }
}

/// 此混入会在全局范围内注册键盘事件
/// 如果不希望全局获取键盘事件应该使用[FocusNode.onKeyEvent]
/// [KeyEventStateMixin]
/// [KeyEventRenderObjectMixin]
mixin KeyEventRenderObjectMixin on RenderObject, KeyEventMixin {
  @override
  void attach(PipelineOwner owner) {
    HardwareKeyboard.instance.addHandler(onHandleKeyEventMixin);
    super.attach(owner);
  }

  @override
  void detach() {
    HardwareKeyboard.instance.removeHandler(onHandleKeyEventMixin);
    _keyEventRegisterList.clear();
    super.detach();
  }
}

//--

/// 组合按键监听处理
mixin KeyEventMixin {
  //--

  /// 键盘事件监听
  final List<KeyEventRegister> _keyEventRegisterList = [];

  /// 注册一个键盘事件监听
  /// [onHandleKeyEventMixin]
  @api
  void registerKeyEvent(
    List<List<LogicalKeyboardKey>>? eventGroupKeys,
    KeyEventHandleAction? onKeyEventAction, {
    bool matchKeyCount = true,
    bool stopPropagation = true,
    bool keyDown = true,
    bool keyRepeat = false,
    bool keyUp = false,
  }) {
    addKeyEventRegister(
      KeyEventRegister(
        eventGroupKeys,
        stopPropagation: stopPropagation,
        matchKeyCount: matchKeyCount,
        keyDown: keyDown,
        keyRepeat: keyRepeat,
        keyUp: keyUp,
        onKeyEventAction: onKeyEventAction,
      ),
    );
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

  /// 处理入口
  @callPoint
  @overridePoint
  bool onHandleKeyEventMixin(KeyEvent event) {
    bool handle = false;
    //l.w("onHandleKeyEventMixin[${event.isKeyUp}]->$event");
    //debugger(when: event.isKeyUp);
    if (event.isKeyDownOrRepeat || event.isKeyUp) {
      for (final register in _keyEventRegisterList) {
        if ((event.isKeyDown && register.keyDown) ||
            (event.isKeyRepeat && register.keyRepeat) ||
            (event.isKeyUp && register.keyUp)) {
          //需要处理 按下事件
          //需要处理 重复事件
          //需要处理 抬起事件
        } else {
          continue;
        }
        final onKeyEvent = register.onKeyEventAction;
        if (onKeyEvent == null) {
          continue;
        }
        //--
        final eventGroupKeys = register.eventGroupKeys;
        //debugger(when: event.isKeyUp);
        if (eventGroupKeys != null) {
          //中断
          bool interrupt = false;
          for (final keys in eventGroupKeys) {
            if (((event.isKeyDown || event.isKeyRepeat) &&
                    isKeysPressedAll(
                      keys,
                      matchKeyCount: register.matchKeyCount,
                    )) ||
                (event.isKeyUp &&
                    isSameLogicalKey(keys.lastOrNull, event.logicalKey))) {
              handle = onKeyEvent(
                KeyEventHitInfo(
                  keys,
                  isKeyDown: event.isKeyDown,
                  isKeyRepeat: event.isKeyRepeat,
                  isKeyUp: event.isKeyUp,
                ),
              );
              /*assert(() {
                l.d("按键命中->[${keys.connect(
                    " + ", (e) => e.debugName ?? e.keyLabel)}] $handle");
                return true;
              }());*/
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

typedef KeyEventHandleAction = bool Function(KeyEventHitInfo);

/// 键盘事件, 注册信息
class KeyEventRegister {
  /// 事件按键
  final List<List<LogicalKeyboardKey>>? eventGroupKeys;

  /// 回调
  final KeyEventHandleAction? onKeyEventAction;

  /// 事件被处理之后, 是否阻止冒泡
  final bool stopPropagation;

  /// 是否要匹配按键的数量
  final bool matchKeyCount;

  /// 处理键盘按下事件
  final bool keyDown;

  /// 处理键盘重复事件
  final bool keyRepeat;

  /// 处理键盘抬起事件
  final bool keyUp;

  const KeyEventRegister(
    this.eventGroupKeys, {
    this.onKeyEventAction,
    this.stopPropagation = true,
    this.matchKeyCount = true,
    this.keyDown = true,
    this.keyRepeat = false,
    this.keyUp = false,
  });
}

/// 键盘事件, 命中信息
/// [KeyEventRegister]
class KeyEventHitInfo {
  /// 命中的按键组合
  final List<LogicalKeyboardKey> keys;

  /// 是否是按下事件
  final bool isKeyDown;

  /// 是否是重复事件
  final bool isKeyRepeat;

  /// 是否是抬起事件
  final bool isKeyUp;

  const KeyEventHitInfo(
    this.keys, {
    this.isKeyRepeat = false,
    this.isKeyDown = false,
    this.isKeyUp = false,
  });

  @override
  String toString() {
    return 'KeyEventHitInfo{keys: $keys, isKeyDown: $isKeyDown, isKeyRepeat: $isKeyRepeat, isKeyUp: $isKeyUp}';
  }
}

/// 按键处理客户端
mixin KeyEventClientMixin {
  /// 是否要拦截后续的所有键盘事件
  @overridePoint
  bool interceptKeyEvent(KeyEvent event) => false;

  /// 是否处理了键盘事件
  @overridePoint
  bool handleKeyEvent(KeyEvent event) => false;
}

/// 手机数字按键, 回调输入的数值
/// - 支持限制整数
/// - 支持限制小数
mixin NumberKeyEventDetectorMixin {
  /// 需要探测的数字类型
  /// - 整数
  /// - 小数
  NumType detectorNumberType = NumType.d;

  /// 探测超时时长
  @configProperty
  Duration numberDetectorTimeout = Duration(milliseconds: 160);

  //--

  Timer? _numberDetectorTimer;

  /// 是否是正数, 按下[LogicalKeyboardKey.minus]键时, 变成负数
  bool _isPositive = true;

  /// 收集到的有效字符
  final _keyCharacterMixin = <String>[];

  @entryPoint
  bool addNumberDetectorKeyEvent(KeyEvent event) {
    final character = event.character;
    if (character != null) {
      //有效输入
      if (character == ".") {
        if (detectorNumberType == NumType.d) {
          //可以收集浮点
          if (!_keyCharacterMixin.contains(character)) {
            _keyCharacterMixin.add(character);
            _numberDetector(event);
          }
        } else {
          _clearNumberDetector();
        }
      } else if (character == "-") {
        _isPositive = false;
      } else if (character == "+") {
        _isPositive = true;
      } else if (character.isInt) {
        _keyCharacterMixin.add(character);
        _numberDetector(event);
      } else {
        _clearNumberDetector();
      }
    }
    return true;
  }

  /// 处理收集到的数值
  @overridePoint
  bool handleNumberDetectorKeyEvent(KeyEvent event, dynamic number) {
    return false;
  }

  /// 探测
  void _numberDetector(KeyEvent event) {
    _numberDetectorTimer?.cancel();
    _numberDetectorTimer = null;
    _numberDetectorTimer = Timer(numberDetectorTimeout, () {
      final number = _keyCharacterMixin.join();
      if (number.isNotEmpty) {
        if (handleNumberDetectorKeyEvent(
          event,
          detectorNumberType == NumType.i
              ? int.parse(number) * (_isPositive ? 1 : -1)
              : double.parse(number) * (_isPositive ? 1 : -1),
        )) {
          _clearNumberDetector();
        }
      }
    });
  }

  void _clearNumberDetector() {
    _numberDetectorTimer?.cancel();
    _numberDetectorTimer = null;
    _keyCharacterMixin.clear();
  }
}
