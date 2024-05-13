part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///
/// 开关tile
class SwitchTile extends StatelessWidget with TileMixin {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// 开关
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.value = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return [
      buildTextWidget(
        context,
        textWidget: labelWidget,
        text: label ?? "",
        textPadding: labelPadding,
      )?.expanded(),
      buildSwitchWidget(
        context,
        value,
        onChanged: (value) {
          onChanged?.call(value);
        },
      ),
    ].row()!;
  }
}
