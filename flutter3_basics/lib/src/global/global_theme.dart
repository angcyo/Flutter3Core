part of '../../flutter3_basics.dart';

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
/// 亮色主题[ui.Brightness.light]
class GlobalTheme {
  /// 颜色配置, 主要颜色
  Color get primaryColor => const Color(0xff2febff);

  /// 主题强调色
  Color get accentColor => const Color(0xff2febff);

  /// 暗一点的主题色
  Color get primaryColorDark => const Color(0xff0cabea);

  /// 系统状态栏的颜色
  Color get systemStatusBarColor => Colors.transparent;

  /// 系统导航栏的颜色
  Color get systemNavigationBarColor => accentColor;

  /// 界面背景颜色
  /// [themeWhiteColor]
  Color get surfaceBgColor => whiteBgColor;

  /// 对话框的背景颜色
  Color get dialogSurfaceBgColor => themeWhiteColor;

  /// 图标按下的颜色/选择的颜色等
  Color get icoSelectedColor => primaryColor;

  /// 图片占位颜色
  Color get imagePlaceholderColor => icoNormalColor;

  /// 图标正常的颜色
  Color get icoNormalColor => const Color(0xff6f6f6f);

  /// 图标禁用的颜色
  Color get icoDisableColor => const Color(0xff949496);

  /// 灰度图标的颜色
  Color get icoGrayColor => const Color(0xff333333);

  /// 白色, 不受暗色模式影响
  Color get whiteColor => Colors.white;

  /// 黑色, 不受暗色模式影响
  /// [blackBgColor]
  Color get blackColor => Colors.black;

  /// 主题黑色, 受暗色模式影响
  Color get themeBlackColor => Colors.black;

  /// 主题白色, 受暗色模式影响
  Color get themeWhiteColor => Colors.white;

  /// 白色背景颜色
  Color get whiteBgColor => const Color(0xfff8f8f8);

  /// 黑色背景颜色
  Color get blackBgColor => const Color(0xff333333);

  /// 容器白色背景颜色 #f6f6f6
  Color get itemWhiteBgColor => const Color(0xfff6f6f6);

  /// 白色背景上的容器背景颜色 f9f9f9
  Color get itemWhiteSubBgColor => const Color(0xfff9f9f9);

  /// 白色背景上的白色按钮背景颜色
  Color get whiteSubBgColor => const Color(0xffececec);

  /// 禁用时的背景颜色(偏白色)
  Color get disableBgColor => const Color(0xffE2E2E2);

  /// 文本禁用时的颜色(偏白色)
  Color get disableTextColor => const Color(0xffd8d8d8);

  /// 禁用时的颜色
  Color get disableColor => Colors.black26;

  /// 链接的颜色
  Color get linkColor => const Color(0xff0a84ff);

  /// 线的颜色 #F6F6F6
  Color get lineColor => const Color(0xffECECEC);

  /// 线的颜色 (更暗一点)
  Color get lineDarkColor => const Color(0xffD8D8D8);

  /// 边框的颜色
  Color get borderColor => const Color(0xff6f6f6f);

  /// 错误提示颜色
  Color get errorColor => const Color(0xffFF443D);

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

  double get xxxh => kXxx;

  /// 按钮内边距
  EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: x, vertical: h);

  /// 平板模式下, 对话框的约束
  BoxConstraints get tabletDialogConstraints => BoxConstraints(
      minWidth: 0,
      maxWidth: math.min(screenWidth, screenHeight),
      minHeight: 0,
      maxHeight: double.infinity);

  //region 文本样式

  /// [_kDefaultFontSize] 14
  TextStyle get textPrimaryStyle => const TextStyle(
        fontSize: 18,
        color: Color(0xff161B26),
      );

  /// 常规文本颜色
  TextStyle get textGeneralStyle => const TextStyle(
        fontSize: 14,
        color: Color(0xff182334),
      );

  /// 大号常规文本颜色
  TextStyle get textBigGeneralStyle => const TextStyle(
        fontSize: 28,
        color: Color(0xff182334),
      );

  TextStyle get textTitleStyle => const TextStyle(
        fontSize: 17,
        color: Color(0xff333333),
      );

  TextStyle get textSubTitleStyle => const TextStyle(
        fontSize: 14,
        color: Color(0xff929292),
      );

  TextStyle get textBodyStyle => const TextStyle(
        fontSize: 14,
        color: Color(0xff333333),
      );

  TextStyle get textSubStyle => const TextStyle(
        fontSize: 12,
        color: Color(0xffB0B0B0),
      );

  TextStyle get textDesStyle => const TextStyle(
        fontSize: 12,
        color: Color(0xff949496),
      );

  TextStyle get textPlaceStyle => const TextStyle(
        fontSize: 12,
        color: Color(0xff6F6F6F),
      );

  TextStyle get textDisableStyle => const TextStyle(
        fontSize: 14,
        color: Color(0xffb0b0b0),
      );

  TextStyle get  textLabelStyle => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xff333333),
      );

  TextStyle get textInfoStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xff666666),
      );

  //endregion 文本样式

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
            .getInheritedWidgetOfExactType<GlobalThemeScope>()
            ?.globalTheme;
      }
    }
    return result ?? GlobalConfig.of(context, depend: depend).globalTheme;
  }
}

/// 暗色主题[ui.Brightness.dark]
class GlobalThemeDark extends GlobalTheme {
  @override
  Color get primaryColor => const Color(0xff212121);

  @override
  Color get primaryColorDark => const Color(0xff2a2a2a);

  @override
  Color get themeWhiteColor => primaryColor;

  /// [AppBar]的前景颜色
  @override
  Color get appBarForegroundColor =>
      textTitleStyle.color ?? const Color(0xfffcfbfc);

  @override
  Color get whiteBgColor => primaryColorDark;

  @override
  Color get lineColor => const Color(0xff595450);

  @override
  Color get lineDarkColor => const Color(0xff383839);

  @override
  Color get itemWhiteBgColor => const Color(0xff1a1a1a);

  @override
  Color get whiteSubBgColor => const Color(0xff303030);

  @override
  Color get borderColor => const Color(0xff1a1a1a);

  @override
  Color get disableColor => const Color(0xff333333);

  /// 禁用时的背景颜色(偏黑色)
  @override
  Color get disableBgColor => const Color(0x40333333);

  @override
  TextStyle get textGeneralStyle => super.textGeneralStyle.copyWith(
        color: const Color(0xff6f6f6f),
      );

  @override
  TextStyle get textBigGeneralStyle => const TextStyle(
        fontSize: 28,
        color: Color(0xff6f6f6f),
      );

  @override
  TextStyle get textTitleStyle => super.textTitleStyle.copyWith(
        color: const Color(0xfffcfbfc),
      );

  @override
  TextStyle get textBodyStyle => super.textBodyStyle.copyWith(
        color: const Color(0xffa4a4a4),
      );

  @override
  TextStyle get textLabelStyle => super.textLabelStyle.copyWith(
        color: const Color(0xff787878),
      );
}
