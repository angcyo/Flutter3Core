part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
/// 画布样式
class CanvasStyle {
  //region ---basics---

  /// 圆角大小
  @dp
  double canvasRadiusSize = 8;

  /// 画布强调颜色
  Color canvasAccentColor = const Color(0xff00e3ff);

  /// 控制点的背景颜色
  Color controlBgColor = const Color(0xff333333);

  /// 元素信息绘制的字体大小
  @dp
  double paintInfoTextFontSize = 8;

  /// [paintInfoBgColor]圆角大小
  @dp
  double paintInfoBgRadiusSize = 4;

  /// 绘制背景[paintInfoBgColor]距离元素的额外偏移量
  @dp
  double paintInfoOffset = 4;

  /// 文本在背景内,额外的填充内边界
  @dp
  EdgeInsets paintInfoTextPadding =
      const EdgeInsets.symmetric(horizontal: 4, vertical: 2);

  /// 元素信息绘制的背景颜色
  Color paintInfoBgColor = Colors.black54; //0x61000000

  /// 元素信息绘制的文字颜色
  Color paintInfoTextColor = const Color(0xffffffff);

  //endregion ---basics---

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
