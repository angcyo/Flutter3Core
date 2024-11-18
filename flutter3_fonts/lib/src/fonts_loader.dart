part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体加载,
/// 1. 加载系统字体
/// 2. 加载自定义字体
/// 3. 加载网络字体
/// 4. 加载本地字体
/// 5. 加载字体文件
/// 6. 加载ttf字体
/// 7. 加载otf字体
class FontsLoader {
  FontsLoader._();

  /// 加载assets中的字体
  static Future<bool> loadFont(Uint8List? bytes, {String? fontFamily}) async {
    try {
      if (bytes != null) {
        await loadFontFromList(bytes, fontFamily: fontFamily);
        return true;
      }
      return false;
    } catch (e) {
      assert(() {
        debugPrint("Font load error!!!");
        debugPrint(e.toString());
        return true;
      }());
      return false;
    }
  }

  /// 加载assets中的字体
  /// [fontFamily] 字体名称
  /// [uri] 字体资产key
  /// 返回是否加载成功
  static Future<(bool, ByteData?)> loadAssetFont(
    String fontFamily,
    String uri,
  ) async {
    try {
      final loader = FontLoader(fontFamily);
      final fontData = await rootBundle.load(uri);
      loader.addFont(Future.value(fontData));
      await loader.load();
      return (true, fontData);
    } catch (e) {
      assert(() {
        debugPrint("Font asset error!!!");
        debugPrint(e.toString());
        return true;
      }());
      return (false, null);
    }
  }

  /// 加载文件中的字体
  /// [fontFamily] 字体名称
  /// [uri] 字体文件路径
  static Future<bool> loadFileFont(
    String fontFamily,
    String uri,
  ) async {
    try {
      final bytes = await File(uri).readAsBytes();
      //debugger();
      await loadFontFromList(bytes, fontFamily: fontFamily);
      return true;
    } catch (e) {
      assert(() {
        debugPrint("Font file error!!!");
        debugPrint(e.toString());
        return true;
      }());
      return false;
    }
  }

  /// 加载网络中的字体
  /// [fontFamily] 字体名称
  /// [uri] 字体网络地址
  /// [savePath] 保存的路径
  /// @return 返回是否成功和本地文件路径
  static Future<(bool, String?)> loadHttpFont(
    String fontFamily,
    String uri, {
    String? savePath,
    bool? overwrite,
  }) async {
    try {
      final pair = await downloadFile(
        uri,
        savePath: savePath,
        overwrite: overwrite ?? false,
      );
      await loadFontFromList(pair.$1, fontFamily: fontFamily);
      return (true, pair.$2);
    } catch (e, s) {
      assert(() {
        debugPrint("Font download failed!!!");
        debugPrint(e.toString());
        debugPrint(s.toString());
        return true;
      }());
      return (false, null);
    }
  }

  //--

  /// 下载文件/下载字体到指定的文件路径, 并返回数据内容
  /// [url] 网络地址
  /// [savePath] 保存路径, 文件名是网络地址的最后一部分
  /// [overwrite] 是否覆盖原有的文件
  /// @return 返回数据字节和本地文件路径
  static Future<(Uint8List, String)> downloadFile(
    String url, {
    String? savePath,
    bool overwrite = false,
  }) async {
    final uri = Uri.parse(url);
    final filename = uri.pathSegments.last;

    //
    final dir = savePath ?? (await cacheFolder()).path;
    final file = File('$dir/$filename');

    if (await file.exists() && !overwrite) {
      return (await file.readAsBytes(), file.path);
    }

    final bytes = await downloadBytes(uri);
    file.writeAsBytes(bytes);
    return (bytes, file.path);
  }

  /// 下载文件到指定的文件路径
  static Future<void> downloadFileTo(
    String url, {
    required String filepath,
    bool overwrite = false,
  }) async {
    final uri = Uri.parse(url);
    final file = File(filepath);

    if (await file.exists() && !overwrite) return;
    await file.writeAsBytes(await downloadBytes(uri));
  }

  /// 下载数据内容
  static Future<Uint8List> downloadBytes(Uri uri) async {
    final client = http.Client();
    final request = http.Request('GET', uri);
    final response =
        await client.send(request).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw HttpException("status code ${response.statusCode}");
    }

    List<int> bytes = [];
    double prevPercent = 0;
    await response.stream.listen((List<int> chunk) {
      bytes.addAll(chunk);

      if (response.contentLength == null) {
        assert(() {
          debugPrint('download font: ${bytes.length} bytes');
          return true;
        }());
      } else {
        final percent = ((bytes.length / response.contentLength!) * 100);
        if (percent - prevPercent > 15 || percent > 99) {
          assert(() {
            debugPrint('download font: ${percent.toStringAsFixed(1)}%');
            return true;
          }());
          prevPercent = percent;
        }
      }
    }).asFuture();

    return Uint8List.fromList(bytes);
  }
}
