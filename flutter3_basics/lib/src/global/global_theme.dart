part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/20
///

/// 提供[GlobalTheme]的[InheritedWidget]
class GlobalThemeScope extends InheritedWidget {
  final GlobalTheme globalTheme;

  const GlobalThemeScope({
    super.key,
    required super.child,
    required this.globalTheme,
  });

  @override
  bool updateShouldNotify(covariant GlobalThemeScope oldWidget) =>
      isDebug || globalTheme != oldWidget.globalTheme;
}

/// 全局颜色配置
class GlobalTheme {
  /// 颜色配置, 主要颜色
  Color get primaryColor => "#2febff".toColor();

  /// 主题强调色
  Color get accentColor => primaryColor;

  /// 暗一点的主题色
  Color get primaryColorDark => "#0cabea".toColor();

  /// 图标按下的颜色/选择的颜色等
  Color get icoSelectedColor => primaryColor;

  /// 图片占位颜色
  Color get imagePlaceholderColor => icoNormalColor;

  /// 图标正常的颜色
  Color get icoNormalColor => "#6f6f6f".toColor();

  /// 灰度图标的颜色
  Color get icoGrayColor => "#333333".toColor();

  /// 主题白色, 受暗色模式影响
  Color get themeWhiteColor => Colors.white;

  /// 白色背景颜色
  Color get whiteBgColor => "#f9f9f9".toColor();

  /// 白色背景上的白色按钮背景颜色
  Color get whiteSubBgColor => "#ececec".toColor();

  /// 禁用时的背景颜色(偏白色)
  Color get disableBgColor => "#ECECEC".toColor();

  /// 链接的颜色
  Color get linkColor => "#0a84ff".toColor();

  /// 线的颜色
  Color get lineColor => "#ECECEC".toColor();

  /// 边框的颜色
  Color get borderColor => "#6f6f6f".toColor();

  /// 阴影高度默认取值
  double get elevation => 2;

  /// 阴影颜色
  Color get shadowColor => Colors.black;

  /// [AppBar]的默认阴影高度
  double get appBarElevation => 4;

  /// [AppBar]的阴影颜色
  Color get appBarShadowColor => shadowColor;

  /// [AppBar]的背景颜色
  Color get appBarBackgroundColor => primaryColor;

  /// [AppBar]的前景颜色
  Color get appBarForegroundColor => themeWhiteColor;

  /// [AppBar]渐变背景颜色, 如果有
  List<Color>? get appBarGradientBackgroundColorList =>
      listOf(primaryColor, primaryColorDark);

  /// 基础距离配置
  double get s => kS;

  double get m => kM;

  double get l => kL;

  double get h => kH;

  double get x => kX;

  double get xh => kXh;

  double get xxh => kXxh;

  double get xxxh => kXxxh;

  /// 无数据时的提示
  String? get noDataTip => "暂无数据";

  /// 没有更多数据时的提示
  String? get noMoreDataTip => "~已经到底啦~";

  /// 数据加载失败的提示
  String? get loadDataErrorTip => "加载失败, 点击重试";

  /// [_kDefaultFontSize] 14
  TextStyle get textPrimaryStyle => TextStyle(
        fontSize: 18,
        color: "#161B26".toColor(),
      );

  TextStyle get textGeneralStyle => TextStyle(
        fontSize: 14,
        color: "#182334".toColor(),
      );

  TextStyle get textTitleStyle => TextStyle(
        fontSize: 17,
        color: "#333333".toColor(),
      );

  TextStyle get textSubTitleStyle => TextStyle(
        fontSize: 14,
        color: "#929292".toColor(),
      );

  TextStyle get textBodyStyle => TextStyle(
        fontSize: 14,
        color: "#333333".toColor(),
      );

  TextStyle get textSubStyle => TextStyle(
        fontSize: 12,
        color: "#B0B0B0".toColor(),
      );

  TextStyle get textPlaceStyle => TextStyle(
        fontSize: 12,
        color: "#6F6F6F".toColor(),
      );

  TextStyle get textDisableStyle => TextStyle(
        fontSize: 14,
        color: "#b0b0b0".toColor(),
      );

  /// [GlobalTheme]
  static GlobalTheme of(BuildContext? context, {bool depend = false}) {
    GlobalTheme? result;
    if (context != null) {
      if (depend) {
        result = context
            .dependOnInheritedWidgetOfExactType<GlobalThemeScope>()
            ?.globalTheme;
      } else {
        result = context
            .findAncestorWidgetOfExactType<GlobalThemeScope>()
            ?.globalTheme;
      }
    }
    return result ?? GlobalConfig.of(context, depend: depend).globalTheme;
  }
}
