library flutter3_fonts;

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:http/http.dart' as http;

export 'package:google_fonts/google_fonts.dart';

part 'src/font_family_meta.dart';
part 'src/font_family_tile.dart';
part 'src/fonts_loader.dart';
part 'src/fonts_manager.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// flutter默认字体,
/// 在[ThemeData]中决定并初始化,
/// ```
/// // TYPOGRAPHY & ICONOGRAPHY
/// typography ??= useMaterial3
///   ? Typography.material2021(platform: platform, colorScheme: colorScheme)
///   : Typography.material2014(platform: platform);
/// ```
/// [Typography.material2021]
/// [Typography._withPlatform]
///
/// 最终:
/// - iOS 'CupertinoSystemDisplay'
/// [Typography.blackCupertino]
/// [Typography.whiteCupertino]
/// - Android 'Roboto'
/// [Typography.blackMountainView]
/// [Typography.whiteMountainView]
///
class SystemChineseFont {
  const SystemChineseFont._();

  /// Chinese font family fallback, for iOS & macOS
  static const List<String> appleFontFamily = [
    // '.SF UI Text',
    '.AppleSystemUIFont',
    'PingFang SC',
  ];

  /// Chinese font family fallback, for xiaomi & redmi phone
  static const List<String> xiaomiFontFamily = [
    'miui',
    'mipro',
  ];

  /// Chinese font family fallback, for windows
  static const List<String> windowsFontFamily = [
    'Microsoft YaHei',
  ];

  static const systemFont = "system-font";

  static bool systemFontLoaded = false;

  /// Chinese font family fallback, for VIVO Origin OS 1.0
  static final vivoSystemFont = FontFamilyMeta(
    displayFontFamily: systemFont,
    source: FontFamilySource.file,
  )..variantList.add(FontFamilyVariantMeta(
      displayFontFamily: "DroidSansFallbackMonster",
      fontFamily: "DroidSansFallbackMonster",
      uri: '/system/fonts/DroidSansFallbackMonster.ttf',
    ));

  /// Chinese font family fallback, for honor Magic UI 4.0
  static final honorSystemFont = FontFamilyMeta(
    displayFontFamily: systemFont,
    source: FontFamilySource.file,
  )..variantList.add(FontFamilyVariantMeta(
      displayFontFamily: "DroidSansChinese",
      fontFamily: "DroidSansChinese",
      uri: '/system/fonts/DroidSansChinese.ttf',
    ));

  /// Chinese font family fallback, for most platforms
  static List<String> get fontFamilyFallback {
    if (!systemFontLoaded) {
      // honorSystemFont.load();
      () async {
        final vivoFont = File("/system/fonts/VivoFont.ttf");
        final exist = await vivoFont.exists();
        if (exist) {
          final haveLinks = vivoFont
              .resolveSymbolicLinksSync()
              .contains("DroidSansFallbackBBK");
          if (haveLinks) {
            await vivoSystemFont.load();
          }
        }
      }();
      systemFontLoaded = true;
    }

    return [
      systemFont,
      "sans-serif",
      ...appleFontFamily,
      ...xiaomiFontFamily,
      ...windowsFontFamily,
    ];
  }

  /// Text style with updated fontFamilyFallback & fontVariations
  static TextStyle get textStyle {
    return const TextStyle().useSystemChineseFont();
  }

  /// Text theme with updated fontFamilyFallback & fontVariations
  static TextTheme textTheme(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return Typography.material2021()
            .white
            .apply(fontFamilyFallback: fontFamilyFallback);
      case Brightness.light:
        return Typography.material2021()
            .black
            .apply(fontFamilyFallback: fontFamilyFallback);
    }
  }
}

extension TextStyleUseSystemChineseFont on TextStyle {
  /// Add fontFamilyFallback & fontVariation to original font style
  TextStyle useSystemChineseFont() {
    return copyWith(
      fontFamilyFallback: [
        ...?fontFamilyFallback,
        ...SystemChineseFont.fontFamilyFallback,
      ],
      fontVariations: [
        ...?fontVariations,
        if (fontWeight != null)
          FontVariation('wght', (fontWeight!.index + 1) * 100),
      ],
    );
  }
}

extension TextThemeUseSystemChineseFont on TextTheme {
  /// Add fontFamilyFallback & fontVariation to original text theme
  TextTheme useSystemChineseFont(Brightness brightness) {
    return SystemChineseFont.textTheme(brightness).merge(this);
  }
}

extension ThemeDataUseSystemChineseFont on ThemeData {
  /// Add fontFamilyFallback & fontVariation to original theme data
  ThemeData useSystemChineseFont(Brightness brightness) {
    return copyWith(textTheme: textTheme.useSystemChineseFont(brightness));
  }
}
