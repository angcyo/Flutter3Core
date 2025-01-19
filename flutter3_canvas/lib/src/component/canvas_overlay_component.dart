part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/18
///
/// 画布覆盖组件, 用来拦截所有事件.
/// 通常用于在画布上临时绘制额外的信息
/// 比如钢笔工具/绘制形状等
///
class CanvasOverlayComponent extends IElementPainter
    with DiagnosticableTreeMixin, DiagnosticsMixin {
  CanvasOverlayComponent() {
    paintStrokeWidthSuppressCanvasScale = true;
  }

  //region api

  //endregion api

  //region painting

  /// 处理元素事件
  /// [CanvasEventManager.handleEvent]驱动
  @override
  bool handleEvent(@viewCoordinate PointerEvent event) {
    return false;
  }

  /// 处理元素键盘事件
  /// [CanvasEventManager.handleKeyEvent]驱动
  @override
  bool handleKeyEvent(KeyEvent event) {
    return false;
  }

//endregion painting
}

/// 钢笔工具覆盖层
class PenOverlayComponent extends CanvasOverlayComponent {
  PenOverlayComponent();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 100, 100),
      paint,
    );
  }
}
