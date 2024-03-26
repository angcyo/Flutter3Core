part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 简单的查看文本对话框
class SingleTextDialog extends StatelessWidget {
  /// 指定文件路径
  final String? filePath;

  /// 强行指定文本内容
  final String? content;

  const SingleTextDialog({
    super.key,
    this.filePath,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final body = content ?? filePath?.file().readAsStringSync();
    final result = body?.text().paddingAll(kX) ??
        globalConfig.emptyPlaceholderBuilder.call(context, null);
    return result
        .scroll()
        .container(
          color: globalConfig.globalTheme.whiteBgColor,
        )
        .clipRadius(topRadius: kDefaultBorderRadiusXX);
  }
}
