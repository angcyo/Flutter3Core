part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/30
///

/// 按键事件处理
/// [HardwareKeyboard]
/// [HardwareKeyboard.instance]

/// [LogicalKeyboardKey.control]
/// [LogicalKeyboardKey.controlLeft]
/// [LogicalKeyboardKey.controlRight]
///
/// 是否是控制按键
/// Windows: Ctrl
/// macOs: control
/// Linux: Ctrl
/// [HardwareKeyboard.isControlPressed]
bool get isCtrlPressed => isKeyPressed(key: LogicalKeyboardKey.control, keys: [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
    ]);

/// 是否是选项按键
/// Windows: Alt
/// macOs: option
/// Linux: Alt
/// [HardwareKeyboard.isAltPressed]
bool get isAltPressed => isKeyPressed(key: LogicalKeyboardKey.alt, keys: [
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
    ]);

/// 是否是meta按键
/// Windows: Windows
/// macOs: command
/// Linux: ...
/// [HardwareKeyboard.isMetaPressed]
bool get isMetaPressed => isKeyPressed(key: LogicalKeyboardKey.meta, keys: [
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
    ]);

/// [HardwareKeyboard.isShiftPressed]
bool get isShiftPressed => isKeyPressed(key: LogicalKeyboardKey.shift, keys: [
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
    ]);

/// 空格按键是否按下
bool get isSpacePressed => isKeyPressed(key: LogicalKeyboardKey.space);

/// 指定的按键, 任意按键是否按下
bool isKeyPressed({
  LogicalKeyboardKey? key,
  List<LogicalKeyboardKey>? keys,
}) =>
    (key != null &&
        () {
          final keyboard = HardwareKeyboard.instance;
          final logicalKeysPressed = keyboard.logicalKeysPressed;
          if (key == LogicalKeyboardKey.control) {
            return logicalKeysPressed.contains(LogicalKeyboardKey.control) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);
          }
          if (key == LogicalKeyboardKey.alt) {
            return logicalKeysPressed.contains(LogicalKeyboardKey.alt) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.altLeft) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.altRight);
          }
          if (key == LogicalKeyboardKey.meta) {
            return logicalKeysPressed.contains(LogicalKeyboardKey.meta) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.metaRight);
          }
          if (key == LogicalKeyboardKey.shift) {
            return logicalKeysPressed.contains(LogicalKeyboardKey.shift) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
                logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
          }
          return logicalKeysPressed.contains(key);
        }()) ||
    (keys != null &&
        HardwareKeyboard.instance.logicalKeysPressed
            .any((e) => isKeyPressed(key: e)));

/// 指定的按键, 是否都按下
bool isKeysPressedAll(
  List<LogicalKeyboardKey>? keys, {
  bool def = false,
}) =>
    isNil(keys)
        ? def
        : keys!.length == pressedKeyCount &&
            keys.all((key) => isKeyPressed(key: key));

/// 当前有多少按键被按下
int get pressedKeyCount => HardwareKeyboard.instance.logicalKeysPressed.length;

//--

/// 手势事件回调
typedef PointerAction = void Function(PointerEvent event);

/// 手指移动多少距离时, 视为移动
/// [kTouchSlop] 18.0
@dp
const double kTouchMoveSlop = 5;

extension EventIntEx on int {
  /// 是否是鼠标左键
  bool get isMouseLeftDown =>
      (this & kPrimaryMouseButton) == kPrimaryMouseButton;

  /// 是否是鼠标右键
  bool get isMouseRightDown =>
      (this & kSecondaryMouseButton) == kSecondaryMouseButton;

  /// 是否是鼠标中键,
  bool get isMouseMiddleDown =>
      (this & kMiddleMouseButton) == kMiddleMouseButton;
}

extension PointerEventEx on PointerEvent {
  /// 是否是手指类型事件
  /// [isMouseEventKind]
  /// [isTouchEventKind]
  /// [isTrackpadEventKind]
  bool get isTouchEventKind => kind == PointerDeviceKind.touch;

  /// 是否是触控板/托盘类型事件
  /// [isMouseEventKind]
  /// [isTouchEventKind]
  /// [isTrackpadEventKind]
  bool get isTrackpadEventKind => kind == PointerDeviceKind.trackpad;

  /// 是否是手指操作相关事件
  bool get isTouchPointerEvent =>
      synthesized == false /*非合成的事件*/ &&
      (isPointerDown || isPointerMove || isPointerFinish);

  /// 是否是非有效的操作事件
  bool get isInvalidEvent => synthesized || isPointerHover;

  /// 是否是按下事件
  bool get isPointerDown => this is PointerDownEvent;

