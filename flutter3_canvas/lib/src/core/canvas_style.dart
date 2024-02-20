part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
/// 画布样式
class CanvasStyle {
  //region ---axis---

  Color axisPrimaryColor = const Color(0xff888888); //const Color(0xFFB2B2B2);
  Color axisSecondaryColor = const Color(0xffd0d0d0); //const Color(0xFFD7D7D7);
  Color axisNormalColor = const Color(0xffd0d0d0); //const Color(0xFFD7D7D7);

  @dp
  double axisPrimaryWidth = 1.toDpFromPx();
  @dp
  double axisSecondaryWidth = 1.toDpFromPx();
  @dp
  double axisNormalWidth = 1.toDpFromPx();

  /// 标签刻度数值的颜色
  Color axisLabelColor = const Color(0xff888888);

  /// 标签刻度数值的字体大小
  @dp
  double axisLabelFontSize = 8;

//endregion ---axis---
}
