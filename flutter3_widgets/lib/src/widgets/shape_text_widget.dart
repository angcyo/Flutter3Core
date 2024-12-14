part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/11/10
///
/// 用来绘制形状和文本的小部件
/// - 背景是形状
/// - 上层是文本
/// - 支持选中状态提示
class ShapeTextWidget extends LeafRenderObjectWidget {
  /// 是否选中
  final bool isSelected;

  /// 颜色
  final Color color;

  /// 选中颜色
  @defInjectMark
  final Color? selectedColor;

  /// 是否是圆形
  final bool isCircleShape;

  /// 选中范围需要扩展的距离
  final double extend;

  /// 非圆形时[isCircleShape],
  /// 矩形时的圆角
  final double radius;

  //--

  /// 文本
  final String? text;

  /// 文本颜色
  @defInjectMark
  final Color? textColor;

  /// 文本大小
  final double textSize;

  const ShapeTextWidget({
    super.key,
    required this.color,
    this.selectedColor,
    this.isSelected = false,
    this.isCircleShape = true,
    this.extend = 4,
    this.radius = 0,
    //--
    this.text,
    this.textColor,
    this.textSize = kDefaultFontSize,
  });

  @override
  _ShapeTextRenderer createRenderObject(BuildContext context) =>
      _ShapeTextRenderer(this);

  @override
  void updateRenderObject(
      BuildContext context, _ShapeTextRenderer renderObject) {
    renderObject
      ..config = this
      ..markNeedsPaint();
  }
}

class _ShapeTextRenderer extends RenderBox {
  ShapeTextWidget config;

  _ShapeTextRenderer(this.config);

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final canvas = context.canvas;
    final bounds = offset & size;
    final paint = Paint()..style = PaintingStyle.fill;
    if (config.isCircleShape) {
      final radius = min(size.width, size.height) / 2;
      if (config.isSelected) {
        paint.color = config.selectedColor ?? config.color.withOpacity(0.3);
        canvas.drawCircle(bounds.center, radius, paint);
      }
      //--
      paint.color = config.color;
      canvas.drawCircle(bounds.center, radius - config.extend, paint);
    } else {
      if (config.isSelected) {
        paint.color = config.selectedColor ?? config.color.withOpacity(0.3);
        canvas.drawRRect(bounds.toRRect(config.radius), paint);
      }
      //--
      paint.color = config.color;
      canvas.drawRRect(
          bounds.inflateValue(-config.extend).toRRect(config.radius), paint);
    }
    //--
    canvas.drawText(
      config.text,
      bounds: bounds,
      alignment: Alignment.center,
      textColor: config.textColor ?? Colors.white,
      fontSize: config.textSize,
    );
  }
}
