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
      label = [label, ...?widget.labelActions].row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    }

    //
    Widget? value = widget.valueWidget ?? _buildValueWidget(context, initValue);
    //debugger();
    if (value != null) {
      value =
          [
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
                        })
                        .material();
                  }),
                ].scrollVertical()?.constrained(maxHeight: 300),
                enable: !isNil(widget.valueList),
                showArrow: false,
                onShowAction: (show) {
                  _isShowOverlay = show;
                  updateState();
                },
              );
    }

    return [label, value?.expanded()]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding);
  }

  /// 构建值小部件
  Widget? _buildValueWidget(
    BuildContext context,
    dynamic value, {
    bool showIcon = false,
  }) {
    if (value == null) {
      return null;
    }
    final valueWidget =
        widget.valueWidgetBuilder?.call(context, value) ??
        widgetOf(context, value, tryTextWidget: true);
    if (valueWidget == null) {
      return null;
    }
    if (!showIcon) {
      return valueWidget;
    }
    final globalTheme = GlobalTheme.of(context);
    final isChecked = initValue == value;
    final checkedWidget =
        widget.checkedWidget ??
        Icon(Icons.check, size: 16, color: globalTheme.accentColor);
    return [
      valueWidget.expanded(),
      isChecked ? checkedWidget : empty,
    ].row()?.iw();
  }
}

//--

/// 桌面端文本菜单tile
/// 左[leadingWidget]...[text]...右[trailingWidget]
/// - 支持选中/悬停高亮
///
/// - [DesktopTextMenuTile]
/// - [DesktopIconMenuTile]
/// - [SingleDesktopGridTile]
@desktopLayout
class DesktopTextMenuTile extends StatefulWidget {
  //--leading

  ///领头的小部件. (不指定也占空间)
  final Widget? leadingWidget;

  //--trailing

  /// 尾随的小部件. (不指定也占空间)
  /// 当指定了[popupBodyWidget], 会有默认值的向右箭头
  @defInjectMark
  final Widget? trailingWidget;

  /// 不指定[leadingWidget].[trailingWidget]时的占位大小
  final Size placeholderSize;

  //--text

  /// 中间的文本内容
  final String? text;

  //--

  /// 是否处于选中状态, 会有背景装饰
  final bool isSelected;

  /// 是否处于勾选状态, 会有前置勾选icon
  final bool? isChecked;

  /// 弹窗内容小部件
  /// - 设置之后才会显示[trailingWidget]
  /// - 弹出弹窗之后, 会自动进入选中状态
  final Widget? popupBodyWidget;

  /// 当显示的[popupBodyWidget]被关闭时, 是否自动关闭当前的[PopupRoute]
  final bool? autoClosePopup;

  /// 自定义点击事件
  /// - 会拦截默认的弹出[popupBodyWidget]处理
  final GestureTapCallback? onTap;

  /// 菜单最小宽度
  final double tileMinWidth;

  //--

  /// 菜单的填充
  @defInjectMark
  final EdgeInsets? tilePadding;

  const DesktopTextMenuTile({
    super.key,
    this.text,
    this.leadingWidget,
    this.placeholderSize = const Size(24, 24),
    this.trailingWidget,
    //--
    this.isSelected = false,
    this.isChecked,
    this.tileMinWidth = 100,
    this.popupBodyWidget,
    this.autoClosePopup,
    this.onTap,
    //--
    this.tilePadding,
  });

  @override
  State<DesktopTextMenuTile> createState() => _DesktopTextMenuTileState();
}

