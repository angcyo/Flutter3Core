part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/18
///

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
