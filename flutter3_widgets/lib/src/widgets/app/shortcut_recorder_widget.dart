part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 快捷键录制小部件
class ShortcutRecorderWidget extends StatefulWidget {
  /// 录制完成的快捷键回调
  final void Function(ShortcutConfigBean? configBean)? onShortcutAction;

  const ShortcutRecorderWidget({super.key, this.onShortcutAction});

  @override
  State<ShortcutRecorderWidget> createState() => _ShortcutRecorderWidgetState();
}

class _ShortcutRecorderWidgetState extends State<ShortcutRecorderWidget> {
  ShortcutConfigBean? _configBean;

  late final TextFieldConfig _labelConfig = TextFieldConfig(
    hintTextBuilder: (ctx) => ctx.libRes?.libSetHotkeys,
    onChanged: (text) {
      if (text.isEmpty) {
        _configBean = null;
        widget.onShortcutAction?.call(null);
      }
    },
    onKeyEvent: (node, event) {
      if (event.isKeyDown || _configBean?.hasTriggerKey != true) {
        if (event.isBackKey) {
          _labelConfig.updateText("");
        } else {
          final bean = ShortcutConfigBean.fromKeyEvent(event);
          _configBean = bean;
          _labelConfig.updateText("$bean");
          widget.onShortcutAction?.call(bean);
        }
      }
      return .handled;
    },
  );

  @override
  Widget build(BuildContext context) {
    return SingleInputWidget(config: _labelConfig, alwaysShowSuffixIcon: true);
  }
}
