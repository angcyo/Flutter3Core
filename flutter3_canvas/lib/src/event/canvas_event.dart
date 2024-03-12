part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/18
///
/// 简单的事件处理混入, 支持[ignoreEventHandle]
mixin HandleEventMixin on IHandleEventMixin, MultiPointerDetectorMixin {
  @override
  void dispatchPointerEvent(PointerEvent event) {
    super.dispatchPointerEvent(event);
    if (!ignoreEventHandle) {
      //没有忽略事件
      addMultiPointerDetectorPointerEvent(event);
    }
    if (event.isPointerFinish) {
      ignoreEventHandle = false;
    }
  }
}
