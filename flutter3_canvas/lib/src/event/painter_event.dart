part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/21
///
/// [IElementPainter] 响应手势事件客户端处理器
abstract interface class IPainterEventHandler {
  /// 响应手势事件
  @overridePoint
  bool handlePointerEvent(@viewCoordinate PointerEvent event);
}
