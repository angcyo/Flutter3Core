part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/10
///
/// 输入框tile
/// 上label
/// 下input hint(des)
class LabelSingleInputTile extends StatefulWidget {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// 标签右边的小部件
  final WidgetNullList? labelActions;

  /// 提示
  final String? hint;

  //--

  final String? value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<String>? onChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  final FutureValueCallback<String>? onConfirmChange;

  /// tile的填充
  final EdgeInsets? tilePadding;

  //--input

  /// 下划线的输入框样式
  final bool useUnderlineInputBorder;

  const LabelSingleInputTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.labelActions,
    this.hint,
    this.value,
    this.onChanged,
    this.onConfirmChange,
    this.useUnderlineInputBorder = true,
    this.tilePadding = kTilePadding,
  });

  @override
  State<LabelSingleInputTile> createState() => _LabelSingleInputTileState();
}

class _LabelSingleInputTileState extends State<LabelSingleInputTile>
    with TileMixin {
  String? _initialValue;

  String? _currentValue;

  late final TextFieldConfig _inputConfig = TextFieldConfig(
    text: widget.value,
    hintText: widget.hint,
    textInputAction: TextInputAction.done,
    onChanged: (value) {
      //FocusScope.of(context).requestFocus(_passwordFocusNode);
      //debugger();
      _changeValue(value);
    },
  );

  @override
  void initState() {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    _inputConfig.updateText(_currentValue);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelSingleInputTile oldWidget) {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    _inputConfig.updateText(_currentValue);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // build label
    Widget? label = buildLabelWidget(
      context,
      labelWidget: widget.labelWidget,
      label: widget.label,
      labelPadding: widget.labelPadding,
      constraints: null,
    );
    if (label != null && !isNil(widget.labelActions)) {
      label = [
        label,
        ...?widget.labelActions,
      ].row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center);
    }

    Widget input = SingleInputWidget(
      config: _inputConfig,
      useUnderlineInputBorder: widget.useUnderlineInputBorder,
    ).paddingOnly(left: widget.labelPadding?.left ?? 0);

    return [label, input]
        .column(crossAxisAlignment: CrossAxisAlignment.start)!
        .paddingInsets(widget.tilePadding);
  }

  void _changeValue(String toValue) async {
    if (widget.onConfirmChange != null) {
      final result = await widget.onConfirmChange!(toValue);
      if (result != true) {
        return;
      }
    }
    _currentValue = toValue;
    widget.onChanged?.call(toValue);
    updateState();
  }
}
