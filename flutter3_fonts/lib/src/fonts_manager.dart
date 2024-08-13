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

  FontsManager() {
    if (customFontPathList.isEmpty) {
      /*fileFolder("/").then((value) {
        customFontPathList.add(value);
      });*/
    }
  }

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

  //region ---自定义字体---

  /// 加载自定义字体的目录
  final List<String> customFontPathList = [];

  /// 自定义字体加载后的缓存
  final List<FontFamilyMeta> _customFontFamilyMetaList = [];

  /// 尝试直接加载自定义字体
  /// [fontFamily] 字体名称, 同时也是.ttf的文件名
  Future<bool> tryLoadCustomFontFamily(String? fontFamily) async {
    return tryLoadFontFamilyIn(customFontPathList, fontFamily);
  }

  /// 加载自定义字体
  /// 注意, 此方法会返回缓存数据, 所以对数据操作将影响后续的使用
  Future<List<FontFamilyMeta>> loadCustomFileFontFamilyList({
    bool parseVariant = false,
    bool? autoLoad = true,
    bool? reload,
    bool? waitLoad,
  }) async {
    if (reload == true) {
      _customFontFamilyMetaList.clear();
    }
    if (_customFontFamilyMetaList.isNotEmpty) {
      return _customFontFamilyMetaList;
    }
    _customFontFamilyMetaList.addAll(await loadFileFontFamilyListIn(
      customFontPathList,
      parseVariant: parseVariant,
      autoLoad: autoLoad,
      reload: reload,
      waitLoad: waitLoad,
    ));
    return _customFontFamilyMetaList;
  }

  /// 保存自定义字体
  /// [fontFilePath] 原始的字体文件路径
  /// [fontData] 字体数据
  /// [fontFileName] 字体数据的文件名
  Future<bool> saveCustomFontFamily({
    String? fontFilePath,
    Uint8List? fontData,
    String? fontFileName,
  }) async {
    final savePath = customFontPathList.firstOrNull;
    if (savePath == null) {
      return false;
    }

    if (fontFilePath != null) {
      final file = fontFilePath.file();
      if (await file.exists()) {
        //复制字体文件
        final saveFile = "$savePath/${file.fileName()}";
        await file.copy(saveFile);

        //加载字体
        if (_customFontFamilyMetaList.isNotEmpty) {
          final fontMeta = await loadFileFontFamily(saveFile, autoLoad: true);
          _customFontFamilyMetaList.add(fontMeta);
        }
        return true;
      }
    } else if (fontData != null && fontFileName != null) {
      //保存字体文件
      final saveFile = "$savePath/$fontFileName";
      await saveFile.file().writeAsBytes(fontData);

      //加载字体
      if (_customFontFamilyMetaList.isNotEmpty) {
        final fontMeta = await loadFileFontFamily(saveFile, autoLoad: true);
        _customFontFamilyMetaList.add(fontMeta);
      }
      return true;
    }
    return false;
  }

  //endregion ---自定义字体---

  //region ---系统字体---

  /// 加载系统字体的目录
  final List<String> systemFontPathList = [
    "/system/fonts",
    "/system/font",
    "/data/fonts",
    "/System/Library/Fonts",
  ];

  /// 系统字体加载后的缓存
  final List<FontFamilyMeta> _systemFontFamilyMetaList = [];

  /// 尝试直接加载系统字体
  /// [fontFamily] 字体名称, 同时也是.ttf的文件名
  Future<bool> tryLoadSystemFontFamily(String? fontFamily) async {
    return tryLoadFontFamilyIn(systemFontPathList, fontFamily);
  }

  /// 加载系统字体
  /// 注意, 此方法会返回缓存数据, 所以对数据操作将影响后续的使用
  Future<List<FontFamilyMeta>> loadSystemFileFontFamilyList({
    bool parseVariant = false,
    bool? autoLoad = true,
    bool? reload,
    bool? waitLoad,
  }) async {
    if (reload == true) {
      _systemFontFamilyMetaList.clear();
    }
    if (_systemFontFamilyMetaList.isNotEmpty) {
      return _systemFontFamilyMetaList;
    }
    _systemFontFamilyMetaList.addAll(await loadFileFontFamilyListIn(
      systemFontPathList,
      parseVariant: parseVariant,
      autoLoad: autoLoad,
      reload: reload,
      waitLoad: waitLoad,
    ));
    return _systemFontFamilyMetaList;
  }

  //endregion ---系统字体---

  /// 加载字体
  /// [FontFamilyMeta]
  Future<bool> loadFontFamily(FontFamilyMeta fontFamilyMeta) async {
    bool result = fontFamilyMeta.variantList.isNotEmpty;
    for (final variantMeta in fontFamilyMeta.variantList) {
      try {
        result = result &&
            await loadFontFamilyVariant(
              variantMeta,
              fontFamilyMeta.source,
              savePath: fontFamilyMeta.savePath,
              overwrite: fontFamilyMeta.overwrite,
            );
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
    return result;
  }

  /// 加载字体变种
  /// [FontFamilyVariantMeta]
  Future<bool> loadFontFamilyVariant(
    FontFamilyVariantMeta variantMeta,
    FontFamilySource? source, {
    String? savePath,
    bool? overwrite,
  }) async {
    if (source == null) {
      return false;
    }

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
  }) =>
      asyncFuture<List<FontFamilyMeta>>((completer) async {
        final list = <FontFamilyMeta>[];
        final filesStream = path.file().listFilesStream();
        filesStream.listen((file) async {
          final uri = file.path;
          final meta = await loadFileFontFamily(uri,
              parseVariant: parseVariant,
              autoLoad: autoLoad,
              waitLoad: waitLoad);

          //
          final displayFontFamily = meta.displayFontFamily;
          final find =
              list.findFirst((e) => e.displayFontFamily == displayFontFamily);
          if (find == null) {
            list.add(meta);
          } else {
            //新的变种
            find.variantList.addAll(meta.variantList);
          }

          //await futureDelay(1.seconds);
        }, onDone: () {
          if (!completer.isCompleted) {
            completer.complete(list);
          }
        }, onError: (e, stack) {
          completer.completeError(e, stack);
        });
      });

  /// 从文件中加载字体
  /// [parseVariant] 是否解析变种
  /// [autoLoad] 是否自动加载
  /// [FontFamilyMeta]
  Future<FontFamilyMeta> loadFileFontFamily(
    String filePath, {
    bool parseVariant = false,
    bool? autoLoad,
    bool? waitLoad,
  }) async {
    final fontFamily = filePath.fileName(true);
    final filename = filePath.fileName(false);

    //debugger();

    final variantMeta = parseVariant
        ? FontFamilyVariantMeta.fromFilename(filename, filePath: filePath)
        : FontFamilyVariantMeta(
            displayFontFamily: fontFamily,
            fontFamily: fontFamily,
            uri: filePath,
          );

    //
    if (autoLoad == true) {
      if (waitLoad == true) {
        await loadFontFamilyVariant(
          variantMeta,
          FontFamilySource.file,
          savePath: filePath,
          overwrite: autoLoad,
        );
      } else {
        loadFontFamilyVariant(
          variantMeta,
          FontFamilySource.file,
          savePath: filePath,
          overwrite: autoLoad,
        );
      }
    }

    //
    final displayFontFamily = variantMeta.displayFontFamily;
    final meta = FontFamilyMeta(
      displayFontFamily: displayFontFamily,
      source: FontFamilySource.file,
    );
    return meta;
  }

  //--

  /// 尝试在文件夹[pathList]中加载字体
  /// [fontFamily] 字体名称, 同时也是.ttf的文件名
  Future<bool> tryLoadFontFamilyIn(
      List<String> pathList, String? fontFamily) async {
    if (isNil(fontFamily)) {
      return false;
    }
    for (final path in pathList) {
      final filePath = "$path/$fontFamily.ttf";
      try {
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
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
    return false;
  }

  /// 在文件夹中加载字体
  Future<List<FontFamilyMeta>> loadFileFontFamilyListIn(
    List<String> pathList, {
    bool parseVariant = false,
    bool? autoLoad = true,
    bool? reload,
    bool? waitLoad,
  }) async {
    final List<FontFamilyMeta> resultList = [];
    for (final path in pathList) {
      try {
        final list = await loadFileFontFamilyList(
          path,
          parseVariant: parseVariant,
          autoLoad: autoLoad,
          waitLoad: waitLoad,
        );
        resultList.addAll(list);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
    return resultList;
  }
}

/// 字体管理
final FontsManager $fontsManager = FontsManager();
