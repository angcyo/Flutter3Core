part of flutter3_canvas;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/04
/// 手势入口
class CanvasEventManager {
  final CanvasDelegate canvasDelegate;

  CanvasEventManager(this.canvasDelegate);

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    canvasDelegate.canvasViewBox.translateBy(event.delta.dx, event.delta.dy);
  }
}

abstract class IHandleEvent {
  /// 开始派发事件
  void dispatchPointerEvent(PointerEvent event);

  /// 询问, 是否要拦截事件, 如果返回true, 则不会继续派发事件
  bool interceptPointerEvent(PointerEvent event);

  /// 处理事件, 返回true表示事件被处理了, 否则继续派发事件
  bool onPointerEvent(PointerEvent event);
}
