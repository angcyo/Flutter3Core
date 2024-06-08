part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///
/// 开关tile
/// [CheckboxTile]
/// [SwitchTile]
class SwitchTile extends StatefulWidget {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// 标签右边的小部件
  final WidgetNullList? labelActions;

  /// 描述
  final String? des;
  final EdgeInsets? desPadding;
  final Widget? desWidget;

  /// 开关
  final bool value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<bool>? onChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  final FutureValueCallback<bool>? onConfirmChange;

  ///
  final EdgeInsets? tilePadding;

  const SwitchTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.labelActions,
    this.des,
    this.desWidget,
    this.desPadding = kDesPadding,
    this.value = false,
    this.onChanged,
    this.onConfirmChange,
    this.tilePadding = kTilePadding,
  });

  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> with TileMixin {
  bool _initValue = false;

  @override
  void initState() {
    super.initState();
    _initValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SwitchTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
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
    return [
      [
        label,
        buildDesWidget(
          context,
          desWidget: widget.desWidget,
          des: widget.des,
          desPadding: widget.desPadding,
        )
      ].column(crossAxisAlignment: CrossAxisAlignment.start)?.expanded(),
      buildSwitchWidget(
        context,
        _initValue,
        onChanged: (value) {
          _changeValue(value);
        },
      ),
    ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding)
        .click(() {
      //debugger();
      _changeValue(!_initValue);
    });
  }

  void _changeValue(bool toValue) async {
    if (widget.onConfirmChange != null) {
      final result = await widget.onConfirmChange!(toValue);
      if (result != true) {
        return;
      }
    }
    _initValue = toValue;
    widget.onChanged?.call(toValue);
    updateState();
  }
}
