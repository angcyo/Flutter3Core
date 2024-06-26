part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 绘制管理
class GraffitiPaintManager
    with DiagnosticableTreeMixin, DiagnosticsMixin, MagnifierRenderMixin {
  final GraffitiDelegate graffitiDelegate;

  GraffitiPaintManager(this.graffitiDelegate);

  /// 是否强制显示放大镜, 否则自动在橡皮擦模式下开启
  bool? showMagnifier;

  /// 放大镜拍偏移
  Offset magnifierOffset = const Offset(-20, -40);

  /// 放大倍数
  double magnifierFactor = 4;

  /// 放大镜的大小, 直径
  double magnifierSize = 80;

  @dp
  @viewCoordinate
  Rect paintBounds = Rect.zero;

  /// [showMagnifier]
  bool get _showMagnifier =>
      showMagnifier == true ||
          graffitiDelegate.graffitiEventManager.pointEventHandler
          is GraffitiEraserHandler;

  /// 更新整个绘制区域大小, 顺便更新内容绘制区域
  @entryPoint
  void updatePaintBounds(Size size, bool isInitialize) {
    paintBounds = Offset.zero & size;
  }

  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.withOffset(offset, () {
      /*assert(() {
        canvas.drawRect(
            paintBounds + offset,
            Paint()
              ..strokeWidth = 2
              ..style = UiPaintingStyle.stroke
              ..color = Colors.purpleAccent);
        return true;
      }());*/
      final paintMeta = PaintMeta(host: graffitiDelegate);
      //
      canvas.withClipRect(paintBounds + offset, () {
        graffitiDelegate.graffitiElementManager
            .paintElements(canvas, paintMeta);
        if (_showMagnifier) {
          //绘制放大镜
          final touchPointer =
              graffitiDelegate.graffitiEventManager.currentTouchPointer;
          paintMagnifier(
              context,
              offset,
              paintBounds.size,
              touchPointer,
              magnifierFactor,
              magnifierSize,
              magnifierOffset, (context, offset) {
            graffitiDelegate.graffitiElementManager
                .paintElements(canvas, paintMeta);
          });
        }
      });
    });
  }
}
