part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025-01-22
///
/// 菜单相关tile

/// 左[label]...右[value]
///
/// 使用[HoverAnchorLayout]实现的点击浮窗弹窗tile
///
class LabelMenuTile extends StatefulWidget with LabelMixin {
  //--label

  /// 标签/LabelMixin
  @override
  final String? label;
  @override
  final Widget? labelWidget;
  @override
  final TextStyle? labelTextStyle;
  @override
  final EdgeInsets? labelPadding;
  @override
  final BoxConstraints? labelConstraints;

  /// 标签右边的小部件
  final WidgetNullList? labelActions;

  //--value

  /// 要显示的值
  final dynamic value;

  /// 要显示的值列表
  final List<dynamic>? valueList;

  /// 菜单的值
  final Widget? valueWidget;

  /// 菜单的提示箭头, 会有旋转提示
  final Widget? arrowWidget;

  /// 菜单的值的小部件构造器
  @defInjectMark
  final WidgetValueBuilder? valueWidgetBuilder;

  /// 选中后, 显示的图标
  @defInjectMark
  final Widget? checkedWidget;

  /// 选中回调, 并不需要再此会调用更新界面
  /// - 索引
  /// - value
  final DoubleValueChanged<int, dynamic>? onSelectedAction;

  //--tile

  /// menu的填充
  final EdgeInsetsGeometry? menuPadding;

  /// tile的填充
  final EdgeInsets? tilePadding;

  const LabelMenuTile({
    super.key,
    //--label
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints,
    this.labelActions,
    //--value
    this.value,
    this.valueList,
    this.valueWidget,
    this.arrowWidget,
    this.valueWidgetBuilder,
    this.checkedWidget,
    this.onSelectedAction,
    //--
    this.tilePadding = kTilePadding,
    this.menuPadding = kItemPadding,
  });

  @override
  State<LabelMenuTile> createState() => _LabelMenuTileState();
}

class _LabelMenuTileState extends State<LabelMenuTile> {
  /// 初始化值
  dynamic initValue;

  ///
  bool _isShowOverlay = false;

  @override
  void initState() {
    initValue = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelMenuTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    initValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    //build label
    Widget? label = widget.buildLabelWidgetMixin(context);
    if (label != null && !isNil(widget.labelActions)) {
      label = [
        label,
        ...?widget.labelActions,
      ].row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center);
    }

    //
    Widget? value = widget.valueWidget ?? _buildValueWidget(context, initValue);
    //debugger();
    if (value != null) {
      value = [
        empty.expanded(),
        value,
        widget.arrowWidget?.rotate(_isShowOverlay ? -180.hd : 0),
      ]
          .row(crossAxisAlignment: CrossAxisAlignment.center)
          ?.ink(() {}, enable: !isNil(widget.valueList))
          /*.material()*/
          .hoverLayout(
              overlayBuilder: (ctx) => [
                    ...?widget.valueList?.mapIndexed((index, v) {
                      return _buildValueWidget(ctx, v, showIcon: true)
                          ?.paddingInsets(widget.menuPadding)
                          .constrained(minWidth: 140)
                          .ink(() {
                        if (initValue != v) {
                          initValue = v;
                          widget.onSelectedAction?.call(index, v);
                          updateState();
                        }
                      }).material();
                    }),
                  ].scrollVertical()?.constrained(maxHeight: 300),
              enable: !isNil(widget.valueList),
              showArrow: false,
              onShowAction: (show) {
                _isShowOverlay = show;
                updateState();
              });
    }

    return [
      label,
      value?.expanded(),
    ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding);
  }

  /// 构建值小部件
  Widget? _buildValueWidget(BuildContext context, dynamic value,
      {bool showIcon = false}) {
    if (value == null) {
      return null;
    }
    final valueWidget = widget.valueWidgetBuilder?.call(context, value) ??
        widgetOf(context, value, tryTextWidget: true);
    if (valueWidget == null) {
      return null;
    }
    if (!showIcon) {
      return valueWidget;
    }
    final globalTheme = GlobalTheme.of(context);
    final isChecked = initValue == value;
    final checkedWidget = widget.checkedWidget ??
        Icon(
          Icons.check,
          size: 16,
          color: globalTheme.accentColor,
        );
    return [valueWidget.expanded(), isChecked ? checkedWidget : empty]
        .row()
        ?.iw();
  }
}
