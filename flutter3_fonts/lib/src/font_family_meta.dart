part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体描述元数据
class FontFamilyMeta {
  /// 字体名称
  String fontFamily;

  /// 字体资源路径
  String uri;

  /// 字体来源
  FontFamilySource source;

  /// http字体保存路径
  String? savePath;

  /// http文件是否覆盖
  bool? overwrite;

  FontFamilyMeta({
    required this.fontFamily,
    required this.uri,
    required this.source,
    this.savePath,
    this.overwrite,
  });

  static FontWeight _extractFontWeightFromApiFilenamePart(String filenamePart) {
    if (filenamePart.contains('Thin')) return FontWeight.w100;

    // ExtraLight must be checked before Light because of the substring match.
    if (filenamePart.contains('ExtraLight')) return FontWeight.w200;
    if (filenamePart.contains('Light')) return FontWeight.w300;

    if (filenamePart.contains('Medium')) return FontWeight.w500;

    // SemiBold and ExtraBold must be checked before Bold because of the
    // substring match.
    if (filenamePart.contains('SemiBold')) return FontWeight.w600;
    if (filenamePart.contains('ExtraBold')) return FontWeight.w800;
    if (filenamePart.contains('Bold')) return FontWeight.w700;

    if (filenamePart.contains('Black')) return FontWeight.w900;
    return FontWeight.w400;
  }

  static FontStyle _extractFontStyleFromApiFilenamePart(String filenamePart) {
    if (filenamePart.contains('Italic')) return FontStyle.italic;
    return FontStyle.normal;
  }

  /// 获取字体样式
  TextStyle textStyle({
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight:
          fontWeight ?? _extractFontWeightFromApiFilenamePart(fontFamily),
      fontStyle: fontStyle ?? _extractFontStyleFromApiFilenamePart(fontFamily),
    );
  }

  /// 加载字体
  Future<bool> load() async {
    assert(() {
      l.d("加载字体[$fontFamily]->$uri");
      return true;
    }());
    switch (source) {
      case FontFamilySource.asset:
        return FontsLoader.loadAssetFont(fontFamily, uri);
      case FontFamilySource.file:
        return FontsLoader.loadFileFont(fontFamily, uri);
      case FontFamilySource.http:
        return FontsLoader.loadHttpFont(
          fontFamily,
          uri,
          savePath: savePath,
          overwrite: overwrite,
        );
    }
  }
}

/// 字体来源
enum FontFamilySource { asset, file, http }
