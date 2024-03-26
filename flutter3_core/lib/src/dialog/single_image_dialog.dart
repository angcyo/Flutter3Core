part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 简单的图片对话框
class SingleImageDialog extends StatelessWidget {
  /// 指定文件路径
  final String? filePath;

  /// 强行指定图片内容
  final UiImage? content;

  const SingleImageDialog({
    super.key,
    this.filePath,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final Future<UiImage?>? body =
        content != null ? Future(() => content) : filePath?.toImageFromFile();
    return body!
        .toWidget((value) => value!.toImageWidget())
        /*.scroll()*/
        /*.container(
          color: globalConfig.globalTheme.whiteBgColor,
        )*/
        /*.clipRadius(topRadius: kDefaultBorderRadiusXX)*/;
  }
}
