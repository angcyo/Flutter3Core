part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/10
///
//region Color 扩展

/// https://pub.dev/packages/hsluv
extension ColorEx on Color {
  /// ARGB
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  /// [def] 失败后的默认颜色
  /// - [toHex]
  /// - [toHexColor]
  static Color? fromHex(String hexString) {
    try {
      if (hexString.startsWith("0x")) {
        hexString = hexString.substring(2);
      }
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(buffer.toString().toInt(radix: 16));
    } catch (e) {
      assert(() {
        print(e);
        return true;
      }());
      return null;
    }
  }

  /// 系统的RGB值取值范围是[0~1], 这里转成[0~255]
  int get R => (r * 255).round().clamp(0, 255);

  int get G => (g * 255).round().clamp(0, 255);

  int get B => (b * 255).round().clamp(0, 255);

  int get A => (a * 255).round().clamp(0, 255);

  /// 默认的[value]时argb
  /// 这里返回rgba
  int get rgbaValue => red << 24 | green << 16 | blue << 8 | alpha;

  int get rgbaValue2 => R << 24 | G << 16 | B << 8 | A;

  /// 返回argb色值
  int get argbValue => A << 24 | R << 16 | G << 8 | B;

  /// 不透明度的比例
  Color o(double opacity) => withOpacityRatio(opacity);

  /// 在已有的透明值上进行再次透明
  /// 使用一个增量透明比例创建一个新的颜色
  /// [withOpacity]
  /// [withAlpha]
  /// [withValues]
  Color withOpacityRatio(double opacity) =>
      withAlpha((alpha * opacity).round());

  /// 返回小写的十六进制字符串, ARGB
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  /// - [leadingHashSign] 是否包含#
  /// - [includeAlpha] 是否包含透明通道
  ///
  /// - [toHex]
  /// - [toHexColor]
  String toHex({bool leadingHashSign = true, bool includeAlpha = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ""}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  /// 返回#ff00ff00, ARGB
  /// - [leadingHashSign] 是否包含#
  /// - [includeAlpha] 是否包含透明通道
  ///
  /// - [toHex]
  /// - [toHexColor]
  String toHexColor([bool leadingHashSign = true, bool includeAlpha = true]) =>
      toHex(leadingHashSign: leadingHashSign, includeAlpha: includeAlpha);

  /// 判断当前颜色是否是暗色
  /// [Color.computeLuminance]
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.dark;

  /// 判断当前颜色是否是亮色
  /// [Color.computeLuminance]
  bool get isLight =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light;

  /// `import 'dart:ui' as ui;`
  /// [ui.ColorFilter]
  UiColorFilter toColorFilter([BlendMode blendMode = BlendMode.srcIn]) =>
      ui.ColorFilter.mode(this, blendMode);

  /// 获取当前颜色暗一点的颜色变体
  /// [ColorScheme]
  /// [Scheme]
  Color get darkColor => HSLuvColor.fromColor(this).addLightness(-4).toColor();

  Color get lightColor => HSLuvColor.fromColor(this).addLightness(4).toColor();

  /// 反色
  Color get inverseColor =>
      Color.from(alpha: a, red: 1 - r, green: 1 - g, blue: 1 - b);

  /// 反色
  Color inverse({bool enable = true}) => enable ? inverseColor : this;

  /// 如果是暗色主题, 则返回 [darkColor] 否则返回[this]
  Color darkOr(bool? isDark, Color? darkColor) =>
      isDark == true ? darkColor ?? this : this;

  /// 获取当前颜色的禁用颜色变体
  /// [withAlpha] [0~255] 值越大, 越不透明.
  /// [withOpacity] [0~1] 值越小, 越透明.
  Color get disabledColor => withValues(alpha: 0.6);

  /// 悬停时的透明颜色
  Color get withHoverAlphaColor => withValues(alpha: 0.1 /*[0~1]*/);

  /// 获取当前颜色的强调色,
  /// 值越小, 越弱调, 越暗, 黑色, min:0
  /// 值越大, 越强调, 越亮, 白色, max:100
  Color tone(int tone) => CorePalette.of(value).primary.get(tone).toColor();

  //--

  /// 调整一个颜色的色温
  /// [hue] 色温[0~360]
  /// @return 一个新的颜色
  Color withHue(double hue) =>
      HSLuvColor.fromColor(this).withHue(hue).toColor();

  /// 添加一个颜色的色温
  Color addHue(double add) => HSLuvColor.fromColor(this).addHue(add).toColor();

  /// 调整一个颜色的亮度
  /// [lightness]亮度[0~100]
  /// @return 一个新的颜色
  Color withBrightness(double brightness) =>
      HSLuvColor.fromColor(this).withLightness(brightness).toColor();

  /// 添加一个颜色的亮度[0~100]
  Color addBrightness(double add) =>
      HSLuvColor.fromColor(this).addLightness(add).toColor();

  /// 调整一个颜色的饱和度
  /// [saturation]饱和度[0~100]
  /// @return 一个新的颜色
  Color withSaturation(double saturation) =>
      HSLuvColor.fromColor(this).withSaturation(saturation).toColor();

  /// 添加一个颜色的饱和度
  Color addSaturation(double add) =>
      HSLuvColor.fromColor(this).addSaturation(add).toColor();
}

//endregion Color 扩展