  /// 是否是移动事件
  bool get isPointerMove => this is PointerMoveEvent;

  /// 是否是抬起事件
  bool get isPointerUp => this is PointerUpEvent;

  /// 是否是取消事件
  bool get isPointerCancel => this is PointerCancelEvent;

  /// 是否是鼠标悬停事件
  bool get isPointerHover => this is PointerHoverEvent;

  /// 是否完成
  bool get isPointerFinish => isPointerUp || isPointerCancel;

  /// 当前的事件与[other]之间, 是否超过了指定的移动阈值
  bool isMoveExceed(Offset? other, [double threshold = kTouchMoveSlop]) {
    if (other == null) {
      return false;
    }
    return (localPosition.dx - other.dx).abs() > threshold ||
        (localPosition.dy - other.dy).abs() > threshold;
  }

  //-- mouse event

  /// 是否是鼠标事件
  /// [isMouseEventKind]
  /// [isTouchEventKind]
  /// [isTrackpadEventKind]
  bool get isMouseEventKind => kind == PointerDeviceKind.mouse;

  /// 是否是鼠标左键, 只有在[PointerDownEvent]时才能确定
  bool get isMouseLeftDown => isMouseEventKind && buttons.isMouseLeftDown;

  /// 是否是鼠标右键, 只有在[PointerDownEvent]时才能确定
  bool get isMouseRightDown => isMouseEventKind && buttons.isMouseRightDown;

  /// 是否是鼠标中键, 只有在[PointerDownEvent]时才能确定
  bool get isMouseMiddleDown => isMouseEventKind && buttons.isMouseMiddleDown;

  /// 鼠标滚动事件[_TransformedPointerScrollEvent]
  bool get isMouseScrollEvent => this is PointerScrollEvent;

  /// [PointerScrollEvent]事件的鼠标当前滚动量
  /// 在使用的时候通常需要取反
  Offset get mouseScrollDelta => this is PointerScrollEvent
      ? (this as PointerScrollEvent).scrollDelta
      : Offset.zero;

  //-- trackpad event

  /// [PointerPanZoomStartEvent]
  /// [PointerPanZoomUpdateEvent]
  /// [PointerPanZoomEndEvent]
  bool get isPanZoomStart => this is PointerPanZoomStartEvent;

  /// [PointerPanZoomUpdateEvent.pan] 从开始到结束的偏移量
  /// [PointerPanZoomUpdateEvent.panDelta] 偏移增量
  ///
  /// [PointerPanZoomUpdateEvent.scale] 从开始到结束的缩放比例
  /// [PointerPanZoomUpdateEvent.rotation] 从开始到结束的旋转弧度
  ///
  bool get isPanZoomUpdate => this is PointerPanZoomUpdateEvent;

  double get panScale => this is PointerPanZoomUpdateEvent
      ? (this as PointerPanZoomUpdateEvent).scale
      : 1.0;

  bool get isPanZoomEnd => this is PointerPanZoomEndEvent;
}

extension KeyEventEx on KeyEvent {
  bool get isKeyDown => this is KeyDownEvent;

  bool get isKeyRepeat => this is KeyRepeatEvent;

  bool get isKeyDownOrRepeat => isKeyDown || isKeyRepeat;

  bool get isKeyUp => this is KeyUpEvent;

  /// 是否是空格键
  bool get isSpaceKey => isKeyboardKey(LogicalKeyboardKey.space);

  /// 是否是Ctrl键
  bool get isCtrlKey =>
      isKeyboardKey(LogicalKeyboardKey.control) ||
      isKeyboardKey(LogicalKeyboardKey.controlLeft) ||
      isKeyboardKey(LogicalKeyboardKey.controlRight);

  /// 是否是指定的按键
  bool isKeyboardKey(KeyboardKey key) => key == logicalKey;
}

