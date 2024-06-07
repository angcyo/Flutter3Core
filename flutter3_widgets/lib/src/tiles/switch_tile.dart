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

  /// 描述
  final String? des;
  final EdgeInsets? desPadding;
  final Widget? desWidget;

  /// 开关
  final bool value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<bool>? onChanged;

  ///
  final EdgeInsets? tilePadding;

  const SwitchTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.des,
    this.desWidget,
    this.desPadding = kDesPadding,
    this.value = false,
    this.onChanged,
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
    return [
      [
        buildLabelWidget(
          context,
          labelWidget: widget.labelWidget,
          label: widget.label,
          labelPadding: widget.labelPadding,
          constraints: null,
        ),
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
          _initValue = value;
          widget.onChanged?.call(value);
          updateState();
        },
      ),
    ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding)
        .click(() {
      //debugger();
      _initValue = !_initValue;
      widget.onChanged?.call(_initValue);
      updateState();
    });
  }
}
