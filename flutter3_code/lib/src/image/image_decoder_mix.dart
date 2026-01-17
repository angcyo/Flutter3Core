part of '../../flutter3_code.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
/// 解码Gif图片转ui图片帧列表
/// - 非Gif图片只有一帧
Future<List<UiImage>?> decoderImageFrames({
  String? filePath,
  Uint8List? bytes,
}) async {
  if (filePath == null && bytes == null) {
    return null;
  }

  img.Decoder? decoder;
  if (filePath?.isFileExistsSync() == true) {
    bytes ??= await filePath!.toFile().readAsBytes();
    decoder =
        img.findDecoderForNamedImage(filePath!) ??
        img.findDecoderForData(bytes);
  } else {
    decoder = img.findDecoderForData(bytes!);
  }

  if (decoder == null) {
    l.w("未找到解码器->$filePath");
    return null;
  }

  final image = decoder.decode(bytes);
  if (image == null) {
    l.w("解码失败->$filePath");
    return null;
  }

  List<UiImage> result = [];
  final frames = image.frames;
  for (final frame in frames) {
    if (frame.frameIndex == 0 &&
        frames.length > 1 /*decoder is img.GifDecoder*/ ) {
      //动画帧, 第一帧就是图像本身
      continue;
    }
    result.add(await frame.uiImage);
  }

  return result;
}
