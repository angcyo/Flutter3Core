import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/23
///
/// 支持选中提示的小部件
class SelectChip extends StatefulWidget {
  /// 子小部件
  final Widget child;

  /// 选中时的提示小部件
  final Widget? selected;

  /// 是否选中
  final bool isSelected;

  /// 选中的回调
  final ValueChanged<bool>? onSelected;

  /// 选中后是否可以点击
  final bool enableSelectedTap;

  const SelectChip({
    super.key,
    required this.child,
    this.selected,
    this.isSelected = false,
    this.onSelected,
    this.enableSelectedTap = false,
  });

  @override
  State<SelectChip> createState() => _SelectChipState();
}

class _SelectChipState extends State<SelectChip> {
  @override
  Widget build(BuildContext context) {
    return [
      widget.child,
      if (widget.isSelected) ?widget.selected,
    ].stack()!.inkWellCircle(
      () {
        widget.onSelected?.call(!widget.isSelected);
      },
      enable: widget.isSelected && widget.enableSelectedTap
          ? true
          : !widget.isSelected,
    );
  }
}
