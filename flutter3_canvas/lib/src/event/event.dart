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

mixin HandleEventMixin on IHandleEvent {

  /// 是否忽略处理事件
  bool ignoreHandle = false;

  @override
  void dispatchPointerEvent(PointerEvent event) {

  }

  @override
  bool interceptPointerEvent(PointerEvent event) => false;

  @override
  bool onPointerEvent(PointerEvent event) => false;
}