part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/18
///

abstract class IHandleEvent {
  /// 开始派发事件, 一定会调用
  void dispatchPointerEvent(PointerEvent event) {}

  /// 询问, 是否要拦截事件, 如果返回true, 则[onPointerEvent]执行, 并中断继续派发事件
  bool interceptPointerEvent(PointerEvent event) => false;

  /// 处理事件, 返回true表示事件被处理了, 否则继续派发事件
  bool onPointerEvent(PointerEvent event) => false;
}

/// 指针事件派发
class PointerDispatch {
  Set<IHandleEvent> handleEventList = {};

  /// 派发事件, 入口点
  @entryPoint
  void handleEvent(PointerEvent event) {}

  /// 添加事件处理
  void addHandleEvent(IHandleEvent handleEvent) {
    handleEventList.add(handleEvent);
  }

  /// 移除事件处理
  void removeHandleEvent(IHandleEvent handleEvent) {
    handleEventList.remove(handleEvent);
  }
}

mixin HandleEventMixin on IHandleEvent, MultiPointerDetector {
  /// 是否忽略处理事件, 会在手势抬起/取消时, 重置为false
  bool ignoreHandle = false;

  @override
  void dispatchPointerEvent(PointerEvent event) {
    if (!ignoreHandle) {
      //没有忽略事件
      addPointerEvent(event);
    }
    if (event.isPointerFinish) {
      ignoreHandle = false;
    }
  }

  @override
  bool interceptPointerEvent(PointerEvent event) => false;

  @override
  bool onPointerEvent(PointerEvent event) => false;
}