/// 事件处理
mixin IHandlePointerEventMixin {
  /// 是否要激活手势事件处理, 需要在外层判断此属性的处理逻辑
  /// [PointerDispatchMixin]
  bool enableEventHandled = true;

  /// 第一个手指按下事件
  PointerEvent? firstDownEvent;
  PointerEvent? firstMoveEvent;
  PointerEvent? _firstLastMoveEvent;

  ///  第一个手指每次[PointerMoveEvent]事件的移动距离
  Offset firstMoveOffset = Offset.zero;

  @flagProperty
  bool _isFirstEventCancel = false;

  /// 标记, 第一个手指的事件是否处理了, 会在下次down时, 自动重置为false
  @flagProperty
  bool isFirstEventHandled = false;

  /// 是否临时忽略处理事件, 请在手势抬起/取消时, 重置为false
  @flagProperty
  bool ignoreEventHandle = false;

  /// 开始派发事件, 一定会调用
  @entryPoint
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (event is PointerDownEvent) {
      if (firstDownEvent == null || _isFirstEventCancel) {
        isFirstEventHandled = false;
        _isFirstEventCancel = false;
        firstDownEvent = event;
        _firstLastMoveEvent = event;
        dispatchFirstPointerEvent(dispatch, event);
      }
    } else if (event is PointerMoveEvent) {
      if (event.pointer == firstDownEvent?.pointer) {
        firstMoveOffset =
            event.localPosition - (_firstLastMoveEvent ?? event).localPosition;
        firstMoveEvent = event;
        _firstLastMoveEvent = event;
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      //ignoreHandle = false; //请手动重置
      if (event.pointer == firstDownEvent?.pointer) {
        _isFirstEventCancel = true;
      }
    }
  }

  /// 询问, 是否要拦截事件, 如果返回true, 则[onPointerEvent]执行, 并中断继续派发事件
  @property
  bool interceptPointerEvent(
      PointerDispatchMixin dispatch, PointerEvent event) {
    if (isFirstPointerEvent(dispatch, event)) {
      return onInterceptFirstPointerEvent(dispatch, event);
    }
    return false;
  }

  /// 处理事件, 返回true表示事件被处理了, 否则继续派发事件
  @property
  bool onPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (isFirstPointerEvent(dispatch, event)) {
      return onFirstPointerEvent(dispatch, event);
    }
    return false;
  }

  /// 当执行了回调[onPointerEvent]后, [ignoreEventHandle]被设为[true]时回调
  /// [ignoreEventHandle]
  @property
  void onIgnorePointerEvent(
      PointerDispatchMixin dispatch, PointerEvent event) {}

  //---

  /// 只回调第一个点的事件
  void dispatchFirstPointerEvent(
      PointerDispatchMixin dispatch, PointerEvent event) {}

  /// 只回调第一个点的事件
  bool onInterceptFirstPointerEvent(
          PointerDispatchMixin dispatch, PointerEvent event) =>
      false;

  /// 只回调第一个点的事件
  bool onFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) =>
      false;

  //---

  /// 是否是第一个手指的事件
  bool isFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) =>
      firstDownEvent?.pointer == event.pointer;

  /// 第一个手指, 移动的距离是否超过指定的阈值
  bool isFirstMoveExceed([double threshold = kTouchSlop]) {
    if (firstDownEvent == null || firstMoveEvent == null) return false;
    return firstDownEvent?.isMoveExceed(
            firstMoveEvent!.localPosition, threshold) ==
        true;
  }
}

