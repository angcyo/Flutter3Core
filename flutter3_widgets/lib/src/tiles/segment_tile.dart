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

  /// 选中的索引回调, 并不需要再此会调用更新界面
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

  /// 圆角大小
  final double radius;

  /// 区段边框的颜色, 同时也是是否绘制边框的使能条件
  final Color? borderColor;

  /// 选中后的边框颜色,
  /// 当设置了[borderColor]后, 此值不指定也会有默认值
  @defInjectMark
  final Color? selectedBorderColor;

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
    this.radius = 2.0,
    this.borderColor,
    this.selectedBorderColor,
    //--
    this.enable = true,
    this.isMultiSelect = false,
    this.isEmptySelect = false,
  });

  @override
  State<SegmentTile> createState() => _SegmentTileState();
}

class _SegmentTileState extends State<SegmentTile> {
  double get _radius => widget.radius;

  int get segmentCount => widget.segments?.length ?? widget.segmentCount;

  //--

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

    final children = <Widget>[];
    for (var i = 0; i < segmentCount; i++) {
      final isSelected = _isSelectedIndex(i);
      Widget child = _buildSegment(context, i).textStyle(
        isSelected
            ? widget.selectedTextStyle
            : widget.selectedTextStyle?.copyWith(fontWeight: FontWeight.normal),
        animate: true,
      );
      if (widget.enable) {
        child = child.ink(
          () {
            if (_canTapIndex(i)) {
              _onTapSegment(i);
            }
          },
          borderRadius: _buildBorderRadius(i),
          /*highlightColor: Colors.redAccent,*/
          splashColor: Colors.transparent,
        ).material(borderRadius: _buildBorderRadius(i));
      }
      child = child.stateDecoration(
        isSelected
            ? widget.selectedDecoration ??
                (widget.borderColor == null
                    ? fillDecoration(
                        context: context,
                        color: globalTheme.accentColor,
                        borderRadius: _buildBorderRadius(i),
                      )
                    : null)
            : null,
      );
      children.add(child);
    }
    final result = children
            .flowLayout(
              /*debugLabel: "segment",*/
              matchLineHeight: true,
              mainAxisAlignment: MainAxisAlignment.start,
              lineMainAxisAlignment: MainAxisAlignment.start,
              equalWidthRange: widget.equalWidthRange,
              padding: widget.tilePadding,
              /*childGap: 1,*/
              onAfterPaint: widget.borderColor != null
                  ? (render, canvas, size, offset) {
                      //先绘制未选中的样式
                      render.visitChildrenBoxIndex((child, index) {
                        final isSelected = _isSelectedIndex(index);
                        if (!isSelected) {
                          final childOffset = offset + child.offset;
                          canvas.drawRRect(
                            _buildBorderRadius(index)
                                .toRRect((childOffset & child.size)),
                            Paint()
                              ..color = widget.borderColor!
                              ..style = PaintingStyle.stroke,
                          );
                        }
                      });
                      //再绘制选中的样式, 防止样式覆盖
                      render.visitChildrenBoxIndex((child, index) {
                        final isSelected = _isSelectedIndex(index);
                        if (isSelected) {
                          final childOffset = offset + child.offset;
                          canvas.drawRRect(
                            _buildBorderRadius(index)
                                .toRRect((childOffset & child.size)),
                            Paint()
                              ..color = widget.selectedBorderColor ??
                                  globalTheme.accentColor
                              ..style = PaintingStyle.stroke,
                          );
                        }
                      });
                    }
                  : null,
            )
            ?.stateDecoration(widget.tileDecoration ??
                (widget.borderColor == null
                    ? fillDecoration(
                        context: context,
                        color: globalTheme.itemWhiteBgColor,
                        radius: _radius,
                      )
                    : null)) ??
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

  /// 获取指定索引的圆角信息
  BorderRadius _buildBorderRadius(int index) {
    final isFirst = index == 0;
    final isLast = index == segmentCount - 1;
    if (isFirst && isLast) {
      return BorderRadius.circular(_radius);
    }
    if (isFirst) {
      return BorderRadius.only(
        topLeft: Radius.circular(_radius),
        topRight: Radius.zero,
        bottomLeft: Radius.circular(_radius),
        bottomRight: Radius.zero,
      );
    }
    if (isLast) {
      return BorderRadius.only(
        topLeft: Radius.zero,
        topRight: Radius.circular(_radius),
        bottomLeft: Radius.zero,
        bottomRight: Radius.circular(_radius),
      );
    }
    return BorderRadius.zero;
  }

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
