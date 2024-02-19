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
}
