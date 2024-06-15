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

  /// 加载字体
  Future<bool> loadFontFamily(FontFamilyMeta fontFamilyMeta) async {
    final key = fontFamilyMeta.uri;
    final load = _uriLoadCache[key];
    if (load == true) {
      //已经加载成功过
      return false;
    }
    if (load == null) {
      //还未加载
      _uriLoadCache[key] = false;
      try {
        await fontFamilyMeta.load();
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
  /// [autoLoad] 是否自动加载
  /// [FontFamilyMeta]
  Future<List<FontFamilyMeta>> loadFileFontFamilyList(String path,
      {bool? autoLoad}) async {
    final list = <FontFamilyMeta>[];
    final files = await path.file().listFiles();

    if (files != null) {
      for (final file in files) {
        final uri = file.path;
        final fontFamily = file.fileName(true);
        final meta = FontFamilyMeta(
          fontFamily: fontFamily,
          uri: uri,
          source: FontFamilySource.file,
        );
        list.add(meta);

        //
        if (autoLoad == true) {
          loadFontFamily(meta);
        }
      }
    }

    return list;
  }
}

final FontsManager $fontsManager = FontsManager();
