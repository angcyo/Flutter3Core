part of flutter3_basics;

/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

/// [BoxDecoration] 装饰

/// 圆角纯色装饰
BoxDecoration radiusFillDecoration({
  BuildContext? context,
  Color? fillColor,
  double radius = kDefaultBorderRadiusXX,
}) {
  var color = fillColor ?? GlobalTheme.of(context).primaryColor;
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.all(
      Radius.circular(radius),
    ),
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
    borderRadius: BorderRadius.all(
      Radius.circular(borderRadius),
    ),
    //gradient:
  );
}
