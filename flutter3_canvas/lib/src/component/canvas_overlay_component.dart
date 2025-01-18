part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/18
///
/// 画布覆盖组件, 用来拦截所有事件.
/// 通常用于在画布上临时绘制额外的信息
/// 比如钢笔工具/绘制形状等
///
class CanvasOverlayComponent extends IPainter
    with DiagnosticableTreeMixin, DiagnosticsMixin {
  /// 画布代理
  CanvasDelegate? canvasDelegate;

  CanvasStyle? get canvasStyle => canvasDelegate?.canvasStyle;

  CanvasViewBox? get canvasViewBox => canvasDelegate?.canvasViewBox;

  //region api

  //endregion api

  //region painting

  /// 附加到[CanvasDelegate]
  @mustCallSuper
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    if (this.canvasDelegate == canvasDelegate) {
      return;
    }

    final old = this.canvasDelegate;
    if (old != null && old != canvasDelegate) {
      detachFromCanvasDelegate(old);
    }
    this.canvasDelegate = canvasDelegate;
    //canvasDelegate.dispatchElementAttachToCanvasDelegate(this);
  }

  /// 从[CanvasDelegate]中移除
  @mustCallSuper
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    if (this.canvasDelegate == canvasDelegate) {
      this.canvasDelegate = null;
      //canvasDelegate.dispatchElementDetachFromCanvasDelegate(this);
    }
  }

  /// [ElementPainter]
  /// [ElementPainter.painting]
  @override
  @viewCoordinate
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      onPaintingSelf(canvas, paintMeta);
    });
  }

  /// [painting]
  @sceneCoordinate
  @overridePoint
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 100, 100),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 1 / paintMeta.canvasScale
        ..style = PaintingStyle.stroke,
    );
  }

  /// 处理元素事件
  /// [CanvasEventManager.handleEvent]驱动
  @callPoint
  void handleEvent(@viewCoordinate PointerEvent event) {}

  /// 处理元素键盘事件
  /// [CanvasEventManager.handleKeyEvent]驱动
  @callPoint
  bool handleKeyEvent(KeyEvent event) {
    return false;
  }

//endregion painting
}
