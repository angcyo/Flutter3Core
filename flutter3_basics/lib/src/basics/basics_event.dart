part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/30
///

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
}

/// 事件处理
abstract class IHandleEvent {
  /// 开始派发事件, 一定会调用
  void dispatchPointerEvent(PointerEvent event) {}

  /// 询问, 是否要拦截事件, 如果返回true, 则[onPointerEvent]执行, 并中断继续派发事件
  bool interceptPointerEvent(PointerEvent event) => false;

  /// 处理事件, 返回true表示事件被处理了, 否则继续派发事件
  bool onPointerEvent(PointerEvent event) => false;
}

/// 指针事件派发
mixin PointerDispatchMixin {
  /// 事件处理客户端列表
  Set<IHandleEvent> handleEventClientList = {};

  /// 当前事件处理被此目标拦截
  IHandleEvent? interceptHandleTarget;

  /// N个手指对应的事件
  Map<int, PointerEvent> pointerMap = {};

  /// 派发事件, 入口点
  /// 返回事件是否被处理了
  @entryPoint
  bool handleDispatchEvent(PointerEvent event) {
    pointerMap[event.pointer] = event;

    //1:dispatchPointerEvent
    handleEventClientList.toList(growable: false).forEach((element) {
      element.dispatchPointerEvent(event);
    });

    //2:interceptPointerEvent
    bool handled = false;
    if (interceptHandleTarget != null) {
      handled = interceptHandleTarget!.onPointerEvent(event);
    } else {
      final iterable = handleEventClientList.toList(growable: false);
      for (var element in iterable) {
        if (element.interceptPointerEvent(event)) {
          interceptHandleTarget = element;
          handled = element.onPointerEvent(event);
          break;
        }
      }
      if (interceptHandleTarget == null || !handled) {
        //3:onPointerEvent
        for (var element in iterable) {
          handled = element.onPointerEvent(event);
          if (handled) break;
        }
      }
    }

    //4:last
    if (event.isPointerFinish) {
      pointerMap.remove(event.pointer);
      if (pointerMap.isEmpty) {
        interceptHandleTarget = null;
      }
    }
    return handled;
  }

  /// 添加事件处理
  void addHandleEventClient(IHandleEvent handleEvent) {
    handleEventClientList.add(handleEvent);
  }

  /// 移除事件处理
  void removeHandleEventClient(IHandleEvent handleEvent) {
    handleEventClientList.remove(handleEvent);
  }
}

/// 创建一个取消手势事件
/// [GestureBinding.instance]
/// [GestureBinding.cancelPointer]
PointerCancelEvent createPointerCancelEvent(PointerEvent event) {
  return const PointerCancelEvent(
    timeStamp: Duration.zero,
    kind: PointerDeviceKind.touch,
    device: 0,
    pointer: 1,
  );
}

/// 多指探测
mixin MultiPointerDetector {
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
  @dp
  static List<Offset> getPointerDeltaList(Map<int, PointerEvent> pointerMoveMap,
      Map<int, PointerEvent> pointerDownMap) {
    if (pointerMoveMap.isEmpty || pointerDownMap.isEmpty) {
      return [];
    }
    List<Offset> result = [];
    pointerMoveMap.forEach((key, move) {
      var down = pointerDownMap[key];
      if (down != null) {
        double dx = move.localPosition.dx - down.localPosition.dx;
        double dy = move.localPosition.dy - down.localPosition.dy;
        result.add(Offset(dx, dy));
      }
    });
    return result;
  }

  /// 是否已经处理了事件, 会在手势抬起/取消时, 重置为false
  bool isHandledEvent = false;

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
  void addPointerEvent(PointerEvent event) {
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
    if (handlePointerEvent(event)) {
      //处理了事件, 将down坐标更新
      isHandledEvent = true;

      pointerDownMap.clear();
      pointerDownMap.addAll(pointerMoveMap);
    }
    pointerMoveLastMap[event.pointer] = event;
    //3---
    if (event.isPointerFinish) {
      pointerDownMap.remove(event.pointer);
      pointerMoveMap.remove(event.pointer);
      pointerMoveLastMap.remove(event.pointer);
    }
    if (isHandledEvent && pointerDownMap.isEmpty) {
      isHandledEvent = false;
    }
  }

  /// 处理事件
  bool handlePointerEvent(PointerEvent event) => false;

  /// 当前移动的手势与按下的手势, 之间的偏移
  Offset moveDownDelta() {
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

  /// 当前移动的手势与上一次移动的手势, 之间的偏移
  Offset moveLastDelta() {
    final offsetList = getPointerDeltaList(pointerMoveMap, pointerMoveLastMap);
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
}
