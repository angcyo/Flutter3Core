part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///
/// 画布代理类, 核心类, 整个框架的入口
class CanvasDelegate {
  //region ---入口点---

  /// 绘制入口点
  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    //debugger();
    canvasPaintManager.paint(context, offset);
  }

  /// 手势入口点
  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    refresh();
  }

  //endregion ---入口点---

  //region ---core---

  /// 重绘通知, 监听此通知, 主动触发重绘
  ValueNotifier<int> repaint = ValueNotifier(0);

  /// 视口控制
  late CanvasViewBox canvasViewBox = CanvasViewBox(this);

  /// 绘制管理
  late CanvasPaintManager canvasPaintManager = CanvasPaintManager(this);

  //endregion ---core---

  //region ---api---

  /// 刷新画布
  @api
  void refresh() {
    repaint.value++;
  }

  //endregion ---api---

  //region ---事件派发---

  /// 当[CanvasViewBox]视口发生变化时触发
  void dispatchCanvasViewBoxChanged(CanvasViewBox canvasViewBox) {
    canvasPaintManager.axisManager.updateAxisData(canvasViewBox);
    refresh();
  }

//endregion ---事件派发---
}