class _DesktopTextMenuTileState extends State<DesktopTextMenuTile>
    with DesktopPopupStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final radius = kDefaultBorderRadiusH;

    final isSelected = widget.isSelected || isShowPopupMixin;
    final isEnableTap = widget.popupBodyWidget != null || widget.onTap != null;

    Widget? trailingWidget = widget.trailingWidget;
    if (trailingWidget == null && widget.popupBodyWidget != null) {
      trailingWidget = Icon(
        Icons.navigate_next,
        size: 16,
        color: globalTheme.icoDisableColor,
      ).paddingOnly(horizontal: kL);
    }
    return [
          if (widget.isChecked != null)
            Icon(
              Icons.check_sharp,
              color: globalTheme.successColor,
            ).invisible(enable: !(widget.isChecked == true)).insets(h: kL),
          //-- leading
          widget.leadingWidget ??
              SizedBox.fromSize(size: widget.placeholderSize),
          (widget.text ?? "").text(style: globalTheme.textBodyStyle).expanded(),
          //-- trailing
          trailingWidget ?? SizedBox.fromSize(size: widget.placeholderSize),
        ]
        .row()!
        .insets(vertical: kL)
        .colorFiltered(
          color: isEnableTap ? null : globalTheme.textDisableStyle.color,
        )
        .constrainedMin(minWidth: widget.tileMinWidth)
        .backgroundColor(
          isSelected ? globalTheme.hoverColor : null,
          fillRadius: radius,
        )
        .inkWell(
          widget.onTap ??
              (widget.popupBodyWidget == null
                  ? null
                  : () {
                      wrapShowPopupMixin(() async {
                        await buildContext?.showPopupDialog(
                          widget.popupBodyWidget!,
                        );
                      }).get((data, error) {
                        if (widget.autoClosePopup == true) {
                          buildContext?.popMenu();
                        }
                      });
                    }),
          borderRadius: BorderRadius.circular(radius),
          enable: isEnableTap,
        )
        .material()
        .paddingOnly(horizontal: kM, vertical: kM, insets: widget.tilePadding)
        .localLocation(
          key: widget.key,
          locationNotifier: locationNotifierMixin,
        );
  }
}

//--

/// 桌面端图标菜单tile
/// 左[leadingWidget]...[icon]...右[trailingWidget]
/// - 支持选中/悬停高亮
///
/// - [DesktopTextMenuTile]
/// - [DesktopIconMenuTile]
/// - [SingleDesktopGridTile]
class DesktopIconMenuTile extends StatefulWidget {
  //--leading

  ///领头的小部件
  final Widget? leadingWidget;

  //--trailing

  /// 尾随的小部件
  /// 当指定了[popupBodyWidget], 会有默认值的向下箭头
  @defInjectMark
  final Widget? trailingWidget;

  //--text

  /// 中间的图标
  final Widget? iconWidget;

  //--

  /// 是否处于选中状态, 会有背景装饰
  final bool isSelected;

  /// 弹窗内容小部件
  /// - 设置之后才会显示[trailingWidget]
  /// - 弹出弹窗之后, 会自动进入选中状态
  final Widget? popupBodyWidget;

  /// 自定义点击事件
  /// - 会拦截默认的弹出[popupBodyWidget]处理
  final GestureTapCallback? onTap;

  /// 弹窗对齐锚点的方式
  final Alignment? popupAlignment;

  //--

  /// 长按提示文本
  final String? tooltip;

  const DesktopIconMenuTile({
    super.key,
    this.iconWidget,
    this.leadingWidget,
    this.trailingWidget,
    //--
    this.isSelected = false,
    this.popupBodyWidget,
    this.onTap,
    this.popupAlignment,
    //--
    this.tooltip,
  });

  @override
  State<DesktopIconMenuTile> createState() => _DesktopIconMenuTileState();
}

class _DesktopIconMenuTileState extends State<DesktopIconMenuTile>
    with DesktopPopupStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final radius = kDefaultBorderRadiusH;

    final isSelected = widget.isSelected || isShowPopupMixin;
    final isEnableTap = widget.popupBodyWidget != null || widget.onTap != null;

    Widget? trailingWidget = widget.trailingWidget;
    if (trailingWidget == null && widget.popupBodyWidget != null) {
      trailingWidget = Icon(
        Icons.navigate_next,
        size: 16,
        color: globalTheme.icoDisableColor,
      ).rotate(90.hd);
    }
    return [
          //-- leading
          widget.leadingWidget,
          widget.iconWidget?.paddingOnly(
            left: kM,
            vertical: kM,
            right: trailingWidget == null ? kM : null,
          ),
          //-- trailing
          trailingWidget,
        ]
        .row()!
        .colorFiltered(
          color: isEnableTap ? null : globalTheme.textDisableStyle.color,
        )
        .backgroundColor(
          isSelected ? globalTheme.hoverColor : null,
          fillRadius: radius,
        )
        .inkWell(
          widget.onTap ??
              () {
                wrapShowPopupMixin(() async {
                  await buildContext?.showPopupDialog(
                    widget.popupBodyWidget!,
                    alignment: widget.popupAlignment,
                  );
                });
              },
          borderRadius: BorderRadius.circular(radius),
          enable: isEnableTap,
        )
        .tooltip(widget.tooltip)
        .material()
        .localLocation(
          key: widget.key,
          locationNotifier: locationNotifierMixin,
        );
  }
}
