import 'dart:io';

import 'package:image/image.dart' as imglib;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/25
///
/// https://github.com/leanflutter/makeanyicon/tree/main/packages
void main() async {
  //读取指定图片, 生成不同规格/不同尺寸的图片
  final inputPath =
      "android/app/src/main/res/mipmap-xhdpi/flutter_dash_255.png";
  final outputPath = ".output/flutter_dash_256.ico";
  final outputWidth = 256;
  final outputHeight = 256;

  //--
  final originImageFile = File(inputPath);
  imglib.Image originImage =
      imglib.decodePng(originImageFile.readAsBytesSync())!;

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