/// 指针事件派发
///
/// [handleDispatchEvent]->将事件派发给[IHandlePointerEventMixin]
///                      1:[IHandlePointerEventMixin.dispatchPointerEvent]
///                      2:[IHandlePointerEventMixin.interceptPointerEvent]
///                      3:[IHandlePointerEventMixin.onPointerEvent]
///
mixin PointerDispatchMixin {
  /// 事件处理客户端列表
  Set<IHandlePointerEventMixin> handleEventClientList = {};

  /// 当前事件处理被此目标拦截
  IHandlePointerEventMixin? interceptHandleTarget;

  /// N个手指对应的事件
  Map<int, PointerEvent> pointerMap = {};

  /// 指定的手势, 是否要忽略处理
  Map<int, bool> ignorePointerMap = {};

  /// 当前按下的手指数量
  int get pointerCount => pointerMap.length;

  /// 派发事件, 入口点
  /// 事件分发到[handleEventClientList]客户端中
  /// 返回事件是否被处理了
  @entryPoint
  bool handleDispatchEvent(PointerEvent event) {
    if (isIgnorePointer(event)) {
      if (event.isPointerFinish) {
        ignoreHandlePointer(event, false);
      }
      return false;
    }

    if (!event.isInvalidEvent) {
      //非合成的事件
      pointerMap[event.pointer] = event;
    }
    final clientList = handleEventClientList
        .where((event) => event.enableEventHandled)
        .clone();

    //1:dispatchPointerEvent
    for (final element in clientList) {
      element.dispatchPointerEvent(this, event);
    }

    //2:interceptPointerEvent
    bool handled = false;
    if (interceptHandleTarget != null &&
        !interceptHandleTarget!.ignoreEventHandle) {
      if (interceptHandleTarget!.ignoreEventHandle) {
        //拦截器, 忽略了手势处理
        handled = true;
      } else {
        handled = interceptHandleTarget!.onPointerEvent(this, event);
        assert(() {
          if (event.isPointerDown) {
            l.v("手势(PointerDown)处理[$handled]->${interceptHandleTarget.runtimeType}");
          }
          return true;
        }());
      }
    } else {
      for (final element in clientList) {
        if (element.interceptPointerEvent(this, event)) {
          //debugger();
          interceptHandleTarget = element;
          assert(() {
            if (event.isPointerDown) {
              l.v("手势(PointerDown)被拦截->${interceptHandleTarget.runtimeType}");
            }
            return true;
          }());
          if (!element.ignoreEventHandle) {
            handled = element.onPointerEvent(this, event);
            assert(() {
              if (event.isPointerDown) {
                l.v("手势(PointerDown)处理[$handled]->${interceptHandleTarget.runtimeType}");
              }
              return true;
            }());
            break;
          }
        }
      }
      if (interceptHandleTarget != null && handled) {
        //事件被拦截, 而且处理了, 则其他接收器发送取消事件
        final cancelEvent = createPointerCancelEvent(event);
        for (var element in clientList) {
          if (element != interceptHandleTarget) {
            element.onPointerEvent(this, cancelEvent);
          }
        }
      }
      if (interceptHandleTarget == null || !handled) {
        //3:onPointerEvent
        for (final element in clientList) {
          if (!element.ignoreEventHandle) {
            handled = element.onPointerEvent(this, event);
            assert(() {
              if (event.isPointerDown) {
                l.v("手势(PointerDown)分发轮询处理[$handled]->${element.runtimeType}");
              }
              return true;
            }());
            if (element.ignoreEventHandle) {
              //此时忽略了, 则其他接收器发送取消事件
              element.onIgnorePointerEvent(this, event);
            }
          }
          if (handled) break;
        }
      }
    }

    //4:last
    if (event.isPointerFinish) {
      //debugger();
      pointerMap.remove(event.pointer);
      if (pointerMap.isEmpty) {
        interceptHandleTarget = null;
      }
    }
    return handled;
  }

  /// 添加事件处理
  void addHandleEventClient(IHandlePointerEventMixin handleEvent) {
    handleEventClientList.add(handleEvent);
  }

  /// 移除事件处理
  void removeHandleEventClient(IHandlePointerEventMixin handleEvent) {
    handleEventClientList.remove(handleEvent);
  }

  /// 是否忽略了指定手势的处理
  bool isIgnorePointer(PointerEvent event) =>
      ignorePointerMap[event.pointer] == true;

  /// 忽略指定手势的处理
  void ignoreHandlePointer(PointerEvent event, [bool ignore = true]) {
    ignorePointerMap[event.pointer] = ignore;
  }
}

/// 创建一个取消手势事件
/// [GestureBinding.instance]
/// [GestureBinding.cancelPointer]
PointerCancelEvent createPointerCancelEvent(PointerEvent event) {
  return PointerCancelEvent(
    pointer: event.pointer,
    kind: event.kind,
    device: event.device,
    position: event.position,
    timeStamp: event.timeStamp,
  );
}

/// 手势探测到的类型
enum TouchDetectorType {
  /// 点击事件
  click,

  /// 长按事件, 此时手势还未抬起
  longPress,
}

