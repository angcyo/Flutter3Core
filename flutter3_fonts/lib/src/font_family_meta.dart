part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体描述元数据
class FontFamilyMeta {
  /// 字体名称, 不包含字宽和字体的样式
  /// 用来显示的字体名称
  String displayFontFamily;

  /// 字体来源
  /// 不指定则没有来源. 则不加载字体,
  /// 则使用默认[TextStyle]
  FontFamilySource? source;

  /// http字体下载时保存路径
  String? savePath;

  /// http文件下载时是否覆盖
  bool? overwrite;

  /// 当前字体支持的变种列表
  /// [displayFontFamily]-[fontWeight][fontStyle].[fileExtension]
  List<FontFamilyVariantMeta> variantList;

  FontFamilyMeta({
    required this.displayFontFamily,
    this.source,
    this.savePath,
    this.overwrite,
    this.variantList = const [],
  });

  /// 获取字体样式
  TextStyle textStyle({
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    //通过[fontWeight].[fontStyle]查找变体名称, 从而获取真正的字体名称
    final find = FontFamilyVariantMeta.closestMatch(
            fontWeight, fontStyle, variantList) ??
        variantList.firstOrNull;
    //debugger();
    if (find != null) {
      /*assert(() {
        l.d('[${fontWeight}][${fontStyle}]匹配到字体:${find.fontFamily}');
        return true;
      }());*/
    }
    if (source == null) {
      return const TextStyle();
    }
    return TextStyle(
      fontFamily: find?.fontFamily ?? displayFontFamily,
      fontWeight: find?.fontWeight ?? fontWeight ?? FontWeight.normal,
      fontStyle: find?.fontStyle ?? fontStyle ?? FontStyle.normal,
    );
  }

  /// 加载字体
  /// ```
  /// /system/fonts/Miui-Bold.ttf
  /// /system/fonts/Miui-Light.ttf
  /// /system/fonts/Miui-Regular.ttf
  /// /system/fonts/Miui-Thin.ttf
  ///
  /// /system/fonts/Roboto-Black.ttf
  /// /system/fonts/Roboto-BlackItalic.ttf
  /// /system/fonts/Roboto-Bold.ttf
  /// /system/fonts/Roboto-BoldItalic.ttf
  /// /system/fonts/Roboto-Italic.ttf
  /// /system/fonts/Roboto-Light.ttf
  /// /system/fonts/Roboto-LightItalic.ttf
  /// /system/fonts/Roboto-Medium.ttf
  /// /system/fonts/Roboto-MediumItalic.ttf
  /// /system/fonts/Roboto-Regular.ttf
  /// /system/fonts/Roboto-Thin.ttf
  /// /system/fonts/Roboto-ThinItalic.ttf
  /// ```
  Future<bool> load() async {
    if (source == null) {
      return false;
    }
    bool result = variantList.isNotEmpty;
    for (final variant in variantList) {
      result = result &&
          await variant.load(
            source!,
            savePath: savePath,
            overwrite: overwrite,
          );
    }
    return result;
  }
}

/// 字体来源
enum FontFamilySource { asset, file, http }

/// 字体变体
/// Roboto-MediumItalic.ttf
/// [Roboto]字体名称
/// [-] 分隔符
/// [Medium]字体粗细
/// [Italic]字体样式
/// [.ttf]扩展名
class FontFamilyVariantMeta {
  /// 用来显示的字体名称
  String displayFontFamily;

  /// 这里的字体名称, 包含了[fontWeightStr]和[fontStyleStr]
  String fontFamily;

  /// 当前字体变种的资源路径
  String uri;

  /// 扩展名, 如果有
  String? fileExtension;

  /// 支持的字体粗细
  String? fontWeightStr;

  FontWeight fontWeight = FontWeight.normal;

  /// 支持的字体样式
  String? fontStyleStr;

  FontStyle fontStyle = FontStyle.normal;

  /// 匹配最接近的变体
  static FontFamilyVariantMeta? closestMatch(
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Iterable<FontFamilyVariantMeta> variantsToCompare,
  ) {
    int? bestScore;
    FontFamilyVariantMeta? bestMatch;
    final sourceVariant = FontFamilyVariantMeta(
      displayFontFamily: '',
      fontFamily: '',
      uri: '',
    )
      ..fontWeight = fontWeight ?? FontWeight.normal
      ..fontStyle = fontStyle ?? FontStyle.normal;
    for (final variantToCompare in variantsToCompare) {
      final score = _computeMatch(sourceVariant, variantToCompare);
      if (bestScore == null || score < bestScore) {
        bestScore = score;
        bestMatch = variantToCompare;
      }
    }
    return bestMatch;
  }

