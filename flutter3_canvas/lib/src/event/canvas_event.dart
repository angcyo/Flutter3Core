part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/18
///
/// 简单的事件处理混入, 支持[ignoreHandle]
mixin HandleEventMixin on IHandleEventMixin, MultiPointerDetectorMixin {
  @override
  void dispatchPointerEvent(PointerEvent event) {
    super.dispatchPointerEvent(event);
    if (!ignoreHandle) {
      //没有忽略事件
      addMultiPointerDetectorPointerEvent(event);
    }
    if (event.isPointerFinish) {
      ignoreHandle = false;
    }
  }
}
