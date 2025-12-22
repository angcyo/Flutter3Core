part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/12/27
///
/// 全局键盘事件监听
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

  /// 当前按下的物理按键
  final Set<PhysicalKeyboardKey> _physicalKeysPressed = {};

  /// 注册一个键盘事件监听
  /// [handleKeyEventResultMixin]
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

  /// 重置所有键盘事件监听
  @api
  void resetAllKeyEventRegister(Iterable<KeyEventRegister> list) {
    _keyEventRegisterList.resetAll(list);
  }

  /// 移除所有键盘事件监听
  @api
  void removeAllKeyEventRegister() {
    _keyEventRegisterList.clear();
  }

  @callPoint
  @overridePoint
  bool onHandleKeyEventMixin(KeyEvent event) {
    return handleKeyEventResultMixin(event) != KeyEventResult.ignored;
  }

  /// 处理入口
  /// - 实现快捷方式按键匹配
  /// @return 按键事件返回
  ///  - [KeyEventResult.ignored] 没有处理了
  ///  - [KeyEventResult.handled] 被处理了
  ///  - [KeyEventResult.skipRemainingHandlers] 跳过剩余处理者
  @callPoint
  @overridePoint
  KeyEventResult handleKeyEventResultMixin(KeyEvent event) {
    KeyEventResult handle = KeyEventResult.ignored;
    //l.w("onHandleKeyEventMixin[${event.isKeyUp}]->$event");
    //debugger(when: event.isKeyUp);
    if (event.isKeyDown) {
      _physicalKeysPressed.add(event.physicalKey);
    }

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
            if ((((register.keyDown && event.isKeyDown) ||
                        (register.keyRepeat && event.isKeyRepeat)) &&
                    isKeysPressedAll(
                      keys,
                      matchKeyCount: register.matchKeyCount,
                      physicalPressedKeys: _physicalKeysPressed,
                    )) ||
                (register.keyUp &&
                    event.isKeyUp &&
                    isSameLogicalKey(
                      keys.filterLogicalKeysPressed.lastOrNull,
                      event.logicalKey,
                    ))) {
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
              if (handle != KeyEventResult.ignored) {
                if (register.stopPropagation) {
                  interrupt = true;
                }
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
    if (event.isKeyUp) {
      _physicalKeysPressed.remove(event.physicalKey);
    }
    if (handle != KeyEventResult.ignored) {
      //清空
      _physicalKeysPressed.clear();
    }
    return handle;
  }
}

typedef KeyEventHandleAction = KeyEventResult Function(KeyEventHitInfo event);

/// 键盘事件, 注册的信息
/// - [KeyEventRegister]
/// - [KeyEventHitInfo]
class KeyEventRegister {
  /// 事件按键
  final List<List<KeyboardKey>>? eventGroupKeys;

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

/// 键盘事件, 命中的信息
/// [KeyEventRegister]
class KeyEventHitInfo {
  /// 命中的按键组合
  final List<KeyboardKey> keys;

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

//--

/// 快捷键注册监听[KeyEventRegister]
/// [KeyEventMixin]
class KeyEventWidget extends StatefulWidget {
  /// 按键匹配处理列表
  final List<KeyEventRegister> keyEventRegisterList;

  /// 内容
  final Widget child;

  const KeyEventWidget({
    super.key,
    required this.keyEventRegisterList,
    required this.child,
  });

  @override
  State<KeyEventWidget> createState() => _KeyEventWidgetState();
}

class _KeyEventWidgetState extends State<KeyEventWidget> with KeyEventMixin {
  @override
  void initState() {
    resetAllKeyEventRegister(widget.keyEventRegisterList);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant KeyEventWidget oldWidget) {
    resetAllKeyEventRegister(widget.keyEventRegisterList);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: null,
      parentNode: null,
      autofocus: true,
      canRequestFocus: null,
      skipTraversal: null,
      onFocusChange: isDebug
          ? (value) {
              l.i('[${classHash()}] focus change $value');
            }
          : null,
      onKeyEvent: (node, event) {
        assert(() {
          //l.i('[${classHash()}] key event $event');
          //l.w("${HardwareKeyboard.instance.physicalKeysPressed}");
          return true;
        }());
        //debugger(when: event.physicalKey == PhysicalKeyboardKey.keyS);
        //debugger(when: event.isKeyUp);
        return handleKeyEventResultMixin(event);
      },
      child: widget.child,
    );
  }
}
