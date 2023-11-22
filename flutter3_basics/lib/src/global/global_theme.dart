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

  /// 暗一点的主题色
  Color get primaryColorDark => "#0cabea".toColor();

  /// 图标按下的颜色/选择的颜色等
  Color get icoSelectedColor => primaryColor;

  /// 图片占位颜色
  Color get imagePlaceholderColor => icoNormalColor;

  /// 图标正常的颜色
  Color get icoNormalColor => "#6f6f6f".toColor();

  /// 主题白色, 受暗色模式影响
  Color get themeWhiteColor => "#fbfdfd".toColor();

  /// 阴影
  double get elevation => 2;

  /// 阴影颜色
  Color get shadowColor => Colors.black;

  /// 基础距离配置
  double get s => kS;

  double get m => kM;

  double get l => kL;

  double get h => kH;

  double get x => kX;

  double get xh => kXh;

  double get xxh => kXxh;

  double get xxxh => kXxxh;

  /// [_kDefaultFontSize] 14
  TextStyle get textPrimaryStyle => TextStyle(
        fontSize: 14,
        color: "#161B26".toColor(),
      );

  TextStyle get textGeneralStyle => TextStyle(
        fontSize: 14,
        color: "#182334".toColor(),
      );

  TextStyle get textSubStyle => TextStyle(
        fontSize: 14,
        color: "#ACAFB7".toColor(),
      );

  TextStyle get textPlaceStyle => TextStyle(
        fontSize: 14,
        color: "#B0B0B0".toColor(),
      );

  TextStyle get textDisableStyle => TextStyle(
        fontSize: 14,
        color: "#aab1bd".toColor(),
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