/// 点击/长按事件探测
mixin TouchDetectorMixin {
  /// 是否要检查长按事件
  bool checkLongPress = true;

  /// 是否激活长按保持回调
  /// 激活后, 每隔[loopLongPressDelay]毫秒触发一个长按
  bool enableLoopLongPress = false;

  /// [enableLoopLongPress]
  double loopLongPressDelay = 60;

  /// 长按循环触发器
  Timer? loopLongPressTimer;

  /// 超过此值的点视为无效
  @dp
  double touchDetectorSlop = kTouchSlop;

  /// 按下时长超过此值, 视为长按
  Duration touchLongPressTimeout = kLongPressTimeout;

  /// N个手指对应的按下事件
  final Map<int, PointerEvent> _pointerDownMap = {};

  /// N个手指的长按定时器
  final Map<int, Timer> _pointerLongMap = {};

  /// 入口方法, 添加手势事件
  @entryPoint
  void addTouchDetectorPointerEvent(PointerEvent event) {
    final pointer = event.pointer;
    if (event.isPointerDown) {
      loopLongPressTimer?.cancel();
      loopLongPressTimer = null;
      _pointerDownMap[pointer] = event;
      if (checkLongPress) {
        _pointerLongMap[pointer] = Timer(touchLongPressTimeout, () {
          _checkLongPress(event);
        });
      }
    } else if (event.isPointerMove) {
      //手势移动一定距离后,移除长按事件探测
      if (event.isMoveExceed(
          _pointerDownMap[pointer]?.localPosition, touchDetectorSlop)) {
        _clearLongPress(pointer);
      }
    } else if (event.isPointerUp) {
      _checkClick(event);
    }
    if (event.isPointerFinish) {
      loopLongPressTimer?.cancel();
      loopLongPressTimer = null;
      _clear(event);
    }
  }

  /// 处理点击/长按事件
  /// [touchType] 事件类型,
  ///  [TouchDetectorType.click] 点击事件
  ///  [TouchDetectorType.longPress] 长按事件
  @overridePoint
  bool onTouchDetectorPointerEvent(
          PointerEvent event, TouchDetectorType touchType) =>
      false;

  /// 检查当前的手势, 是否应该触发点击事件
  void _checkClick(PointerEvent event) {
    final downEvent = _pointerDownMap[event.pointer];
    if (downEvent == null ||
        event.isMoveExceed(downEvent.localPosition, touchDetectorSlop)) {
      //超出了移动范围
      return;
    }
    onTouchDetectorPointerEvent(event, TouchDetectorType.click);
  }

  /// 检查是否需要触发长按事件回调
  void _checkLongPress(PointerEvent event) {
    final downEvent = _pointerDownMap[event.pointer];
    if (downEvent == null ||
        event.isMoveExceed(downEvent.localPosition, touchDetectorSlop)) {
      //超出了移动范围
      return;
    }
    onTouchDetectorPointerEvent(event, TouchDetectorType.longPress);
    if (enableLoopLongPress) {
      loopLongPressTimer?.cancel();
      loopLongPressTimer = null;
      loopLongPressTimer =
          Timer.periodic(loopLongPressDelay.milliseconds, (timer) {
        onTouchDetectorPointerEvent(event, TouchDetectorType.longPress);
      });
    }
    _clear(event);
  }

  /// 清理指定手指的数据
  void _clear(PointerEvent event) {
    final pointer = event.pointer;
    _pointerDownMap.remove(pointer);
    _clearLongPress(pointer);
  }

  /// 清理指定手指的长按事件定时器
  void _clearLongPress(int pointer) {
    _pointerLongMap[pointer]?.cancel();
    _pointerLongMap.remove(pointer);
  }
}

/// 双击探测
mixin DoubleTapDetectorMixin {
  /// 双击间隔时间
  /// [kDoubleTapTimeout]
  /// [kDoubleTapMinTime]
  Duration doubleTapTime = kDoubleTapTimeout;

  /// 2次手指之间的距离不能超过此值
  @dp
  double doubleTapThreshold = kTouchSlop;

  /// 上一次按下的时间
  DateTime lastDownTime = 0.toDateTime();

  /// 上一次按下的位置
  Offset lastDownPoint = Offset.zero;

  /// 记录按下时的鼠标按键
  /// [PointerDownEvent.buttons]
  int lastDownButtons = 0;

  /// 双击检测时, 是否是第一次触摸
  bool isDoubleFirstTouch = true;

  @entryPoint
  void addDoubleTapDetectorPointerEvent(PointerEvent event) {
    final point = event.localPosition;
    final nowTime = DateTime.now();
    if (event.isPointerDown) {
      isDoubleFirstTouch = nowTime.difference(lastDownTime) > doubleTapTime ||
          (point.dx - lastDownPoint.dx).abs() > doubleTapThreshold ||
          (point.dy - lastDownPoint.dy).abs() > doubleTapThreshold;

      if (isDoubleFirstTouch) {
        lastDownTime = DateTime.now();
        lastDownPoint = point;
        lastDownButtons = event.buttons;
      }
    } else if (event.isPointerUp) {
      if (!isDoubleFirstTouch) {
        //debugger();
        if ((point.dx - lastDownPoint.dx).abs() < doubleTapThreshold &&
            (point.dy - lastDownPoint.dy).abs() < doubleTapThreshold) {
          //触发双击事件
          onDoubleTapDetectorPointerEvent(event);
        }
        isDoubleFirstTouch = true;
        lastDownButtons = 0;
      }
    } else if (event.isPointerCancel) {
      isDoubleFirstTouch = true;
      lastDownButtons = 0;
    }
  }

  /// 处理双击事件
  @overridePoint
  bool onDoubleTapDetectorPointerEvent(PointerEvent event) => false;
}

