part of '../flutter3_fonts.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/13
///
/// 加载shx/svg字体
///
/// - [FontType.shx]
/// - [FontType.svg
class ShxLoader {
  ShxLoader._();

  /// 字体名:编码格式
  /// - `shift-jis`
  /// - `gbk`
  /// - `big5`
  /// - `euc-kr`
  final Map<String, String> _fontEncodingMap = {};

  /// 不同的shx字体, 对应了不同的编码格式
  /// - [configPath] 编码格式配置文件路径
  @initialize
  Future<void> initFontEncoding(String? configPath) async {
    if (configPath != null) {
      final json = await File(configPath).readAsString();
      final array = jsonDecode(json);
      for (final item in array) {
        String? key = item["file"]?.toString().substringStart(".");
        final name = item['name'];
        if (name is List) {
          key = name.getOrNull(0) ?? key;
        }
        if (key != null) {
          final encoding = item['encoding'];
          if (encoding is String) {
            _fontEncodingMap[key] = item['encoding'];
          }
        }
      }
    }
  }

  /// 查找字体编码格式
  /// - [fontPathList]字体路径, 文件名就是字体名
  @api
  List<String>? findFontEncodingList(List<String>? fontPathList) {
    if (fontPathList != null) {
      final result = <String>[];
      for (final fontPath in fontPathList) {
        final fileName = fontPath.fileName(true);
        final key = fileName;
        final encoding = _fontEncodingMap[key];
        result.add(encoding ?? "");
      }
      return result;
    }
    return null;
  }

  /// 加载字体中的字符路径
  /// - [fontMeta] 字体信息
  /// - [text] 字符串
  /// - [fontPath] 字体文件路径集合
  /// @return 字符对应的[Path]字符路径映射
  @configProperty
  Map<String, Path?> Function(
    FontFamilyMeta? fontMeta,
    String? text,
    List<String>? fontPathList,
  )?
  loadTextPath;
}

@globalInstance
ShxLoader $shxLoader = ShxLoader._();
