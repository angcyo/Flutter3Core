part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///

/// 上图标, 下文字的tile
class SingleGridTile extends StatelessWidget {
  /// 图标
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Widget? iconWidget;

  /// 标签
  final String? label;
  final Widget? labelWidget;

  /// 整体的内边距
  final EdgeInsetsGeometry? padding;

  /// 最小高度
  final double? minHeight;

  /// 点击事件, 同时决定是否要显示默认的箭头
  final GestureTapCallback? onTap;

  const SingleGridTile({
    super.key,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.iconWidget,
    this.minHeight,
    this.label,
    this.labelWidget,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);

    var top = iconWidget ??
        (icon == null
            ? null
            : Icon(
                icon,
                size: iconSize,
                color: iconColor ?? globalTheme.accentColor,
              ));

    var bottom = labelWidget ??
        label
            ?.text(
                style: globalTheme.textBodyStyle,
                softWrap: false,
                overflow: TextOverflow.ellipsis)
            .paddingAll(kM);

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
      child: [
        if (top != null) top,
        if (bottom != null) bottom,
      ].column()!.constrainedMin(minHeight: minHeight),
    )
        .ink(
          onTap: onTap,
        )
        .material();
  }
}
