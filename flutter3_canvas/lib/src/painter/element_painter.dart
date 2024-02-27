part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 绘制元素数据

class ElementPainter extends IPainter {
  /// 元素绘制的属性信息
  /// 为空表示未初始化
  PaintProperty? _paintProperty;

  PaintProperty? get paintProperty => _paintProperty;

  set paintProperty(PaintProperty? value) {
    final old = _paintProperty;
    _paintProperty = value;
    canvasDelegate?.dispatchCanvasElementPropertyChanged(this, old, value);
  }

  /// 画笔
  Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black
    ..strokeWidth = 1.toDpFromPx();

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      onPaintingSelf(canvas, paintMeta);
    });
  }

  @overridePoint
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {}

  //---

  CanvasDelegate? canvasDelegate;

  /// 附加到[CanvasDelegate]
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    this.canvasDelegate = canvasDelegate;
  }

  /// 从[CanvasDelegate]中移除
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    this.canvasDelegate = null;
  }
}

class ElementGroupPainter extends ElementPainter {}

/// 绘制属性, 包含坐标/缩放/旋转/倾斜等信息
class PaintProperty {
  /// 绘制的左上坐标
  @dp
  double left = 0;
  @dp
  double top = 0;

  /// 绘制的宽高大小
  @dp
  double width = 0;
  @dp
  double height = 0;

  double scaleX = 1;
  double scaleY = 1;

  /// 倾斜角度, 弧度单位
  double skewX = 0;
  double skewY = 0;

  /// 旋转角度, 弧度单位
  /// [NumEx.toDegrees]
  /// [NumEx.toSanitizeDegrees]
  double angle = 0;
}