  static int _computeMatch(FontFamilyVariantMeta a, FontFamilyVariantMeta b) {
    if (a == b) {
      return 0;
    }
    int score = (a.fontWeight.index - b.fontWeight.index).abs();
    if (a.fontStyle != b.fontStyle) {
      score += 2;
    }
    return score;
  }

  /// 字体变体
  FontFamilyVariantMeta({
    required this.displayFontFamily,
    required this.fontFamily,
    required this.uri,
    this.fontWeightStr,
    this.fontStyleStr,
  }) {
    if (fontWeightStr != null) {
      for (final entry in _fontWeightMap.entries) {
        if (entry.value == fontWeightStr) {
          fontWeight = entry.key;
          break;
        }
      }
    }

    if (fontStyleStr != null) {
      if (_fontStyleList.contains(fontStyleStr)) {
        fontStyle =
            fontStyleStr == 'Italic' ? FontStyle.italic : FontStyle.normal;
      }
    }
  }

  /// 从文件名解析
  /// [filename] 文件名, 包含扩展名
  FontFamilyVariantMeta.fromFilename(
    String filename, {
    String? filePath,
  })  : displayFontFamily = filename,
        fontFamily = filename,
        uri = filePath ?? filename {
    //debugger();
    final filenameParts = filename.split('.');
    fontFamily = filenameParts.first;
    if (filenameParts.length > 1) {
      fileExtension = ".${filenameParts.last}";
    }

    final parts = fontFamily.split('-');
    displayFontFamily = parts.first;

    if (parts.length > 1) {
      final style = parts.last;
      for (final item in _fontStyleList) {
        if (style.contains(item)) {
          fontStyleStr = item;
          fontStyle =
              fontStyleStr == 'Italic' ? FontStyle.italic : FontStyle.normal;
          break;
        }
      }

      for (final item in _fontWeightMap.entries) {
        if (style.contains(item.value)) {
          fontWeightStr = item.value;
          fontWeight = item.key;
          break;
        }
      }

      /*final styleList = style.matchList(r"[A-Z]{1,}[a-z]*");
        if (styleList.isNotEmpty) {
          fontWeight = styleList.first;
          fontStyle = styleList.last;
        } else {
          fontWeight = style;
        }

        final weight = style.split(RegExp(r'[a-zA-Z]')).first;
        fontStyle = style.substring(weight.length);
        fontWeight = weight;*/
    }
  }

  Future<bool> load(
    FontFamilySource source, {
    String? savePath,
    bool? overwrite,
  }) async {
    bool result = false;
    assert(() {
      l.d("加载字体[$fontFamily]->$uri");
      return true;
    }());
    switch (source) {
      case FontFamilySource.asset:
        result = await FontsLoader.loadAssetFont(fontFamily, uri);
      case FontFamilySource.file:
        result = await FontsLoader.loadFileFont(fontFamily, uri);
      case FontFamilySource.http:
        result = await FontsLoader.loadHttpFont(
          fontFamily,
          uri,
          savePath: savePath,
          overwrite: overwrite,
        );
    }
    return result;
  }

  @override
  String toString() {
    return 'FontFamilyVariantMeta{fontFamily: $fontFamily, displayFontFamily: $displayFontFamily, fileExtension: $fileExtension, '
        'fontWeight: $fontWeightStr, fontStyle: $fontStyleStr, uri: $uri, fileExtension: $fileExtension}';
  }
}

/// 字体样式列表
const _fontStyleList = ['Italic', 'Normal', 'Regular'];

/// 字宽列表
const _fontWeightMap = {
  FontWeight.w100: 'Thin',
  FontWeight.w200: 'ExtraLight',
  FontWeight.w300: 'Light',
  FontWeight.w400: 'Regular',
  FontWeight.w500: 'Medium',
  FontWeight.w600: 'SemiBold',
  FontWeight.w700: 'Bold',
  FontWeight.w800: 'ExtraBold',
  FontWeight.w900: 'Black',
};
