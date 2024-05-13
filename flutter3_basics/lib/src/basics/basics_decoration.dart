part of '../../flutter3_basics.dart';

/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

//region BoxDecoration

/// [BoxDecoration] 装饰
/// [PaintFn]
class PaintDecoration extends Decoration {
  final PaintFn? paint;

  const PaintDecoration(this.paint);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return PaintBoxPainter(paint, onChanged);
  }
}

class PaintBoxPainter extends BoxPainter {
  final PaintFn? paintFn;

  PaintBoxPainter(this.paintFn, super.onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    //super.paint(canvas, offset, configuration);
    //debugger();
    if (paintFn != null) {
      canvas.withTranslate(offset.dx, offset.dy, () {
        paintFn?.call(canvas, configuration.size ?? Size.zero);
      });
    }
  }
}

/// 描边装饰
/// [color] 描边颜色
/// [strokeWidth] 描边宽度
/// [fillDecoration]
BoxDecoration strokeDecoration({
  Color? color,
  BuildContext? context,
  double strokeWidth = 1,
  double borderRadius = kDefaultBorderRadiusXX,
  BorderStyle style = BorderStyle.solid,
  double strokeAlign = BorderSide.strokeAlignInside,
  BorderSide? top,
  BorderSide? bottom,
  BorderSide? start,
  BorderSide? end,
}) {
  final strokeColor = color ?? GlobalTheme.of(context).primaryColor;
  final BorderSide side = BorderSide(
    color: strokeColor,
    width: strokeWidth,
    style: style,
    strokeAlign: strokeAlign,
  );
  return BoxDecoration(
    border: BorderDirectional(
      top: top ?? side,
      bottom: bottom ?? side,
      start: start ?? side,
      end: end ?? side,
    ),
    borderRadius: borderRadius > 0
        ? BorderRadius.all(
            Radius.circular(borderRadius),
          )
        : null,
  );
}

/// 线条装饰
BoxBorder strokeBorder({
  Color? color,
  BuildContext? context,
  double strokeWidth = 1,
  double borderRadius = kDefaultBorderRadiusXX,
  BorderStyle style = BorderStyle.solid,
  double strokeAlign = BorderSide.strokeAlignInside,
  BorderSide? top,
  BorderSide? bottom,
  BorderSide? left,
  BorderSide? right,
}) {
  final strokeColor = color ?? GlobalTheme.of(context).primaryColor;
  final BorderSide side = BorderSide(
    color: strokeColor,
    width: strokeWidth,
    style: style,
    strokeAlign: strokeAlign,
  );
  return Border(
    top: top ?? side,
    bottom: bottom ?? side,
    left: left ?? side,
    right: right ?? side,
  );
}

/// 四条边都是线条的装饰器
BoxDecoration lineDecoration({
  BuildContext? context,
  Color? topLineColor,
  Color? bottomLineColor,
  Color? leftLineColor,
  Color? rightLineColor,
  double topLineWidth = 1,
  double bottomLineWidth = 1,
  double leftLineWidth = 1,
  double rightLineWidth = 1,
  BorderSide? topSide,
  BorderSide? bottomSide,
  BorderSide? leftSide,
  BorderSide? rightSide,
}) {
  final lineColor = GlobalTheme.of(context).lineColor;
  return BoxDecoration(
    border: Border(
      left: leftSide ??
          BorderSide(color: leftLineColor ?? lineColor, width: leftLineWidth),
      top: topSide ??
          BorderSide(color: topLineColor ?? lineColor, width: topLineWidth),
      right: rightSide ??
          BorderSide(color: rightLineColor ?? lineColor, width: rightLineWidth),
      bottom: bottomSide ??
          BorderSide(
              color: bottomLineColor ?? lineColor, width: bottomLineWidth),
    ),
  );
}

/// 纯色填充装饰, 支持圆角
/// [color] 填充颜色
/// [gradient] 渐变颜色.[linearGradient].[sweepGradientShader].[sweepGradientShader]
/// [strokeDecoration]
/// [border] 边框
BoxDecoration fillDecoration({
  BuildContext? context,
  Color? color,
  Gradient? gradient,
  BorderRadiusGeometry? radiusGeometry,
  double? borderRadius = kDefaultBorderRadiusXX,
  double? borderTopRadius,
  double? borderBottomRadius,
  BoxBorder? border,
}) {
  final fillColor = color ?? GlobalTheme.of(context).primaryColor;

  if (radiusGeometry == null) {
    if (borderTopRadius != null || borderBottomRadius != null) {
      radiusGeometry = BorderRadius.only(
        topLeft: Radius.circular(borderTopRadius ?? 0),
        topRight: Radius.circular(borderTopRadius ?? 0),
        bottomLeft: Radius.circular(borderBottomRadius ?? 0),
        bottomRight: Radius.circular(borderBottomRadius ?? 0),
      );
    } else if (borderRadius != null) {
      radiusGeometry = BorderRadius.circular(borderRadius);
    }
  }

  return BoxDecoration(
    color: fillColor,
    gradient: gradient,
    borderRadius: radiusGeometry,
    border: border,
    //gradient:
  );
}

/// 线性渐变装饰
/// [colors] 设置了渐变颜色, 则[fillColor]无效
/// [borderRadius] 圆角
BoxDecoration lineaGradientDecoration(
  List<Color>? colors, {
  BuildContext? context,
  Color? fillColor,
  double borderRadius = 0,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
}) {
  final color = fillColor ?? GlobalTheme.of(context).primaryColor;
  return BoxDecoration(
    color: color,
    gradient: colors == null
        ? null
        : linearGradient(
            colors,
            begin: begin,
            end: end,
          ),
    borderRadius: borderRadius > 0
        ? BorderRadius.all(
            Radius.circular(borderRadius),
          )
        : null,
    //gradient:
  );
}

//endregion BoxDecoration

//region InputDecoration

/// [InputBorder.none]
/// [BorderSide.none]
/// [InputDecoration]
/// [OutlineInputBorder]
OutlineInputBorder outlineInputBorder({
  BuildContext? context,
  Color? color,
  double width = 1,
  double gapPadding = 4,
  double? borderRadius,
  BorderSide? borderSide,
}) {
  final globalTheme = GlobalTheme.of(context);
  return OutlineInputBorder(
    borderRadius: borderRadius != null
        ? BorderRadius.circular(borderRadius)
        : BorderRadius.circular(kDefaultBorderRadiusXX),
    borderSide: borderSide ??
        BorderSide(
          color: color ?? globalTheme.borderColor,
          width: width,
        ),
    gapPadding: gapPadding,
  );
}

/// [InputDecoration]
/// [UnderlineInputBorder]
UnderlineInputBorder underlineInputBorder({
  BuildContext? context,
  Color? color,
  double width = 1,
  double borderRadius = 0,
}) {
  final globalTheme = GlobalTheme.of(context);
  return UnderlineInputBorder(
    borderSide: BorderSide(
      color: color ?? globalTheme.borderColor,
      width: width,
    ),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

//endregion InputDecoration
