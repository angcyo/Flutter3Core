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

  /// 菜单的值的小部件构造器
  @defInjectMark
  final WidgetValueBuilder? valueWidgetBuilder;

  /// 选中后, 显示的图标
  @defInjectMark
  final Widget? checkedWidget;

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
    this.valueWidgetBuilder,
    this.checkedWidget,
    //--
    this.tilePadding = kTilePadding,
    this.menuPadding = kItemPadding,
  });

  @override
  State<LabelMenuTile> createState() => _LabelMenuTileState();
}

class _LabelMenuTileState extends State<LabelMenuTile> {
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
    Widget? value =
        widget.valueWidget ?? _buildValueWidget(context, widget.value);
    //debugger();
    if (value != null) {
      value = [
        empty.expanded(),
        value.backgroundColor(Colors.red),
      ]
          .row(crossAxisAlignment: CrossAxisAlignment.center)
          ?.ink(() {}, enable: !isNil(widget.valueList))
          /*.material()*/
          .hoverLayout(
            overlayBuilder: (ctx) => [
              for (final v in widget.valueList ?? [])
                _buildValueWidget(ctx, v, showIcon: true)
                    ?.paddingInsets(widget.menuPadding)
                    .constrained(minWidth: 140)
                    .ink(() {})
                    .material()
            ].scrollVertical()?.constrained(maxHeight: 300),
            enable: !isNil(widget.valueList),
            showArrow: false,
          );
    }

    return [
      label?.backgroundColor(Colors.yellow),
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
    final isChecked = widget.value == value;
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
