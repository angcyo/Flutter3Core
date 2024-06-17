part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体管理
class FontsManager {
  /// 字体加载缓存, 指定的uri是否已经加载过
  final Map<String, bool> _uriLoadCache = {};

  FontsManager();

  /*static FontWeight _extractFontWeightFromApiFilenamePart(String filenamePart) {
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
  }*/

  /// 加载系统字体
  final List<String> systemFontPath = [
    "/system/fonts",
    "/system/font",
    "/data/fonts",
    "/System/Library/Fonts",
  ];

  /// 系统字体的缓存
  final List<FontFamilyMeta> _systemFontFamilyMetas = [];

  /// 尝试直接加载系统字体
  /// [fontFamily] 字体名称, 同时也是.ttf的文件名
  Future<bool> tryLoadSystemFontFamily(String? fontFamily) async {
    if (isNil(fontFamily)) {
      return false;
    }
    for (final path in systemFontPath) {
      final filePath = "$path/$fontFamily.ttf";
      if (await filePath.file().exists()) {
        final variantMeta = FontFamilyVariantMeta(
          displayFontFamily: fontFamily!,
          fontFamily: fontFamily,
          uri: filePath,
        );
        return await loadFontFamilyVariant(
          variantMeta,
          FontFamilySource.file,
        );
      }
    }
    return false;
  }

  /// 加载系统字体
  Future<List<FontFamilyMeta>> loadSystemFileFontFamilyList({
    bool parseVariant = false,
    bool? autoLoad = true,
    bool? reload,
    bool? waitLoad,
  }) async {
    if (reload == true) {
      _systemFontFamilyMetas.clear();
    }
    if (_systemFontFamilyMetas.isNotEmpty) {
      return _systemFontFamilyMetas;
    }
    for (final path in systemFontPath) {
      final list = await loadFileFontFamilyList(
        path,
        parseVariant: parseVariant,
        autoLoad: autoLoad,
        waitLoad: waitLoad,
      );
      _systemFontFamilyMetas.addAll(list);
    }
    return _systemFontFamilyMetas;
  }

  /// 加载字体
  Future<bool> loadFontFamily(FontFamilyMeta fontFamilyMeta) async {
    bool result = fontFamilyMeta.variantList.isNotEmpty;
    for (var variantMeta in fontFamilyMeta.variantList) {
      result = result &&
          await loadFontFamilyVariant(
            variantMeta,
            fontFamilyMeta.source,
            savePath: fontFamilyMeta.savePath,
            overwrite: fontFamilyMeta.overwrite,
          );
    }
    return result;
  }

  /// 加载字体变种
  Future<bool> loadFontFamilyVariant(
    FontFamilyVariantMeta variantMeta,
    FontFamilySource source, {
    String? savePath,
    bool? overwrite,
  }) async {
    final key = variantMeta.uri;
    final load = _uriLoadCache[key];
    if (load == true) {
      //已经加载成功过
      return true;
    }
    if (load == null) {
      //还未加载
      _uriLoadCache[key] = false;
      try {
        await variantMeta.load(
          source,
          savePath: savePath,
          overwrite: overwrite,
        );
        _uriLoadCache[key] = true;
        return true;
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
        _uriLoadCache.remove(key);
      }
    }
    return false;
  }

  /// 从文件夹中读取字体列表
  /// [parseVariant] 是否解析变种
  /// [autoLoad] 是否自动加载
  /// [FontFamilyMeta]
  Future<List<FontFamilyMeta>> loadFileFontFamilyList(
    String path, {
    bool parseVariant = false,
    bool? autoLoad,
    bool? waitLoad,
  }) async {
    final list = <FontFamilyMeta>[];
    final files = await path.file().listFiles();

    if (files != null) {
      for (final file in files) {
        final uri = file.path;
        final fontFamily = file.fileName(true);
        final filename = file.fileName(false);

        //debugger();

        final variantMeta = parseVariant
            ? FontFamilyVariantMeta.fromFilename(filename, filePath: uri)
            : FontFamilyVariantMeta(
                displayFontFamily: fontFamily,
                fontFamily: fontFamily,
                uri: uri,
              );

        //
        if (autoLoad == true) {
          if (waitLoad == true) {
            await loadFontFamilyVariant(
              variantMeta,
              FontFamilySource.file,
              savePath: path,
              overwrite: autoLoad,
            );
          } else {
            loadFontFamilyVariant(
              variantMeta,
              FontFamilySource.file,
              savePath: path,
              overwrite: autoLoad,
            );
          }
        }

        //
        final displayFontFamily = variantMeta.displayFontFamily;
        final find =
            list.findFirst((e) => e.displayFontFamily == displayFontFamily);
        if (find == null) {
          //第一次添加
          final meta = FontFamilyMeta(
            displayFontFamily: displayFontFamily,
            source: FontFamilySource.file,
          );
          meta.variantList.add(variantMeta);
          list.add(meta);
        } else {
          //新的变种
          find.variantList.add(variantMeta);
        }
      }
    }
    return list;
  }
}

/// 字体管理
final FontsManager $fontsManager = FontsManager();
