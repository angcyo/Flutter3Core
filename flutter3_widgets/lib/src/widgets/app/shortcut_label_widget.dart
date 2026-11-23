part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 用来显示快捷键的小部件
/// - [ShortcutConfigBean]
///
/// [ShortcutLabelWidget] 用来显示快捷键
/// [ShortcutRecorderWidget] 用来记录快捷键
///
class ShortcutLabelWidget extends StatelessWidget {
  /// 快捷键配置信息
  final ShortcutConfigBean? configBean;

  /// 无快捷键时的默认小部件
  final Widget? defWidget;

  //--style

  /// 文本样式
  @defInjectMark
  final TextStyle? textStyle;

  const ShortcutLabelWidget({
    super.key,
    this.configBean,
    this.defWidget,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final label = configBean?.getShortcutLabel();
    return isNil(label)
        ? defWidget ?? empty
        : label!.text(textStyle: textStyle ?? globalTheme.textDesStyle);
  }
}
