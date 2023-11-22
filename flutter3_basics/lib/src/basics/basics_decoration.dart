part of flutter3_basics;

/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

/// [BoxDecoration] 装饰

/// 描边装饰
/// [strokeColor] 描边颜色
/// [strokeWidth] 描边宽度
BoxDecoration strokeDecoration({
  BuildContext? context,
  Color? strokeColor,
  double strokeWidth = 1,
  double borderRadius = kDefaultBorderRadiusXX,
  BorderStyle style = BorderStyle.solid,
  double strokeAlign = BorderSide.strokeAlignInside,
  BorderSide? top,
  BorderSide? bottom,
  BorderSide? start,
  BorderSide? end,
}) {
  var color = strokeColor ?? GlobalTheme.of(context).primaryColor;
  final BorderSide side = BorderSide(
    color: color,
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

/// 纯色填充装饰, 支持圆角
BoxDecoration fillDecoration({
  BuildContext? context,
  Color? fillColor,
  double borderRadius = kDefaultBorderRadiusXX,
}) {
  var color = fillColor ?? GlobalTheme.of(context).primaryColor;
  return BoxDecoration(
    color: color,
    borderRadius: borderRadius > 0
        ? BorderRadius.all(
            Radius.circular(borderRadius),
          )
        : null,
    //gradient:
  );
}

/// 线性渐变装饰
/// [borderRadius] 圆角
BoxDecoration lineaGradientDecoration(
  List<Color> colors, {
  BuildContext? context,
  Color? fillColor,
  double borderRadius = 0,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
}) {
  var color = fillColor ?? GlobalTheme.of(context).primaryColor;
  return BoxDecoration(
    color: color,
    gradient: linearGradient(
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
