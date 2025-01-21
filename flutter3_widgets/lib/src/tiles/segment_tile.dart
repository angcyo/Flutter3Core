part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/21
///

typedef SegmentWidgetBuilder = Widget Function(
    BuildContext context,
    int index,
    bool isSelected,
    );

///
/// 系统[SegmentedButton]
///
class SegmentTile extends StatefulWidget {
  /// 区段按钮
  final List<Widget>? segments;

  /// 或者指定数量
  final int segmentCount;

  /// 构建器
  final SegmentWidgetBuilder? segmentBuilder;

  //--

  /// 选中的索引列表
  final Iterable<int>? selectedIndexList;

  /// 选中回调, 并不需要再此会调用更新界面
  final void Function(List<int> list)? onSelectedAction;

  //--

  /// tile 整体的背景
  @defInjectMark
  final Decoration? tileDecoration;

  /// tile 整体的内边距
  final EdgeInsets? tilePadding;

  /// 子元素等宽个数范围
  final String? equalWidthRange;

  /// 选中后的背景装饰
  @defInjectMark
  final Decoration? selectedDecoration;

  /// 选中后的文本样式
  final TextStyle? selectedTextStyle;

  //--

  /// 是否激活组件
  final bool enable;

  /// 是否激活多选
  final bool isMultiSelect;

  /// 是否允许空选
  final bool isEmptySelect;

  const SegmentTile({
    super.key,
    this.segments,
    this.segmentCount = 0,
    this.segmentBuilder,
    //--
    this.selectedIndexList,
    this.onSelectedAction,
    //--
    this.tileDecoration,
    this.tilePadding,
    this.equalWidthRange,
    this.selectedDecoration,
    this.selectedTextStyle,
    //--
    this.enable = true,
    this.isMultiSelect = false,
    this.isEmptySelect = false,
  });

  @override
  State<SegmentTile> createState() => _SegmentTileState();
}

class _SegmentTileState extends State<SegmentTile> {
  final _radius = 2.0;

  /// 选中的列表
  final List<int> _selectedIndexList = [];

  @override
  void initState() {
    _selectedIndexList.reset([...?widget.selectedIndexList]);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SegmentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedIndexList.reset([...?widget.selectedIndexList]);
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final count = widget.segments?.length ?? widget.segmentCount;
    final children = <Widget>[];
    for (var i = 0; i < count; i++) {
      final isSelected = _isSelectedIndex(i);
      Widget child = _buildSegment(context, i).textStyle(
        isSelected ? widget.selectedTextStyle : null,
        animate: true,
      );
      if (widget.enable && _canTapIndex(i)) {
        child = child.ink(() {
          _onTapSegment(i);
        }, radius: _radius).material(radius: _radius);
      }
      child = child.stateDecoration(
        isSelected
            ? widget.selectedDecoration ??
            fillDecoration(
              context: context,
              color: globalTheme.accentColor,
              radius: _radius,
            )
            : null,
      );
      children.add(child);
    }
    final result = children
        .flowLayout(
      equalWidthRange: widget.equalWidthRange,
      padding: widget.tilePadding,
    )
        ?.stateDecoration(widget.tileDecoration ??
        fillDecoration(
          context: context,
          color: globalTheme.itemWhiteBgColor,
          radius: _radius,
        )) ??
        empty;
    return result.disable(!widget.enable);
  }

  /// 是否可以tap索引
  bool _canTapIndex(int index) {
    if (_isSelectedIndex(index)) {
      //已经是选择状态, 那意图就是取消选择
      if (widget.isMultiSelect) {
        //多选下允许取消选择
        return true;
      }
      return widget.isEmptySelect;
    }
    return true;
  }

  /// 是否选中索引
  bool _isSelectedIndex(int index) => _selectedIndexList.contains(index);

  /// 构建一个区段
  Widget _buildSegment(BuildContext context, int index) {
    return widget.segments?.getOrNull(index) ??
        widget.segmentBuilder?.call(context, index, _isSelectedIndex(index)) ??
        empty;
  }

  /// 点击区段回调
  void _onTapSegment(int index) {
    if (_isSelectedIndex(index)) {
      //取消选择
      _selectedIndexList.remove(index);
    } else {
      //添加选择
      if (!widget.isMultiSelect) {
        //单选下, 清空选择
        _selectedIndexList.clear();
      }
      _selectedIndexList.add(index);
    }
    widget.onSelectedAction?.call(_selectedIndexList);
    updateState();
    /*l.d("点击区段:$index $_selectedIndexList");*/
  }
}
