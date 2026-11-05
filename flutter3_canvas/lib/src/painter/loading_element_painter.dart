part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/04
///
/// 加载中...绘制元素对象
/// - 需要指定位置和大小
///
/// - [ElementPainter.updatePaintProperty]
///
/// - [StrokeLoadingWidget]
class LoadingElementPainter extends ElementPainter {
  final StrokeLoadingRenderObject renderObject = StrokeLoadingRenderObject()
    ..progress = -1
    ..pause = false;

  /// - [bounds] 绘制位置和大小
  LoadingElementPainter({
    Rect? bounds,
    double width = 100,
    double height = 100,
  }) {
    bounds ??= Rect.fromLTWH(-width / 2, -height / 2, width, height);
    paintColor = Colors.black12;
    paintStrokeWidth = 4;
    paintProperty = PaintProperty()
      ..left = bounds.left
      ..top = bounds.top
      ..width = bounds.width
      ..height = bounds.height;
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    renderObject
      ..lineColor = paintColor
      ..lineWidth = paintStrokeWidth / paintMeta.canvasScale
      ..contentSize = elementsBounds?.size
      ..paintSelf(canvas, elementsBounds?.topLeft ?? .zero);
    super.onPaintingSelf(canvas, paintMeta);
    if (!renderObject.pause) {
      refresh();
    }
  }
}
