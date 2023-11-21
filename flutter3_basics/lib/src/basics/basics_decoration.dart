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