/// 多指探测
mixin MultiPointerDetectorMixin {
  /// 获取N个手势对应的包裹矩形
  @dp
  static Rect getPointerBounds(Map<int, PointerEvent> pointerMap) {
    if (pointerMap.isEmpty) {
      return Rect.zero;
    }
    double left = doubleMaxValue;
    double top = doubleMaxValue;
    double right = doubleMinValue;
    double bottom = doubleMinValue;

    pointerMap.forEach((key, value) {
      left = math.min(left, value.localPosition.dx);
      top = math.min(top, value.localPosition.dy);
      right = math.max(right, value.localPosition.dx);
      bottom = math.max(bottom, value.localPosition.dy);
    });

    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// 获取每个手指之间的移动距离
  /// [pointerMoveMap] 当前移动时的点
  /// [pointerDownMap] 当前按下的点
  /// [pointerDownMap2] 最开始按下的点
  @dp
  static List<Offset> getPointerDeltaList(Map<int, PointerEvent> pointerMoveMap,
      Map<int, PointerEvent> pointerDownMap,
      [Map<int, PointerEvent>? pointerDownMap2]) {
    if (pointerMoveMap.isEmpty || pointerDownMap.isEmpty) {
      return [];
    }
    List<Offset> result = [];
    pointerMoveMap.forEach((key, move) {
      var down = pointerDownMap[key] ?? pointerDownMap2?[key];
      if (down != null) {
        double dx = move.localPosition.dx - down.localPosition.dx;
        double dy = move.localPosition.dy - down.localPosition.dy;
        result.add(Offset(dx, dy));
      }
    });
    return result;
  }

  /// 获取每个手指的位置
  @dp
  static List<Offset> getPointerPositionList(
      Map<int, PointerEvent> pointerMap) {
    List<Offset> result = [];
    pointerMap.forEach((key, pointer) {
      result.add(pointer.localPosition);
    });
    return result;
  }

  /// 是否已经处理了事件, 会在手势抬起/取消时, 重置为false
  bool isHandledMultiPointerDetectorEvent = false;

  /// 按下的点
  final Map<int, PointerEvent> pointerDownMap = {};

  /// 当前移动时的点
  final Map<int, PointerEvent> pointerMoveMap = {};

  /// 上一次移动时的坐标
  final Map<int, PointerEvent> pointerMoveLastMap = {};

  /// 当前手指的数量
  int get pointerCount =>
      math.min(pointerDownMap.length, pointerMoveMap.length);

  @entryPoint
  void addMultiPointerDetectorPointerEvent(PointerEvent event) {
    if (!event.isTouchPointerEvent) {
      return;
    }
    //1---
    var pointer = event.pointer;
    if (event.isPointerDown) {
      //手势按下
      pointerDownMap[pointer] = event;
      pointerMoveMap[pointer] = event;
      pointerMoveLastMap[pointer] = event;
      startCheckMultiLongPress();
    } else if (event.isPointerMove) {
      //手势移动
      pointerMoveMap[pointer] = event;
      if (isEnableMultiLongPress) {
        if (isHaveMoveDeltaExceedX(isSameDirection: false) ||
            isHaveMoveDeltaExceedY(isSameDirection: false)) {
          //有手势移动, 取消长按检查
          stopCheckMultiLongPress();
        }
      }
    } else if (event.isPointerFinish) {
      //有手势抬起, 取消长按检查
      stopCheckMultiLongPress();
    }
    //2---
    if (handleMultiPointerDetectorPointerEvent(event)) {
      //处理了事件, 将down坐标更新
      isHandledMultiPointerDetectorEvent = true;

      resetPointerMap(pointerDownMap, pointerMoveMap);
    }
    pointerMoveLastMap[pointer] = event;
    //3---
    if (event.isPointerFinish) {
      removePointer(event);
    }
    if (isHandledMultiPointerDetectorEvent && pointerDownMap.isEmpty) {
      isHandledMultiPointerDetectorEvent = false;
    }
  }

  /// 处理多指操作事件
  @overridePoint
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) => false;

  /// 重置数据
  void resetPointerMap(Map from, Map to) {
    from.clear();
    from.addAll(to);
  }

  /// 第一个手指移动的距离
  Offset firstMoveDownDelta() {
    final first = pointerDownMap.keys.first;
    final move = pointerMoveMap[first];
    final down = pointerDownMap[first];
    if (move != null && down != null) {
      return move.localPosition - down.localPosition;
    }
    return Offset.zero;
  }

  /// 当前移动的手势与按下的手势, 之间的偏移
  Offset minMoveDownDelta() {
    final offsetList = getPointerDeltaList(pointerMoveMap, pointerDownMap);
    if (offsetList.isNotEmpty) {
      //返回最小的偏移
      return offsetList.reduce((value, element) {
        if (value.dx < element.dx || value.dy < element.dy) {
          return value;
        }
        return element;
      });
    }
    return Offset.zero;
  }

  /// 第一个手指移动的距离
  Offset firstMoveLastDelta() {
    final first = pointerDownMap.keys.first;
    final move = pointerMoveMap[first];
    final down = pointerMoveLastMap[first] ?? pointerDownMap[first];
    if (move != null && down != null) {
      return move.localPosition - down.localPosition;
    }
    return Offset.zero;
  }

  /// 当前移动的手势与上一次移动的手势, 之间的偏移
  Offset moveLastDelta() {
    final offsetList =
        getPointerDeltaList(pointerMoveMap, pointerMoveLastMap, pointerDownMap);
    if (offsetList.isNotEmpty) {
      //返回最小的偏移
      return offsetList.reduce((value, element) {
        if (value.dx < element.dx || value.dy < element.dy) {
          return value;
        }
        return element;
      });
    }
    return Offset.zero;
  }

  /// 指定的手指, 移动的距离是否超过指定的阈值
  /// [PointerEventEx.isMoveExceed]
  bool isPointerMoveExceed(int pointer, [double threshold = kTouchSlop]) {
    final move = pointerMoveMap[pointer];
    final down = pointerDownMap[pointer];
    if (move != null && down != null) {
      return (move.localPosition.dx - down.localPosition.dx).abs() > threshold;
    }
    return false;
  }

  /// 所有手指横向移动的距离是否大于指定的阈值, 并且是同方向的
  /// [isSameDirection] 是否是同方向
  /// [kTouchSlop]
  bool isAllMoveDeltaExceedX({
    double threshold = kTouchSlop,
    bool isSameDirection = true,
  }) {
    final offsetList = getPointerDeltaList(pointerMoveMap, pointerDownMap);
    if (offsetList.isNotEmpty) {
      int? direction;
      for (var offset in offsetList) {
        if (offset.dx.abs() < threshold) {
          //x轴移动距离不够
          return false;
        }
        if (isSameDirection) {
          //还需要判断同方向
          int d = offset.dx > 0 ? 1 : -1;
          direction ??= d;
          if (direction != d) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }

  /// 所有手指纵向移动的距离是否大于指定的阈值, 并且是同方向的
  /// [kTouchSlop]
  bool isAllMoveDeltaExceedY({
    double threshold = kTouchSlop,
    bool isSameDirection = true,
  }) {
    final offsetList = getPointerDeltaList(pointerMoveMap, pointerDownMap);
    if (offsetList.isNotEmpty) {
      int? direction;
      for (var offset in offsetList) {
        if (offset.dy.abs() < threshold) {
          //y轴移动距离不够
          return false;
        }
        if (isSameDirection) {
          //还需要判断同方向
          int d = offset.dy > 0 ? 1 : -1;
          direction ??= d;
          if (direction != d) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }

  /// 判断是否有手指在横向的移动距离达到阈值
  /// [isHaveMoveDeltaExceedX]
  /// [isHaveMoveDeltaExceedY]
  bool isHaveMoveDeltaExceedX({
    double threshold = kTouchSlop,
    bool isSameDirection = false,
  }) {
    final offsetList = getPointerDeltaList(pointerMoveMap, pointerDownMap);
    if (offsetList.isNotEmpty) {
      int? direction;
      for (var offset in offsetList) {
        if (offset.dx.abs() >= threshold) {
          //y轴移动距离超过阈值
          if (isSameDirection) {
            //还需要判断同方向
            int d = offset.dx > 0 ? 1 : -1;
            direction ??= d;
            if (direction != d) {
              return false;
            }
          } else {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// 判断是否有手指在纵向的移动距离达到阈值
  /// [isHaveMoveDeltaExceedX]
  /// [isHaveMoveDeltaExceedY]
  bool isHaveMoveDeltaExceedY({
    double threshold = kTouchSlop,
    bool isSameDirection = false,
  }) {
    final offsetList = getPointerDeltaList(pointerMoveMap, pointerDownMap);
    if (offsetList.isNotEmpty) {
      int? direction;
      for (var offset in offsetList) {
        if (offset.dy.abs() >= threshold) {
          //y轴移动距离超过阈值
          if (isSameDirection) {
            //还需要判断同方向
            int d = offset.dy > 0 ? 1 : -1;
            direction ??= d;
            if (direction != d) {
              return false;
            }
          } else {
            return true;
          }
        }
      }
    }
    return false;
  }

  //--

  /// 移除指针缓存
  void removePointer(PointerEvent event) {
    final pointer = event.pointer;
    pointerDownMap.remove(pointer);
    pointerMoveMap.remove(pointer);
    pointerMoveLastMap.remove(pointer);
  }

  /// 移除所有指针缓存
  void removeAllPointer() {
    pointerDownMap.clear();
    pointerMoveMap.clear();
    pointerMoveLastMap.clear();
  }

  // ---多指长按检测---

  /// 多指长按检测时长, 同时也是开启此功能的标志
  Duration? multiLongPressDuration;

  Timer? _multiLongPressTimer;

  /// 是否开启多指同时长按检测
  bool get isEnableMultiLongPress => multiLongPressDuration != null;

  /// 开始检查多指同时长按
  /// [kTouchSlop]
  void startCheckMultiLongPress() {
    stopCheckMultiLongPress();
    final duration = multiLongPressDuration;
    if (duration == null) {
      return;
    }
    final timer = Timer(duration, () {
      stopCheckMultiLongPress();
      onSelfMultiLongPress();
    });
    _multiLongPressTimer = timer;
  }

  /// 停止检查长按
  void stopCheckMultiLongPress() {
    _multiLongPressTimer?.cancel();
    _multiLongPressTimer = null;
  }

  /// 多指同时长按事件触发
  @overridePoint
  void onSelfMultiLongPress() {}
}

/// fling 快速滑动探测
/// [DragGestureRecognizer._velocityTrackers]
/// [DragGestureRecognizer._defaultBuilder]
/// [DragGestureRecognizer.isFlingGesture]
mixin FlingDetectorMixin {
  /// 每个手指的速度追踪器
  final Map<int, VelocityTracker> velocityTrackersMap = {};

  @entryPoint
  void addFlingDetectorPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      velocityTrackersMap[event.pointer] = VelocityTracker.withKind(event.kind);
    }

    //1
    final tracker = velocityTrackersMap[event.pointer];
    tracker?.addPosition(event.timeStamp, event.localPosition);

    //2
    if (tracker != null && event is PointerUpEvent) {
      final velocity = tracker.getVelocity();
      if (handleFlingDetectorPointerEvent(event, velocity)) {
        velocityTrackersMap.remove(event.pointer);
      }
    }

    //3
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      velocityTrackersMap.remove(event.pointer);
    }
  }

  /// 当手势抬起时, 处理是否需要快速滑动事件
  @overridePoint
  bool handleFlingDetectorPointerEvent(PointerEvent event, Velocity velocity) {
    velocity.pixelsPerSecond;
    return false;
  }

  /// 开始快速滑动
  /// [ScrollUpdateNotification]
  /// [ScrollStartNotification]
  /// [OverscrollNotification]
  /// [ScrollPosition.setPixels]
  /// [ScrollPosition.didOverscrollBy]
  /// [BouncingScrollPhysics.applyPhysicsToUserOffset]
  ///
  /// [ClampingScrollSimulation]
  /// [BouncingScrollSimulation]
  @api
  AnimationController startFling(
    void Function(double value) flingAction, {
    required TickerProvider vsync,
    required double fromValue,
    required double velocity,
    Duration duration = const Duration(seconds: 1),
  }) {
    /*final physics = const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
    final Simulation? simulation = physics.createBallisticSimulation(vsync, velocity);*/
    final simulation =
        ClampingScrollSimulation(position: fromValue, velocity: velocity);
    return animation(vsync, (value, isCompleted) {
      //debugger();
      final x = simulation.x(duration.inSeconds * value);
      //l.d('fling $isCompleted :$value x:$x');
      flingAction(x);
    }, duration: duration);
  }

  /// 开始快速滑动
  /// [AnimationController] 实现的fling必须从当前值开始, 到指定值结束
  @api
  @implementation
  AnimationController startAnimationFling({
    required TickerProvider vsync,
    required double fromValue,
    required double velocity,
    Duration duration = const Duration(seconds: 1),
    SpringDescription? springDescription,
    AnimationBehavior? animationBehavior,
  }) {
    AnimationController controller = AnimationController(
      value: fromValue,
      vsync: vsync,
      lowerBound: doubleMinValue,
      upperBound: doubleMaxValue,
      duration: duration,
      debugLabel: '快速滑动:$fromValue :$velocity $duration',
    );
    if (isDebug) {
      controller.addStatusListener((status) {
        l.d('fling status:$status');
      });
      controller.addListener(() {
        l.d('fling value:${controller.value}');
      });
    }
    debugger();
    controller.fling(
        velocity: velocity,
        springDescription: springDescription,
        animationBehavior: animationBehavior);
    return controller;
  }
}
