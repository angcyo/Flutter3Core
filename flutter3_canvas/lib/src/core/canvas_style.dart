part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
/// 画布样式
class CanvasStyle {
  /// 绘制坐标轴
  static const int sDrawAxis = 0X01;

  /// 绘制坐标网格
  static const int sDrawGrid = sDrawAxis << 1;

  //region ---core---

  //--CanvasAxisManager

  /// 是否绘制网格
  bool get showGrid => drawType.have(sDrawGrid);

  set showGrid(bool value) {
    drawType = drawType.add(sDrawGrid, value);
  }

  /// 是否绘制坐标系
  bool get showAxis => drawType.have(sDrawAxis);

  set showAxis(bool value) {
    drawType = drawType.add(sDrawAxis, value);
  }

  /// 绘制label时, 额外需要的偏移量
  @dp
  double axisLabelOffset = 1;

  /// 坐标系的单位
  IUnit axisUnit = IUnit.mm;

  /// 需要绘制的类型, 用来控制坐标轴和网格的绘制
  int drawType = sDrawAxis | sDrawGrid;

  //--ElementAdsorbControl

  /// 是否激活智能吸附
  bool enableElementAdsorb = true;

  //--CanvasElementControlManager

  /// 是否激活元素的控制操作, 关闭之后, 将无法通过手势交互控制元素
  bool enableElementControl = true;

  /// 是否激活选择元素组件
  bool enableElementSelect = true;

  /// 是否激活元素[PaintProperty]属性改变后, 重置旋转角度
  bool enableResetElementAngle = true;

  /// 是否激活点击元素外, 取消选中元素
  bool enableOutsideCancelSelectElement = true;

  //endregion ---core---

  //region ---basics---

  /// 圆角大小
  @dp
  double canvasRadiusSize = 8;

  /// 画布强调颜色, 同时也是选择框的颜色
  Color canvasAccentColor = const Color(0xff00e3ff);

  /// 控制点的背景颜色
  Color controlBgColor = const Color(0xff333333);

  //--paintInfo--

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

  /// 元素信息绘制是否显示单位后缀
  bool paintInfoShowUnitSuffix = false;

  /// 绘制信息是否单行格式
  bool paintInfoSingleLine = false;

  //endregion ---basics---

  //region ---config---

  /// [CanvasContentManager] 画布整体的背景颜色, 指定了就会绘制
  /// [CanvasViewBox.canvasBounds] 的背景颜色
  Color? canvasBgColor;

  /// 当设置了[CanvasContentManager.contentTemplate]内容模版时,
  /// 是否要在内容模版的边界上绘制一层描边
  bool paintContentTemplateStroke = true;

  /// [paintContentTemplateStroke]开启后, 绘制的宽度
  double contentTemplateStrokeWidth = 1;

  //endregion ---config---

  //region ---axis---

  ///dark #b0b0b0
  Color axisPrimaryColor = const Color(0xffbcbcbc); //const Color(0xFFB2B2B2);
  ///dark #6f6f6f
  Color axisSecondaryColor = const Color(0xffD5D5D5); //const Color(0xFFD7D7D7);
  Color axisNormalColor = const Color(0xffD5D5D5); //const Color(0xFFD7D7D7);

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

  /// x横坐标轴的高度
  @dp
  double xAxisHeight = 20;

  /// y纵坐标轴的宽度
  @dp
  double yAxisWidth = 20;

  /// 是否绘制坐标轴上的单位
  bool showAxisUnitSuffix = false;

  /// 是否仅在绘制原点时, 绘制单位
  bool showOriginAxisUnitSuffix = true;

  //endregion ---axis---

  //region ---menu---

  /// 菜单的圆角大小
  @dp
  double menuRadius = kDefaultBorderRadiusX;

  /// 菜单整体的内边距
  EdgeInsets? menuPadding;

  /// 菜单的外边距
  EdgeInsets? menuMargin = const EdgeInsets.all(kH);

  /// 菜单的背景颜色
  Color menuBgColor = const Color(0xff0c0c06);

  /// 菜单的分割线颜色
  Color menuLineColor = const Color(0xff333333);

  /// 菜单三角的大小
  @dp
  double menuTriangleWidth = 10;
  @dp
  double menuTriangleHeight = 6;

  //endregion ---menu---

  //region ---adsorb---

  /// 吸附提示线的颜色
  Color adsorbLineColor = const Color(0xffff443d);

  /// 吸附提示文字的颜色
  Color adsorbTextColor = const Color(0xff333333);

  /// 吸附提示文字的偏移距离
  @dp
  double adsorbTextOffset = 2;

  /// 吸附提示文字的大小
  @dp
  double adsorbTextSize = 9;

  /// 吸附阈值, 当距离目标的差值<=此值时, 触发吸附
  @dp
  @sceneCoordinate
  double adsorbThreshold = 10;

  /// 逃离吸附阈值, 当手指移动的距离>=此值时, 逃离吸附
  @dp
  @viewCoordinate
  double adsorbEscapeThreshold = 10;

//endregion ---adsorb---
}
