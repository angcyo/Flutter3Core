part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/21
///

typedef SegmentWidgetBuilder =
    Widget Function(BuildContext context, int index, bool isSelected);

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
        child = child
            .ink(
              () {
                if (_canTapIndex(i)) {
                  _onTapSegment(i);
                }
              },
              borderRadius: _buildBorderRadius(i),
              /*highlightColor: Colors.redAccent,*/
              splashColor: Colors.transparent,
            )
            .material(borderRadius: _buildBorderRadius(i));
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
    final result =
        children
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
                            _buildBorderRadius(
                              index,
                            ).toRRect((childOffset & child.size)),
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
                            _buildBorderRadius(
                              index,
                            ).toRRect((childOffset & child.size)),
                            Paint()
                              ..color =
                                  widget.selectedBorderColor ??
                                  globalTheme.accentColor
                              ..style = PaintingStyle.stroke,
                          );
                        }
                      });
                    }
                  : null,
            )
            ?.stateDecoration(
              widget.tileDecoration ??
                  (widget.borderColor == null
                      ? fillDecoration(
                          context: context,
                          color: globalTheme.itemWhiteBgColor,
                          radius: _radius,
                        )
                      : null),
            ) ??
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

//--

/// - [SegmentTile]
/// - [ValueSegmentTile]
class ValueSegmentTile extends StatefulWidget {
  /// 值列表
  /// - [widgetOf]
  final List? values;

  /// 选中的值列表
  final List? selectedValues;

  /// 值列表对应的Widget
  final List<Widget>? valuesWidget;

  //--

  /// 是否激活交互
  final bool enable;

  /// 最多选中数量
  final int maxSelectedCount;

  /// 是否允许空选择
  final bool enableSelectedEmpty;

  /// 选中样式: 背景颜色
  final Color? selectedBgColor;

  /// 选中样式: 圆角大小
  final double? selectedBorderRadius;

  /// 正常情况下的文本样式
  final TextStyle? textStyle;

  /// 选中样式: 文本样式
  final TextStyle? textSelectedStyle;

  //--

  /// 点击事件回调
  final ValueCallback? onTapValue;

  /// 边距
  final EdgeInsetsGeometry? tileInsets;

  /// 选中的值列表改变回调
  final ValueCallback<List>? onValuesSelected;

  const ValueSegmentTile({
    super.key,
    //--
    this.values,
    this.selectedValues,
    this.valuesWidget,
    //--
    this.enable = true,
    this.maxSelectedCount = 1,
    this.enableSelectedEmpty = false,
    this.selectedBgColor,
    this.textStyle,
    this.textSelectedStyle,
    this.selectedBorderRadius = kDefaultBorderRadiusXX,
    //--
    this.tileInsets,
    this.onTapValue,
    this.onValuesSelected,
  });

  @override
  State<ValueSegmentTile> createState() => _ValueSegmentTileState();
}

class _ValueSegmentTileState extends State<ValueSegmentTile> {
  late List _selectedValues;

  /// 是否是多选模式
  bool get _isMultiSelect => widget.maxSelectedCount > 1;

  @override
  void initState() {
    _selectedValues = [...?widget.selectedValues];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final borderRadius = widget.selectedBorderRadius ?? kDefaultBorderRadiusX;
    final segmentList =
        widget.valuesWidget ??
        widget.values?.mapIndexed((index, value) {
          return widgetOf(
                context,
                value,
                tryTextWidget: true,
                textAlign: TextAlign.center,
                textStyle: _isSelectedValue(value)
                    ? widget.textSelectedStyle
                    : widget.textStyle,
              )
              ?.paddingOnly(all: kL)
              .backgroundDecoration(
                !widget.enable
                    ? fillDecoration(
                        color: globalTheme.disableColor,
                        radius: borderRadius,
                      )
                    : _isSelectedValue(value)
                    ? fillDecoration(
                        color:
                            widget.selectedBgColor ?? globalTheme.accentColor,
                        radius: borderRadius,
                      )
                    : null,
              )
              .click(
                () {
                  //debugger();
                  widget.onTapValue?.call(value);
                  if (_isSelectedValue(value)) {
                    if (_canCancelSelectedValue(value)) {
                      _selectedValues.remove(value);
                      widget.onValuesSelected?.call(_selectedValues);
                      updateState();
                    }
                  } else {
                    if (_canSelectedValue(value)) {
                      if (!_isMultiSelect) {
                        _selectedValues.clear();
                      }
                      _selectedValues.add(value);
                      widget.onValuesSelected?.call(_selectedValues);
                      updateState();
                    }
                  }
                },
                enable: widget.enable /*&&
                    !disableTap &&
                    (selectedDisableTap ? !isSelected : true)*/,
              );
        }).toList();
    return segmentList
            ?.flowLayout(
              equalWidthRange: "",
              padding: const EdgeInsets.all(kL),
              selfConstraints: const LayoutBoxConstraints(
                widthType: ConstraintsType.matchParent,
                minHeight: kMinInteractiveHeight,
              ),
            )
            ?.backgroundDecoration(
              fillDecoration(
                color: globalTheme.whiteSubBgColor,
                radius: borderRadius,
              ),
            )
            .paddingOnly(
              horizontal: kX,
              vertical: kL,
              insets: widget.tileInsets,
            ) ??
        empty;
  }

  /// 指定的值[value]是否选中了
  bool _isSelectedValue(dynamic value) {
    return _selectedValues.contains(value) ?? false;
  }

  /// 是否可以选中指定的值[value]
  bool _canSelectedValue(dynamic value) {
    if (_isSelectedValue(value)) {
      return false;
    }
    if (!_isMultiSelect) {
      return true;
    }
    final selectedCount = _selectedValues.size();
    if (selectedCount >= widget.maxSelectedCount) {
      return false;
    }
    return true;
  }

  /// 是否可以取消指定的值[value]
  bool _canCancelSelectedValue(dynamic value) {
    if (_isMultiSelect) {
      return widget.enableSelectedEmpty || _selectedValues.contains(value);
    }
    return widget.enableSelectedEmpty;
  }
}
