part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/27
///
/// 在[ElementOverlayControl]中使用的元素自定义控制点混入
///
/// 混入此类, 实现自定义的控制点
///
mixin PainterOverlayControlMixin on ElementPainter {
  //MARK: - core

  /// 更新控制点坐标
  /// - [ElementOverlayControl.updatePaintControlBounds] 驱动
  @overridePoint
  void updateOverlayControlBounds(PaintProperty? selectComponentProperty) {}

  //MARK: - paint

  /// 绘制入口
  /// - [ElementOverlayControl.paintControl] 驱动
  @overridePoint
  void paintOverlayControl(Canvas canvas, PaintMeta paintMeta) {
    /*canvas.drawRect(
      Rect.fromLTWH(100, 100, 200, 300),
      Paint()..color = Colors.red,
    );*/
  }

  //MARK: - IHandlePointerEventMixin

  /// 手势入口
  /// - [ElementOverlayControl.dispatchPointerEvent] 驱动
  @overridePoint
  void dispatchOverlayControlPointerEvent(
    PointerDispatchMixin dispatch,
    PointerEvent event,
  ) {}

  /// 拦截手势
  /// - [ElementOverlayControl.interceptPointerEvent] 驱动
  @overridePoint
  bool interceptOverlayControlPointerEvent(
    PointerDispatchMixin dispatch,
    PointerEvent event,
  ) {
    return false;
  }

  /// 处理手势
  /// - [ElementOverlayControl.onPointerEvent] 驱动
  @overridePoint
  bool onOverlayControlPointerEvent(
    PointerDispatchMixin dispatch,
    PointerEvent event,
  ) {
    return false;
  }
}
