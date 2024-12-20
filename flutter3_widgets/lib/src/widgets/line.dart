part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
/// 竖线
Line verticalLine(
  BuildContext context, {
  Color? color,
  double? indent,
  double? endIndent,
}) =>
    Line(
      thickness: 1,
      color: color ?? GlobalTheme.of(context).lineColor,
      axis: Axis.vertical,
      indent: indent,
      endIndent: endIndent ?? indent,
    );

/// 横线
Line horizontalLine(
  BuildContext context, {
  Color? color,
  double? indent,
  double? endIndent,
}) =>
    Line(
      thickness: 1,
      color: color ?? GlobalTheme.of(context).lineColor,
      axis: Axis.horizontal,
      indent: indent,
      endIndent: endIndent ?? indent,
    );

/// 线
Widget line(
  BuildContext context, {
  Axis axis = Axis.vertical,
  double thickness = 1,
  double lineSize = 24,
  Color? color,
}) {
  final globalTheme = GlobalTheme.of(context);
  //color ??= context.isThemeDark ? const Color(0xff595450) : const Color(0xffececec);
  color ??=
      context.isThemeDark ? globalTheme.lineDarkColor : globalTheme.lineColor;
  final w = axis == Axis.vertical ? thickness : lineSize;
  final h = axis == Axis.vertical ? lineSize : thickness;
  return DecoratedBox(decoration: fillDecoration(color: color))
      .size(width: w, height: h);
}

class Line extends LeafRenderObjectWidget {
  /// 是否强制指定线条的大小
  final double? lineSize;

  /// 线条的厚度
  final double thickness;

  /// 线条的方向
  final Axis axis;

  /// 宽或高, 需要收尾缩进多少量
  final double? indent;
  final double? endIndent;

  /// 线条的颜色
  final Color color;

  /// 线条的外边距, 可以用来控制小部件的大小
  final EdgeInsets? margin;

  /// 线条的端点样式
  final StrokeCap lineStrokeCap;

  /// 线条的连接样式
  final StrokeJoin lineStrokeJoin;

  /// 线额外的装饰绘制
  final Decoration? decoration;

  const Line({
    super.key,
    this.lineSize,
    this.thickness = 1,
    this.color = Colors.grey,
    this.axis = Axis.horizontal,
    this.indent,
    this.endIndent,
    this.margin,
    this.lineStrokeCap = StrokeCap.round,
    this.lineStrokeJoin = StrokeJoin.round,
    this.decoration,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => LineRender(this);

  @override
  void updateRenderObject(BuildContext context, LineRender renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..reset()
      ..line = this
      ..markNeedsPaint();
  }
}

/// 线条渲染
class LineRender extends RenderBox {
  Line line;

  LineRender(this.line);

  ImageConfiguration configuration = ImageConfiguration.empty;

  BoxPainter? _painter;

  void reset() {}

  @override
  void performLayout() {
    //super.performLayout();
    var constraints = this.constraints;

    double width = line.thickness;
    double height = line.thickness;
    if (line.axis == Axis.horizontal) {
      //横线
      if (line.lineSize == null) {
        //自适应线宽
        if (constraints.maxWidth == double.infinity) {
          final siblingSize = _findSiblingSize();
          width = siblingSize?.width ?? 0;
        } else {
          width = constraints.maxWidth;
        }
      } else {
        width = line.lineSize!;
      }
      width = width - (line.indent ?? 0) - (line.endIndent ?? 0);
    } else {
      //竖线
      if (line.lineSize == null) {
        //自适应线高
        if (constraints.maxHeight == double.infinity) {
          var siblingSize = _findSiblingSize();
          height = siblingSize?.height ?? 0;
        } else {
          height = constraints.maxHeight;
        }
      } else {
        height = line.lineSize!;
      }
      height = height - (line.indent ?? 0) - (line.endIndent ?? 0);
    }
    size = Size(width + (line.margin?.horizontal ?? 0),
        height + (line.margin?.vertical ?? 0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final size = this.size;
    final canvas = context.canvas;

    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.thickness
      ..strokeCap = line.lineStrokeCap
      ..strokeJoin = line.lineStrokeJoin
      ..style = PaintingStyle.stroke;
    final leftMargin = line.margin?.left ?? 0;
    final topMargin = line.margin?.top ?? 0;
    final rightMargin = line.margin?.right ?? 0;
    final bottomMargin = line.margin?.bottom ?? 0;

    final indent = line.indent ?? 0;
    final endIndent = line.endIndent ?? 0;

    if (line.axis == Axis.horizontal) {
      final ImageConfiguration filledConfiguration = configuration.copyWith(
          size: ui.Size(
        size.width - indent - endIndent - leftMargin - rightMargin,
        size.height - topMargin - bottomMargin,
      ));
      //背景绘制
      _painter ??= line.decoration?.createBoxPainter(markNeedsPaint);
      _painter?.paint(context.canvas, offset + Offset(leftMargin, topMargin),
          filledConfiguration);
      setCanvasIsComplexHint(context, line.decoration);

      //var lineHeight = size.height - topMargin - bottomMargin;
      canvas.drawLine(
          offset.translate(indent + leftMargin + line.thickness / 2,
              topMargin + line.thickness / 2),
          offset.translate(
              size.width - endIndent - rightMargin - line.thickness / 2,
              topMargin + line.thickness / 2),
          paint);
    } else {
      final ImageConfiguration filledConfiguration = configuration.copyWith(
          size: ui.Size(
        size.width - leftMargin - rightMargin,
        size.height - indent - endIndent,
      ));
      //背景绘制
      _painter ??= line.decoration?.createBoxPainter(markNeedsPaint);
      _painter?.paint(context.canvas, offset + Offset(leftMargin, topMargin),
          filledConfiguration);
      setCanvasIsComplexHint(context, line.decoration);

      //var lineWidth = size.width - leftMargin - rightMargin;
      canvas.drawLine(
          offset.translate(leftMargin + line.thickness / 2,
              indent + topMargin + line.thickness / 2),
          offset.translate(leftMargin + line.thickness / 2,
              size.height - endIndent - bottomMargin - line.thickness / 2),
          paint);
    }
  }

  /// 查找同级的小部件最大的大小
  Size? _findSiblingSize() {
    Size? result;
    if (parent != null) {
      for (final child in parent!.childrenList) {
        if (child == this) {
          continue;
        }
        var renderSize = child.renderSize ?? child.measureRenderSize();
        if (renderSize != null) {
          if (result == null) {
            result = renderSize;
          } else {
            if (renderSize.width * renderSize.height >
                result.width * result.height) {
              result = renderSize;
            }
          }
        }
      }
    }
    return result;
  }
}
