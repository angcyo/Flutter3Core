part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体管理
///
/// # system_fonts: ^1.0.1
/// https://pub.dev/packages/system_fonts
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

  /// 导出Assets字体到磁盘本地
  /// - [assetFontFolderKey] 资源文件夹名称 `assets/fonts/
  /// - [saveFolder] 保存到磁盘的目录
  /// - [excludeNameList] 排除的文件名列表(含扩展名)
  /// - [override]
  static Future<void> exportAssetsFontToDisk(
    String? assetFontFolderKey,
    String? saveFolder, {
    List<String>? excludeNameList,
    bool? override,
  }) async {
    final keyList = await loadAssetListInFolder(assetFontFolderKey);
    if (keyList == null || saveFolder == null) {
      return;
    }
    for (final key in keyList) {
      final name = key.fileName();
      if (excludeNameList?.contains(name) == true) {
        continue;
      }
      final filePath = joinPath(saveFolder, name);
      final file = filePath.file();
      if (override == true || !file.existsSync()) {
        final bytes = await loadAssetBytes(key);
        await file.writeAsBytes(bytes);
      }
    }
    await $shxLoader.initFontEncoding(joinPath(saveFolder, "shx-fonts.json"));
  }

  /// 所有默认字体对应的本地文件路径
  /// [filterDisplayFontFamilyList] 需要过滤的字体名称列表, 不指定则返回所有
  static List<FontFamilyVariantMeta> getFontFamilyVariantMetaList(
    List<FontFamilyMeta> metaList, {
    List<String>? filterDisplayFontFamilyList,
  }) {
    final result = <FontFamilyVariantMeta>[];
    for (final meta in metaList) {
      for (final variant in meta.variantList) {
        if (variant.localPath != null) {
          if (filterDisplayFontFamilyList == null ||
              filterDisplayFontFamilyList.isEmpty) {
            result.add(variant);
          } else if (filterDisplayFontFamilyList.contains(
            variant.displayFontFamily,
          )) {
            result.add(variant);
          }
        }
      }
    }
    return result;
  }

  /// 所有默认字体对应的本地文件路径
  /// [filterDisplayFontFamilyList] 需要过滤的字体名称列表, 不指定则返回所有
  static List<String> getFontFamilyLocalPathList(
    List<FontFamilyMeta> metaList, {
    List<String>? filterDisplayFontFamilyList,
  }) => getFontFamilyVariantMetaList(
    metaList,
    filterDisplayFontFamilyList: filterDisplayFontFamilyList,
  ).map<String>((e) => e.localPath!).toList();

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

  /// 根据字体名称, 获取字体对应的本地文件路径
  List<String> getFontFamilyLocalPathListByFamily(String? displayFontFamily) {
    if (displayFontFamily == null) {
      return [];
    }
    return [
      ...getFontFamilyLocalPathList(
        customFontFamilyMetaList,
        filterDisplayFontFamilyList: [displayFontFamily],
      ),
      ...getFontFamilyLocalPathList(
        systemFontFamilyMetaList,
        filterDisplayFontFamilyList: [displayFontFamily],
      ),
      ...getFontFamilyLocalPathList(
        defaultFontFamilyMetaList,
        filterDisplayFontFamilyList: [displayFontFamily],
      ),
    ];
  }

  //region ---默认字体---

  /// 默认字体加载后的缓存, 默认数据在内存中
  /// - 显示在最顶上
  /// - [defaultFontFamilyMetaList]
  /// - [customFontFamilyMetaList]
  final List<FontFamilyMeta> defaultFontFamilyMetaList = [];

  /// 所有默认字体对应的本地文件路径
  List<String> get defaultFontLocalPathList =>
      getFontFamilyLocalPathList(defaultFontFamilyMetaList);

  /// 加载默认字体到系统中
  Future<bool> loadDefaultFont(FontFamilyMeta fontMeta) async {
    if (defaultFontFamilyMetaList.contains(fontMeta)) {
      return true;
    }
    final result = await loadFontFamily(fontMeta);
    if (result) {
      defaultFontFamilyMetaList.add(fontMeta);
    }
    return result;
  }

  //endregion ---默认字体---

  //region ---自定义字体---

  /// 加载自定义字体的目录, 包含自定义的字体路径
  /// - [saveCustomFontFamily]
  /// - [deleteCustomFontFamily]
  final List<String> customFontPathList = [];

  /// 自定义字体加载后的缓存, 包含导入的字体
  /// - [defaultFontFamilyMetaList]
  /// - [customFontFamilyMetaList]
  final List<FontFamilyMeta> customFontFamilyMetaList = [];

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
    //debugger();
    if (reload == true) {
      customFontFamilyMetaList.clear();
    }
    if (customFontFamilyMetaList.isNotEmpty) {
      return customFontFamilyMetaList;
    }
    customFontFamilyMetaList.addAll(
      await loadFileFontFamilyListIn(
        customFontPathList,
        parseVariant: parseVariant,
        autoLoad: autoLoad,
        reload: reload,
        waitLoad: waitLoad,
      ),
    );
    return customFontFamilyMetaList;
  }

  /// 保存自定义字体, 自动添加到[customFontFamilyMetaList]
  /// [fontFilePath] 原始的字体文件路径
  /// [fontData] 字体数据
  /// [fontFileName] 字体数据的文件名
  Future<bool> saveCustomFontFamily({
    String? fontFilePath,
    Uint8List? fontData,
    FontType? fontType,
    String? fontFileName,
    bool autoLoad = true,
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
        if (autoLoad && customFontFamilyMetaList.isNotEmpty) {
          final fontMeta = await loadFileFontFamily(
            saveFile,
            fontType ?? FontType.fromPath(fontFilePath) ?? .ttf,
            autoLoad: true,
          );
          customFontFamilyMetaList.add(fontMeta);
        }
        return true;
      }
    } else if (fontData != null && fontFileName != null) {
      //保存字体文件
      final saveFile = "$savePath/$fontFileName";
      await saveFile.file().writeAsBytes(fontData);

      //加载字体
      if (autoLoad && customFontFamilyMetaList.isNotEmpty) {
        final fontMeta = await loadFileFontFamily(
          saveFile,
          fontType ?? FontType.fromPath(saveFile) ?? .ttf,
          autoLoad: true,
        );
        customFontFamilyMetaList.add(fontMeta);
      }
      return true;
    }
    return false;
  }

  /// 删除自定义的字体, 并删除对应的文件
  /// [customFontFamilyMetaList]
  Future<bool> deleteCustomFontFamily(
    List<FontFamilyMeta> fontFamilyMetaList,
  ) async {
    //删除成功的字体
    List<FontFamilyMeta> removeFamilyMetaList = [];
    dynamic error;
    for (final fontFamilyMeta in fontFamilyMetaList) {
      try {
        for (final fontVariantMeta in fontFamilyMeta.variantList) {
          if (await fontVariantMeta.uri.isExists()) {
            await fontVariantMeta.uri.delete();
            assert(() {
              l.i(
                '删除字体文件[${fontFamilyMeta.displayFontFamily}]->${fontVariantMeta.uri}',
              );
              return true;
            }());
          }
        }
        removeFamilyMetaList.add(fontFamilyMeta);
      } catch (e, s) {
        error ??= e;
        assert(() {
          printError(e, s);
          return true;
        }());
      }
    }
    if (removeFamilyMetaList.isNotEmpty) {
      customFontFamilyMetaList.removeAll(removeFamilyMetaList);
    }
    return removeFamilyMetaList.isNotEmpty && error == null;
  }

  //endregion ---自定义字体---

  //region ---系统字体---

  /// 加载系统字体的目录
  ///
  /// https://github.com/Mr-1311/system_fonts/blob/master/lib/system_fonts.dart
  List<String>? _systemFontPathList;

  List<String> get systemFontPathList {
    if (_systemFontPathList == null) {
      if (isWindows) {
        _systemFontPathList = [
          '${Platform.environment['windir']}/fonts/',
          '${Platform.environment['USERPROFILE']}/AppData/Local/Microsoft/Windows/Fonts/',
        ];
      } else if (isMacOS) {
        _systemFontPathList = [
          '/Library/Fonts/',
          '/System/Library/Fonts/',
          '${Platform.environment['HOME']}/Library/Fonts/',
        ];
      } else if (isLinux) {
        _systemFontPathList = [
          '/usr/share/fonts/',
          '/usr/local/share/fonts/',
          '${Platform.environment['HOME']}/.local/share/fonts/',
        ];
      } else {
        _systemFontPathList = [
          "/system/fonts",
          "/system/font",
          "/data/fonts",
          "/System/Library/Fonts",
        ];
      }
    }
    return _systemFontPathList ?? [];
  }

  /// 系统字体加载后的缓存
  final List<FontFamilyMeta> systemFontFamilyMetaList = [];

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
      systemFontFamilyMetaList.clear();
    }
    if (systemFontFamilyMetaList.isNotEmpty) {
      return systemFontFamilyMetaList;
    }
    systemFontFamilyMetaList.addAll(
      await loadFileFontFamilyListIn(
        systemFontPathList,
        parseVariant: parseVariant,
        autoLoad: autoLoad,
        reload: reload,
        waitLoad: waitLoad,
      ),
    );
    return systemFontFamilyMetaList;
  }

  //endregion ---系统字体---

  /// 加载字体
  /// [FontFamilyMeta]
  Future<bool> loadFontFamily(FontFamilyMeta fontFamilyMeta) async {
    bool result = fontFamilyMeta.variantList.isNotEmpty;
    for (final variantMeta in fontFamilyMeta.variantList) {
      try {
        result =
            result &&
            await loadFontFamilyVariant(
              variantMeta,
              fontFamilyMeta.source,
              savePath: fontFamilyMeta.savePath,
              overwrite: fontFamilyMeta.overwrite,
              exportAssetsFont: fontFamilyMeta.exportAssetsFont,
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

  /// 加载字体变种到内存中
  /// [FontFamilyVariantMeta]
  Future<bool> loadFontFamilyVariant(
    FontFamilyVariantMeta variantMeta,
    FontFamilySource? source, {
    String? savePath,
    bool? overwrite,
    bool? exportAssetsFont,
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
          exportAssetsFont: exportAssetsFont,
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
  }) => asyncFuture<List<FontFamilyMeta>>((completer) async {
    final list = <FontFamilyMeta>[];
    final filesStream = path.file().listFilesStream();
    filesStream.listen(
      (file) async {
        final uri = file.path;
        final fontType = FontType.fromPath(uri);
        if (fontType != null) {
          final meta = await loadFileFontFamily(
            uri,
            fontType,
            parseVariant: parseVariant,
            autoLoad: autoLoad,
            waitLoad: waitLoad,
          );

          //
          final displayFontFamily = meta.displayFontFamily;
          final find = list.findFirst(
            (e) => e.displayFontFamily == displayFontFamily,
          );
          if (find == null) {
            list.add(meta);
          } else {
            //新的变种
            find.variantList.addAll(meta.variantList);
          }
          //await futureDelay(1.seconds);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(list);
        }
      },
      onError: (e, stack) {
        completer.completeError(e, stack);
      },
    );
  });

  /// 从文件中加载字体
  /// [parseVariant] 是否解析变种
  /// [autoLoad] 是否自动加载
  /// [FontFamilyMeta]
  Future<FontFamilyMeta> loadFileFontFamily(
    String filePath,
    FontType fontType, {
    bool parseVariant = false,
    bool? autoLoad,
    bool? waitLoad,
  }) async {
    final fontFamily = filePath.fileName(true);
    final filename = filePath.fileName(false);

    //debugger();

    final variantMeta = parseVariant
        ? FontFamilyVariantMeta.fromFilename(
            filename,
            filePath: filePath,
            fontType: fontType,
          )
        : FontFamilyVariantMeta(
            displayFontFamily: fontFamily,
            fontFamily: fontFamily,
            uri: filePath,
            fontType: fontType,
            filePath: filePath,
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
      /*savePath: filePath,*/
      variantList: [variantMeta],
    );
    return meta;
  }

  //--

  /// 尝试在文件夹[pathList]中加载字体
  /// [fontFamily] 字体名称, 同时也是.ttf的文件名
  Future<bool> tryLoadFontFamilyIn(
    List<String> pathList,
    String? fontFamily,
  ) async {
    if (isNil(fontFamily)) {
      return false;
    }
    for (final path in pathList) {
      for (final fontType in FontType.values) {
        final filePath = "$path/$fontFamily${fontType.suffix}";
        try {
          if (await filePath.file().exists()) {
            final variantMeta = FontFamilyVariantMeta(
              displayFontFamily: fontFamily!,
              fontFamily: fontFamily,
              uri: filePath,
              fontType: fontType,
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

/// 字体类型列表
enum FontType {
  /// ttf
  /// (TrueType Font)：最常用、兼容性最好的格式。
  ttf('.ttf'),

  /// otf
  /// (OpenType Font)：功能更强大，支持更高级的排版特性。
  otf('.otf'),

  /// ttc
  /// (TrueType Collection)：TrueType 字体集合文件，允许在一个文件中包含多个字体。
  //ttc('.ttc'),

  /// shx
  /// https://mlightcad.github.io/shx-parser/
  shx('.shx'),

  /// svg
  /// Hershey Vector Font
  /// https://paulbourke.net/dataformats/hershey/
  /// https://gitlab.com/inkscape/inkscape
  svg('.svg');

  /// 后缀
  final String suffix;

  const FontType(this.suffix);

  static FontType? fromPath(String? path) {
    if (isNil(path)) {
      return null;
    }
    for (final type in FontType.values) {
      if (path!.endsWith(type.suffix)) {
        return type;
      }
    }
    return null;
  }
}

/// 字体管理
final FontsManager $fontsManager = FontsManager();
