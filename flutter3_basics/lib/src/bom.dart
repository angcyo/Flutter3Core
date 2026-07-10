part of '../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/10
///
/// BOM 是 Byte Order Mark 的缩写，翻译过来就是 “字节序标记”。
/// 编码格式	| BOM 头的十六进制数据 (Hex)		| 机器视角下的表现
/// ---|---|---
/// UTF-16 LE (小端序) |	FF FE	|也就是我们在配置 Windows desktop.ini 时必须指定的格式。
/// UTF-16 BE (大端序)	|FE FF	|高位在前，低位在后。
/// UTF-8	|EF BB BF	|很多 Windows 自带记事本保存的 UTF-8 会强制带上这个。
/// UTF-32 |LE	FF FE 00 00	| 极少使用，占用空间大。
abstract class BOM {
  /// 将 Windows desktop.ini 文件转换为 UTF-16 LE (带 BOM) 格式
  static Future<void> convertDesktopIniToUtf16LE() async {
    if (isWindows) {
      //final script = Platform.script;
      final fileName = "desktop.ini";
      final resolvedExecutable = Platform.resolvedExecutable;
      final resolvedExecutableDir = resolvedExecutable.parentPath;
      final sourceFile = File("$resolvedExecutableDir/$fileName");
      //final sourceFile2 = File("${fileName}");
      if (await sourceFile.exists()) {
        //读取前2个字节
        final List<int> bytes = await sourceFile.readAsBytes();
        if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
          //已经是 UTF-16 LE 格式
          //print("${fileName} 文件已存在，无需转换");
        } else {
          await convertToUtf16LE(
            sourcePath: sourceFile.path,
            targetPath: "$resolvedExecutableDir/$fileName",
          );
        }
      }
    }
  }

  /// 将任意 Dart 支持的文本文件转换为标准的 UTF-16 LE (带 BOM) 格式
  /// [sourcePath] 原始文件路径
  /// [targetPath] 转换后的目标文件路径
  /// [sourceDecoder] 原始文件的解码器，默认使用 UTF-8
  static Future<void> convertToUtf16LE({
    required String sourcePath,
    required String targetPath,
    Encoding sourceDecoder = utf8,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException("源文件不存在", sourcePath);
    }

    // 1. 读取源文件字节，并使用指定的解码器将其解析为内存中的 String
    final List<int> sourceBytes = await sourceFile.readAsBytes();
    final String content = sourceDecoder.decode(sourceBytes);

    // 2. 构造具有 UTF-16 LE 标志的字节缓冲区
    // 每个字符占用 2 字节，再加上 2 字节的 BOM 头 (0xFF, 0xFE)
    final int totalBytesNum = 2 + (content.length * 2);
    final Uint8List targetBytes = Uint8List(totalBytesNum);

    // 3. 写入标准的 UTF-16 LE BOM 头
    targetBytes[0] = 0xFF; // Low Byte
    targetBytes[1] = 0xFE; // High Byte

    // 4. 将字符串的每个字符（16位码位）拆分为两个字节，以小端序 (Little-Endian) 填入缓冲区
    int byteIndex = 2;
    for (int i = 0; i < content.length; i++) {
      int codeUnit = content.codeUnitAt(i);

      // 小端序逻辑：低位字节在低地址，高位字节在高地址
      targetBytes[byteIndex++] = codeUnit & 0xFF; // 提取低 8 位 (Low Byte)
      targetBytes[byteIndex++] = (codeUnit >> 8) & 0xFF; // 提取高 8 位 (High Byte)
    }

    // 5. 写入目标文件 (直接安全覆盖)
    final targetFile = File(targetPath);
    await targetFile.writeAsBytes(targetBytes, mode: FileMode.write);
  }
}
