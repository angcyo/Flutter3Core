part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/06
///
/// Geometry 几何

extension GeometryWidgetEx on Widget {
  //region ---Padding---

  /// 将当前的小部件, 包裹在一个[Padding]中
  /// [EdgeInsets]
  /// [EdgeInsetsGeometry]
  Widget paddingInsets(EdgeInsetsGeometry? insets) {
    return insets == null || insets == EdgeInsets.zero
        ? this
        : Padding(padding: insets, child: this);
  }

  /// 将当前的小部件, 包裹在一个[Padding]中
  /// 根据html的padding属性, 生成padding
  @Deprecated("请使用[paddingOnly]")
  Widget padding([double? v1, double? v2, double? v3, double? v4]) {
    final insets = edgeInsets(v1, v2, v3, v4);
    return paddingInsets(insets);
  }

  @Deprecated("请使用[paddingOnly]")
  Widget paddingCss([double? v1, double? v2, double? v3, double? v4]) =>
      padding(v1, v2, v3, v4);

  /// 将当前的小部件, 包裹在一个[Padding]中
  @Deprecated("请使用[paddingOnly]")
  Widget paddingAll(double value) => paddingInsets(EdgeInsets.all(value));

  @Deprecated("请使用[paddingOnly]")
  Widget paddingLTRB(double left, double top, double right, double bottom) =>
      paddingInsets(EdgeInsets.fromLTRB(left, top, right, bottom));

  /// 对称
  /// [paddingSymmetric]
  @Deprecated("请使用[paddingOnly]")
  Widget paddingItem({double vertical = kXh / 2, double horizontal = kXh}) {
    return paddingSymmetric(vertical: vertical, horizontal: horizontal);
  }

  /// 对称, 左右大一点, 上下小一点
  @Deprecated("请使用[paddingOnly]")
  Widget paddingSym({
    double? vertical,
    double? horizontal,
    double left = kX,
    double top = kH,
    double right = kX,
    double bottom = kH,
  }) => paddingOnly(
    left: horizontal ?? left,
    top: vertical ?? top,
    right: horizontal ?? right,
    bottom: vertical ?? bottom,
  );

  /// 对称, 左右上下一样大
  @Deprecated("请使用[paddingOnly]")
  Widget paddingSymmetric({
    double? vertical,
    double? horizontal,
    double left = kX,
    double top = kX,
    double right = kX,
    double bottom = kX,
  }) => paddingOnly(
    left: horizontal ?? left,
    top: vertical ?? top,
    right: horizontal ?? right,
    bottom: vertical ?? bottom,
  );

  /// [edgeInsets]
  /// [edgeOnly]
  /// [insets]
  ///
  /// [paddingOnly]
  /// [paddingInsets]
  Widget insets({
    //全部设置
    double? all,
    //水平垂直设置
    double? v,
    double? h,
    double? vertical,
    double? horizontal,
    //除了此方向, 其它都设置
    double? nLeft,
    double? nTop,
    double? nRight,
    double? nBottom,
    //单独设置
    double? left,
    double? top,
    double? right,
    double? bottom,
    //替换设置
    EdgeInsetsGeometry? insets,
  }) => paddingInsets(
    insets ??
        EdgeInsets.only(
          left:
              left ?? nTop ?? nRight ?? nBottom ?? h ?? horizontal ?? all ?? 0,
          top: top ?? nLeft ?? nRight ?? nBottom ?? v ?? vertical ?? all ?? 0,
          right:
              right ?? nLeft ?? nTop ?? nBottom ?? h ?? horizontal ?? all ?? 0,
          bottom:
              bottom ?? nLeft ?? nTop ?? nRight ?? v ?? vertical ?? all ?? 0,
        ),
  );

  /// [insets]
  /// [paddingOnly]
  /// [paddingInsets]
  @Alias("insets")
  Widget paddingOnly({
    //全部设置
    double? all,
    //水平垂直设置
    double? v,
    double? h,
    double? vertical,
    double? horizontal,
    //除了此方向, 其它都设置
    double? nLeft,
    double? nTop,
    double? nRight,
    double? nBottom,
    //单独设置
    double? left,
    double? top,
    double? right,
    double? bottom,
    //替换设置
    EdgeInsetsGeometry? insets,
  }) => this.insets(
    all: all,
    v: v,
    h: h,
    vertical: vertical,
    horizontal: horizontal,
    nLeft: nLeft,
    nTop: nTop,
    nRight: nRight,
    nBottom: nBottom,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    insets: insets,
  );

  /*Widget paddingFromWindowPadding() {
    return Padding(
      padding: EdgeInsets.fromWindowPadding(WidgetsBinding.instance!.window.viewInsets, WidgetsBinding.instance!.window.devicePixelRatio),
      child: this,
    );
  }*/

  //endregion ---Padding---
}

/// [edgeInsets]
/// [edgeOnly]
/// [insets]
EdgeInsets edgeOnly({
  //全部设置
  double? all,
  //水平垂直设置
  double? vertical,
  double? horizontal,
  double? v,
  double? h,
  //除了此方向, 其它都设置
  double? nLeft,
  double? nTop,
  double? nRight,
  double? nBottom,
  //单独设置
  double? left,
  double? top,
  double? right,
  double? bottom,
}) => EdgeInsets.only(
  left: left ?? nTop ?? nRight ?? nBottom ?? h ?? horizontal ?? all ?? 0,
  top: top ?? nLeft ?? nRight ?? nBottom ?? v ?? vertical ?? all ?? 0,
  right: right ?? nLeft ?? nTop ?? nBottom ?? h ?? horizontal ?? all ?? 0,
  bottom: bottom ?? nLeft ?? nTop ?? nRight ?? v ?? vertical ?? all ?? 0,
);

/// [edgeOnly]
/// [insets]
EdgeInsets insets({
  //全部设置
  double? all,
  //水平垂直设置
  double? vertical,
  double? horizontal,
  double? v,
  double? h,
  //除了此方向, 其它都设置
  double? nLeft,
  double? nTop,
  double? nRight,
  double? nBottom,
  //单独设置
  double? left,
  double? top,
  double? right,
  double? bottom,
}) => edgeOnly(
  all: all,
  vertical: vertical,
  horizontal: horizontal,
  v: v,
  h: h,
  nLeft: nLeft,
  nTop: nTop,
  nRight: nRight,
  nBottom: nBottom,
  left: left,
  top: top,
  right: right,
  bottom: bottom,
);

/// 将当前的小部件, 包裹在一个[Padding]中
/// 根据html的padding属性, 生成padding
EdgeInsets? edgeInsets([double? v1, double? v2, double? v3, double? v4]) {
  //如果是4个参数
  if (v1 != null && v2 != null && v3 != null && v4 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v3, v4);
  }
  //如果是3个参数
  if (v1 != null && v2 != null && v3 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v3, v2);
  }
  //如果是2个参数
  if (v1 != null && v2 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v1, v2);
  }
  //如果是1个参数
  if (v1 != null) {
    return EdgeInsets.all(v1);
  }
  return null;
}
