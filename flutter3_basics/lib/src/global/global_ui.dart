part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/20
///

class GlobalThemeConfig extends InheritedWidget {
  final GlobalTheme globalTheme;

  const GlobalThemeConfig({
    super.key,
    required super.child,
    required this.globalTheme,
  });

  @override
  bool updateShouldNotify(covariant GlobalThemeConfig oldWidget) =>
      globalTheme != oldWidget.globalTheme;
}

/// 全局颜色配置
class GlobalTheme {
  /// 颜色配置
  Color get primaryColor => "#2febff".toColor();

  /// 暗一点的主题色
  Color get primaryColorDark => "#0cabea".toColor();

  /// 图标按下的颜色/选择的颜色等
  Color get icoSelectedColor => primaryColor;

  /// 图片占位颜色
  Color get imagePlaceholderColor => icoNormalColor;

  /// 图标正常的颜色
  Color get icoNormalColor => "#6f6f6f".toColor();

  /// 阴影
  double get elevation => 2;

  /// 基础距离配置
  double get s => kS;

  double get m => kM;

  double get l => kL;

  double get h => kH;

  double get x => kX;

  double get xh => kXh;

  double get xxh => kXxh;

  double get xxxh => kXxxh;

  /// [GlobalTheme]
  static GlobalTheme of(BuildContext? context, {bool depend = false}) {
    GlobalTheme? result;
    if (context != null) {
      if (depend) {
        result = context
            .dependOnInheritedWidgetOfExactType<GlobalThemeConfig>()
            ?.globalTheme;
      } else {
        result = context
            .findAncestorWidgetOfExactType<GlobalThemeConfig>()
            ?.globalTheme;
      }
    }
    return result ?? GlobalConfig.of(context, depend: depend).globalThemeConfig;
  }
}
