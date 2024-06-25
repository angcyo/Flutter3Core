part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 绘制管理
class GraffitiPaintManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  final GraffitiDelegate graffitiDelegate;

  GraffitiPaintManager(this.graffitiDelegate);

  @dp
  @viewCoordinate
  Rect paintBounds = Rect.zero;

  /// 更新整个绘制区域大小, 顺便更新内容绘制区域
  @entryPoint
  void updatePaintBounds(Size size, bool isInitialize) {
    paintBounds = Offset.zero & size;
  }

  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.withOffset(offset, () {
      assert(() {
        canvas.drawRect(
            paintBounds + offset,
            Paint()
              ..strokeWidth = 2
              ..style = UiPaintingStyle.stroke
              ..color = Colors.purpleAccent);
        return true;
      }());
      final paintMeta = PaintMeta(host: graffitiDelegate);
      //
      canvas.withClipRect(paintBounds + offset, () {
        graffitiDelegate.graffitiElementManager
            .paintElements(canvas, paintMeta);
      });
    });
  }
}
