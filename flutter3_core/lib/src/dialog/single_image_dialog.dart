part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 简单的图片对话框, 用于显示单张图片, 不支持放大缩小
/// [SingleImageDialog]
/// [SinglePhotoDialog]
class SingleImageDialog extends StatelessWidget {
  /// 指定文件路径
  final String? filePath;

  /// 强行指定图片内容
  final UiImage? content;

  /// 是否模糊背景
  final bool blur;

  const SingleImageDialog({
    super.key,
    this.filePath,
    this.content,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final Future<UiImage?>? body =
        content != null ? Future(() => content) : filePath?.toImageFromFile();
    return body!
            .toWidget((context, image) => image!
                .toImageWidget()
                .position(all: 0)
                .stackOf(isDebug
                    ? "${image.width}*${image.height} (${(image.width * image.height * 4).toSizeStr()})${filePath == null ? '' : '\n$filePath'}"
                        .text(textColor: Colors.white, fontSize: 8)
                        .padding(4, 2)
                        .shadowDecorated(decorationColor: Colors.black26)
                        .paddingSymmetric(horizontal: kH)
                        .position(left: 0, top: 0)
                    : null))
            .blur(sigma: blur ? kM : 0.0)
            .systemUiOverlay(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
            )
        /*.scroll()*/
        /*.container(
          color: globalConfig.globalTheme.whiteBgColor,
        )*/
        /*.clipRadius(topRadius: kDefaultBorderRadiusXX)*/;
  }
}
