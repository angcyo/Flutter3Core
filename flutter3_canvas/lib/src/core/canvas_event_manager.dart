part of flutter3_canvas;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/04
/// 手势入口
class CanvasEventManager {
  final CanvasDelegate canvasDelegate;

  /// 画布平移组件
  late CanvasTranslateComponent canvasTranslateComponent =
      CanvasTranslateComponent(canvasDelegate);

  CanvasEventManager(this.canvasDelegate);

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    //canvasDelegate.canvasViewBox.translateBy(event.delta.dx, event.delta.dy);
  }
}

class CanvasTranslateComponent with CanvasComponent {
  final CanvasDelegate canvasDelegate;

  CanvasTranslateComponent(this.canvasDelegate);

  void translateBy(double dx, double dy) {
    canvasDelegate.canvasViewBox.translateBy(dx, dy);
  }

  void translateTo(double x, double y) {
    canvasDelegate.canvasViewBox.translateTo(x, y);
  }
}
