part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/21
///
/// [IElementPainter] 响应手势事件客户端处理器
///
/// - [PointerDispatchMixin]
/// - [IHandlePointerEventMixin]
mixin IPainterEventHandlerMixin {
  /// 是否激活指针事件处理
  bool isEnablePainterPointerEvent() => true;

  /// 是否需要拦截事件, 拦截之后一定会触发[handlePainterPointerEvent]
  /// - 否则只有在没有其它客户端处理事件时才会触发[handlePainterPointerEvent]
  @overridePoint
  bool interceptPainterPointerEvent(@viewCoordinate PointerEvent event) =>
      false;

  /// 响应手势事件
  @overridePoint
  bool handlePainterPointerEvent(@viewCoordinate PointerEvent event) => false;
}

/// [IElementPainter] 响应手势悬停事件客户端处理器
mixin IPainterHoverHandlerMixin {
  /// 处理悬停事件
  /// @return 是否处理了事件, 鼠标样式
  @overridePoint
  (bool, MouseCursor?) handlePointerHover(
    @viewCoordinate PointerEvent event,
    bool hover,
  );
}
