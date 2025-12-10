part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
/// [iconDecoration.[icon]]
/// [label]
///
/// 上图标[icon], 下文字[label]的tile
class SingleGridTile extends StatelessWidget with TileMixin {
  /// 图标
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Widget? iconWidget;

  /// 图标右上角的提示小部件
  final Widget? iconTipWidget;

  /// 图标的装饰
  final Decoration? iconDecoration;

  /// 装饰的宽高大小
  final double? iconDecorationSize;

  /// 是否使用填充装饰[iconDecoration]的间接属性
  @indirectProperty
  final bool? iconFillDecoration;
  @indirectProperty
  final Color? iconFillDecorationColor;
  @indirectProperty
  final Color? iconDisableFillDecorationColor;

  //--

  /// 标签
  final String? label;
  final int? labelMaxLength;
  final TextStyle? labelStyle;
  final Widget? labelWidget;
  final TextOverflow labelOverflow;

  //--

  /// 整体的内边距
  @defInjectMark
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 最小高度
  final double? minHeight;

  /// 点击事件, 同时决定是否要显示默认的箭头
  final GestureTapCallback? onTap;

  /// 是否激活状态
  final bool enable;

  //--

  /// 显示在背景的小部件
  final Widget? bgWidget;

  const SingleGridTile({
    super.key,
    //--
    this.icon,
    this.iconSize,
    this.iconColor,
    this.iconWidget,
    this.iconDecoration,
    this.iconDecorationSize = 48,
    this.iconFillDecorationColor,
    this.iconDisableFillDecorationColor,
    this.iconFillDecoration,
    this.iconTipWidget,
    //--
    this.minHeight,
    this.label,
    this.labelStyle,
    this.labelMaxLength,
    this.labelWidget,
    this.labelOverflow = TextOverflow.fade,
    this.padding,
    this.margin,
    this.onTap,
    this.enable = true,
    //--
    this.bgWidget,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    Widget? top = buildIconWidget(
      context,
      iconWidget: iconWidget,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
    )?.colorFiltered(color: enable ? null : globalTheme.icoDisableColor);

    Decoration? decoration = iconDecoration;
    if (iconFillDecoration == true) {
      decoration ??= fillDecoration(
        color: enable
            ? iconFillDecorationColor ?? globalTheme.iconWhiteBgColor
            : (iconDisableFillDecorationColor ??
                  iconFillDecorationColor ??
                  globalTheme.iconWhiteBgColor),
        radius: kDefaultBorderRadiusX,
      );
    }

    if (decoration != null) {
      top = top
          ?.center()
          .size(size: iconDecorationSize)
          .backgroundDecoration(decoration);
    }
    if (iconTipWidget != null) {
      top = top?.stackOf(
        iconTipWidget!.position(right: -10, top: -10),
        clipBehavior: Clip.none,
      );
    }

    //--
    final bottom =
        (labelWidget ??
                label
                    ?.ellipsis(labelMaxLength)
                    .text(
                      style: labelStyle ?? globalTheme.textBodyStyle,
                      textAlign: ui.TextAlign.center,
                      softWrap: false,
                      overflow: labelOverflow,
                    )
                    .paddingAll(kM))
            ?.colorFiltered(color: enable ? null : globalTheme.icoDisableColor);

    //--
    Widget body = [
      if (top != null) top,
      if (bottom != null) bottom,
    ].column(mainAxisAlignment: MainAxisAlignment.center)!;

    if (bgWidget != null) {
      body = [
        bgWidget,
        body,
      ].stack(alignment: Alignment.center, fit: StackFit.expand)!;
    }

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
      child: body.constrainedMin(minHeight: minHeight),
    ).inkWellCircle(onTap, enable: enable).material().paddingInsets(margin);
  }
}

/// 桌面样式的网格图标tile
/// - 支持右下角显示more图标
/// - 支持配置选中后的菜单弹窗
///
/// - [DesktopTextMenuTile]
/// - [SingleDesktopGridTile]
@desktopLayout
class SingleDesktopGridTile extends StatefulWidget {
  /// 图标
  final Widget? iconWidget;

  /// 右下角显示的更多图标
  @defInjectMark
  final Widget? moreWidget;

  /// 是否处于选中状态, 会有背景装饰
  final bool isSelected;

  /// tile的填充
  @defInjectMark
  final EdgeInsets? tilePadding;

  //--

  /// 弹窗背景的圆角
  final double? radius;

  /// 自定义点击事件
  /// - 会拦截默认的弹出[popupBodyWidget]处理
  final GestureTapCallback? onTap;

  /// 弹窗内容小部件
  /// - 设置之后才会显示[moreWidget]
  /// - 弹出弹窗之后, 会自动进入选中状态
  final Widget? popupBodyWidget;

  /// 当锚点销毁时, 是否自动移除弹窗
  /// - 使用此功能需要指定[key]
  final bool autoRemovePopup;

  //--

  /// 长按提示文本
  final String? tooltip;

  const SingleDesktopGridTile({
    super.key,
    this.iconWidget,
    this.moreWidget,
    this.tilePadding,
    this.radius = 4,
    this.isSelected = false,
    this.popupBodyWidget,
    this.autoRemovePopup = true,
    this.onTap,
    //--
    this.tooltip,
  });

  @override
  State<SingleDesktopGridTile> createState() => _SingleDesktopGridTileState();
}

class _SingleDesktopGridTileState extends State<SingleDesktopGridTile>
    with DesktopPopupStateMixin {
  @override
  void initState() {
    autoRemovePopupMixin = widget.autoRemovePopup;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SingleDesktopGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    autoRemovePopupMixin = widget.autoRemovePopup;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final isEnableTap = widget.popupBodyWidget != null || widget.onTap != null;
    final isShowMore = widget.popupBodyWidget != null;
    final isSelected = widget.isSelected || isShowPopupMixin;
    //debugger();
    final radius = kDefaultBorderRadiusX;
    return [
          widget.iconWidget?.paddingOnly(all: 4),
          if (isShowMore)
            (widget.moreWidget ?? Icon(Icons.more_horiz, size: 8)).position(
              right: 0,
              bottom: 0,
            ),
        ]
        .stack()!
        .paddingOnly(horizontal: kM, vertical: kM, insets: widget.tilePadding)
        .backgroundColor(
          isSelected ? globalTheme.hoverColor : null,
          fillRadius: radius,
        )
        .inkWell(
          widget.onTap ??
              () {
                wrapShowPopupMixin(() async {
                  await buildContext?.showPopupDialog(widget.popupBodyWidget!);
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
