part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/21
///
/// [IElementPainter] 响应手势事件客户端处理器
mixin IPainterEventHandlerMixin {
  /// 是否激活指针事件处理
  bool isEnablePointerEvent() => true;

  /// 响应手势事件
  @overridePoint
  bool handlePointerEvent(@viewCoordinate PointerEvent event);
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
