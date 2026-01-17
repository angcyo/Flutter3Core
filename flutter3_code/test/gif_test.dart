import 'package:image/image.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
void main() async {
  //解码gif图片
  final path = "/Users/angcyo/Downloads/android.gif";
  //final gif = GifDecoder().decode(File(path).readAsBytesSync());
  final anim = await decodeGifFile(path);
  // The frames property stores the frames of the animation. If the image didn't have any animation,
  // frames would have a single element, the image itself.
  for (final frame in anim!.frames) {
    print(
      "${frame.frameIndex} ${frame.frameDuration} ${frame.formatType} ${frame.format} ${frame.frameType} ${frame.backgroundColor} ${frame.exif} ",
    );
    final name = 'build/.output/animated_${frame.frameIndex}';
    if (frame.frameIndex == 0) {
      //第一帧 就是图像本身
      await encodeGifFile('$name.gif', frame);
    } else {
      await encodePngFile('$name.png', frame);
    }
  }
  print("...end");
}
