part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/13
///

/// 左[label] 右[info] 的信息展示tile
class SingleLabelInfoTile extends StatelessWidget {
  /// 标签
  final String? label;
  final Widget? labelWidget;

  /// 信息
  final String? info;
  final Widget? infoWidget;

  /// 整体的内边距
  final EdgeInsetsGeometry? padding;

  /// 信息右边的箭头
  final Widget? infoIcon;

  /// 最小高度
  final double? minHeight;

  /// 点击事件, 同事决定是否要显示默认的箭头
  final GestureTapCallback? onTap;

  const SingleLabelInfoTile({
    super.key,
    this.label,
    this.labelWidget,
    this.info,
    this.padding,
    this.infoWidget,
    this.infoIcon,
    this.onTap,
    this.minHeight = kMinInteractiveHeight,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    var left = labelWidget ??
        label?.text(style: globalTheme.textLabelStyle) ??
        const Empty();
    var right = infoWidget ??
        info?.text(style: globalTheme.textInfoStyle) ??
        const Empty();
    var rightIco = infoIcon ??
        (onTap == null
            ? null
            : Icon(
                Icons.arrow_forward_ios /*Icons.navigate_next_sharp*/,
                size: 14.0,
                color: globalTheme.textInfoStyle.color,
              ));

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
      child: [
        left,
        right.align(alignment: Alignment.centerRight).expanded(),
        if (rightIco != null && rightIco is! IgnoreWidget) rightIco
      ].row().constrainedMin(minHeight: minHeight),
    )
        .ink(
          onTap: onTap,
        )
        .material();
  }
}
