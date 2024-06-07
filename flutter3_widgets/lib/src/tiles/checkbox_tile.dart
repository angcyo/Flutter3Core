part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/07
///
/// 复选框tile
/// [CheckboxTile]
/// [SwitchTile]
///
/// [CheckboxTheme].[CheckboxThemeData]
class CheckboxTile extends StatefulWidget {
  /// 文本描述信息
  final String? text;
  final EdgeInsets? textPadding;
  final Widget? textWidget;

  /// 是否选中
  /// 如果开启了半选状态, 值可能为null
  final bool? value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<bool?>? onChanged;

  //--

  /// 是否要支持半选
  final bool tristate;

  const CheckboxTile({
    super.key,
    this.text,
    this.textWidget,
    this.textPadding = kContentPadding,
    this.value = false,
    this.tristate = false,
    this.onChanged,
  });

  @override
  State<CheckboxTile> createState() => _CheckboxTileState();
}

class _CheckboxTileState extends State<CheckboxTile> with TileMixin {
  bool? _initValue;

  @override
  void initState() {
    super.initState();
    _initValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CheckboxTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return [
      Checkbox(
        value: _initValue,
        tristate: widget.tristate,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (value) {
          _initValue = value;
          widget.onChanged?.call(value);
          updateState();
        },
      ),
      buildTextWidget(
        context,
        textWidget: widget.textWidget,
        text: widget.text,
        textPadding: widget.textPadding,
      )?.expanded(),
    ].row(crossAxisAlignment: CrossAxisAlignment.center)!.click(() {
      _initValue = !_initValue!;
      widget.onChanged?.call(_initValue);
      updateState();
    });
  }
}
