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

    Widget result;

    /*run(() => content ?? filePath?.file().readStringSync()).get((value, error) {
      debugger();
    });*/

    String? body;
    try {
      body = content ?? filePath?.file().readStringSync();
      result = body?.text(selectable: true).paddingAll(kH) ??
          globalConfig.emptyPlaceholderBuilder.call(context, null);
    } catch (e) {
      result = globalConfig.errorPlaceholderBuilder.call(context, e);
    }

    return result
        .scroll(physics: kDefaultScrollPhysics)
        .position(all: 0)
        .stackOf(isDebug
            ? "${body?.length.toSizeStr()}${filePath == null ? '' : '\n$filePath'}"
                .text(textColor: Colors.white, fontSize: 8)
                .paddingSymmetric(horizontal: kH)
                .position(left: 0, top: 0)
            : null)
        .container(
          color: globalConfig.globalTheme.whiteBgColor,
        )
        .clipRadius(topRadius: kDefaultBorderRadiusXX);
  }
}
