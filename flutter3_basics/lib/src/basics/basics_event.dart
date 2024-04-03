part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/30
///

/// 手势事件回调
typedef PointerAction = void Function(PointerEvent event);

/// 手指移动多少距离时, 视为移动
/// [kTouchSlop] 18.0
@dp
const double kTouchMoveSlop = 5;

extension EventEx on PointerEvent {
  /// 是否是手指操作相关事件
  bool get isTouchEvent =>
      synthesized == false /*非合成的事件*/ &&
      (isPointerDown || isPointerMove || isPointerFinish);

  /// 是否是按下事件
  bool get isPointerDown => this is PointerDownEvent;

  /// 是否是移动事件
  bool get isPointerMove => this is PointerMoveEvent;

  /// 是否是抬起事件
  bool get isPointerUp => this is PointerUpEvent;

  /// 是否是取消事件
  bool get isPointerCancel => this is PointerCancelEvent;

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
}

/// 事件处理
mixin IHandleEventMixin {
  /// 是否要激活手势事件处理, 需要在外层判断
  /// [PointerDispatchMixin]
  bool enableEventHandled = true;

  /// 第一个手指按下事件
  PointerEvent? firstDownEvent;
  PointerEvent? firstMoveEvent;
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
        dispatchFirstPointerEvent(dispatch, event);
      }
    } else if (event is PointerMoveEvent) {
      if (event.pointer == firstDownEvent?.pointer) {
        firstMoveEvent = event;
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
mixin PointerDispatchMixin {
  /// 事件处理客户端列表
  Set<IHandleEventMixin> handleEventClientList = {};

  /// 当前事件处理被此目标拦截
  IHandleEventMixin? interceptHandleTarget;

  /// N个手指对应的事件
  Map<int, PointerEvent> pointerMap = {};

  /// 指定的手势, 是否要忽略处理
  Map<int, bool> ignorePointerMap = {};

  /// 当前按下的手指数量
  int get pointerCount => pointerMap.length;

  /// 派发事件, 入口点
  /// 返回事件是否被处理了
  @entryPoint
  bool handleDispatchEvent(PointerEvent event) {
    if (isIgnorePointer(event)) {
      if (event.isPointerFinish) {
        ignoreHandlePointer(event, false);
      }
      return false;
    }

    if (!event.synthesized) {
      //非合成的事件
      pointerMap[event.pointer] = event;
    }
    final clientList = handleEventClientList
        .where((event) => event.enableEventHandled)
        .clone();

    //1:dispatchPointerEvent
    for (var element in clientList) {
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
      }
    } else {
      for (var element in clientList) {
        if (element.interceptPointerEvent(this, event)) {
          //debugger();
          interceptHandleTarget = element;
          if (!element.ignoreEventHandle) {
            handled = element.onPointerEvent(this, event);
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
        for (var element in clientList) {
          if (!element.ignoreEventHandle) {
            handled = element.onPointerEvent(this, event);
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
  void addHandleEventClient(IHandleEventMixin handleEvent) {
    handleEventClientList.add(handleEvent);
  }

  /// 移除事件处理
  void removeHandleEventClient(IHandleEventMixin handleEvent) {
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

/// 点击/长按事件探测
mixin TouchDetectorMixin {
  /// 点击事件
  static const int sTouchTypeClick = 1;

  /// 长按事件, 此时手势还未抬起
  static const int sTouchTypeLongPress = 2;

  /// 是否要检查长按事件
  bool checkLongPress = true;

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
      _pointerDownMap[pointer] = event;
      if (checkLongPress) {
        _pointerLongMap[pointer] = Timer(touchLongPressTimeout, () {
          _checkLongPress(event);
        });
      }
    } else if (event.isPointerUp) {
      _checkClick(event);
    }
    if (event.isPointerFinish) {
      _clear(event);
    }
  }

  /// 处理点击事件
  @overridePoint
  bool onTouchDetectorPointerEvent(PointerEvent event, int touchType) => false;

  void _checkClick(PointerEvent event) {
    final downEvent = _pointerDownMap[event.pointer];
    if (downEvent == null ||
        event.isMoveExceed(downEvent.localPosition, touchDetectorSlop)) {
      //超出了移动范围
      return;
    }
    onTouchDetectorPointerEvent(event, sTouchTypeClick);
  }

  /// 检查是否需要触发长按事件回调
  void _checkLongPress(PointerEvent event) {
    final downEvent = _pointerDownMap[event.pointer];
    if (downEvent == null ||
        event.isMoveExceed(downEvent.localPosition, touchDetectorSlop)) {
      //超出了移动范围
      return;
    }
    onTouchDetectorPointerEvent(event, sTouchTypeLongPress);
    _clear(event);
  }

  /// 清理指定手指的数据
  void _clear(PointerEvent event) {
    var pointer = event.pointer;
    _pointerDownMap.remove(pointer);
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
      }
    } else if (event.isPointerCancel) {
      isDoubleFirstTouch = true;
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
    //1---
    if (event.isPointerDown) {
      //手势按下
      pointerDownMap[event.pointer] = event;
      pointerMoveMap[event.pointer] = event;
      pointerMoveLastMap[event.pointer] = event;
    } else if (event.isPointerMove) {
      //手势移动
      pointerMoveMap[event.pointer] = event;
    }
    //2---
    if (handleMultiPointerDetectorPointerEvent(event)) {
      //处理了事件, 将down坐标更新
      isHandledMultiPointerDetectorEvent = true;

      resetPointerMap(pointerDownMap, pointerMoveMap);
    }
    pointerMoveLastMap[event.pointer] = event;
    //3---
    if (event.isPointerFinish) {
      pointerDownMap.remove(event.pointer);
      pointerMoveMap.remove(event.pointer);
      pointerMoveLastMap.remove(event.pointer);
    }
    if (isHandledMultiPointerDetectorEvent && pointerDownMap.isEmpty) {
      isHandledMultiPointerDetectorEvent = false;
    }
  }

  /// 重置数据
  void resetPointerMap(Map from, Map to) {
    from.clear();
    from.addAll(to);
  }

  /// 处理多指操作事件
  @overridePoint
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) => false;

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

  /// 所有手指移动的距离是否大于指定的阈值, 并且是同方向的
  /// [isSameDirection] 是否是同方向
  bool isAllMoveDeltaExceedX(double threshold, [bool isSameDirection = true]) {
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

  bool isAllMoveDeltaExceedY(double threshold, [bool isSameDirection = true]) {
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
      l.d('fling $isCompleted :$value x:$x');
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
