part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 用来显示快捷键的小部件
/// - [ShortcutConfigBean]
class ShortcutLabelWidget extends StatelessWidget {
  final ShortcutConfigBean? configBean;

  //--

  @defInjectMark
  final TextStyle? textStyle;

  const ShortcutLabelWidget({super.key, this.configBean, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return configBean == null
        ? empty
        : configBean!.getShortcutLabel().text(
            textStyle: textStyle ?? globalTheme.textDesStyle,
          );
  }
}
