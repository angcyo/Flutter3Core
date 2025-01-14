import 'dart:io';

import 'package:image/image.dart' as imglib;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/25
///
///读取指定图片, 生成不同规格/不同尺寸的图片
/// - 支持输入任意格式
/// - 支持输出ico格式
/// - 支持输出png格式
/// - 支持输出任意尺寸
///
/// https://github.com/leanflutter/makeanyicon/tree/main/packages
void main() async {
  final inputPath =
      "android/app/src/main/res/mipmap-xhdpi/flutter_dash_255.png";
  final outputPath = ".output/flutter_dash_256.ico";
  final outputWidth = 256;
  final outputHeight = 256;

  //--
  final originImageFile = File(inputPath);
  //读取文件数据
  final bytes = originImageFile.readAsBytesSync();
  final imageFormat = imglib.findFormatForData(bytes);
  colorLog("图片格式->$imageFormat");
  //从数据从读取图片解码器
  final decoder = imglib.findDecoderForData(bytes)!;
  //解码图片
  imglib.Image originImage = decoder.decode(bytes)!;
  //imglib.Image originImage = imglib.decodePng(bytes)!;

  final resizedImage = imglib.copyResize(
    originImage,
    width: outputWidth,
    height: outputHeight,
    interpolation: imglib.Interpolation.average,
  );

  File outputFile = File(outputPath);
  if (!outputFile.parent.existsSync()) {
    outputFile.parent.createSync(recursive: true);
  }
  List<int> resizedImageData;
  if (outputPath.split("/").last.contains('.ico')) {
    resizedImageData = imglib.encodeIco(resizedImage);
  } else {
    resizedImageData = imglib.encodePng(resizedImage);
  }
  outputFile.writeAsBytesSync(resizedImageData);

  colorLog("输出->${outputFile.path}");
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

void colorErrorLog(dynamic msg, [int col = 9]) {
  print('\x1B[38;5;${col}m$msg');
}
