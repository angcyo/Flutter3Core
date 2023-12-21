part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/13
///
///
/// 左[label] 右[info] 的信息展示tile
class SingleLabelInfoTile extends StatelessWidget {
  /// 标签
  final String? label;
  final Widget? labelWidget;

  /// 标签下面的描述信息
  final String? des;
  final Widget? desWidget;

  /// 信息
  final String? info;
  final Widget? infoWidget;

  /// 整体的内边距
  final EdgeInsetsGeometry? padding;

  /// 信息右边的箭头
  final Widget? infoIcon;

  /// 最小高度
  final double? minHeight;

  /// 点击事件, 同时决定是否要显示默认的箭头
  final GestureTapCallback? onTap;

  const SingleLabelInfoTile({
    super.key,
    this.label,
    this.labelWidget,
    this.des,
    this.desWidget,
    this.info,
    this.padding,
    this.infoWidget,
    this.infoIcon,
    this.onTap,
    this.minHeight = kMinInteractiveHeight,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final left = labelWidget ?? label?.text(style: globalTheme.textLabelStyle);
    final leftBottom = desWidget ?? des?.text(style: globalTheme.textDesStyle);

    var right = infoWidget ?? info?.text(style: globalTheme.textInfoStyle);

    final rightIco = infoIcon ??
        (onTap == null
            ? null
            : Icon(
                Icons.arrow_forward_ios /*Icons.navigate_next_sharp*/,
                size: 14.0,
                color: globalTheme.textInfoStyle.color,
              ));

    final columnList = [
      if (left != null) left,
      if (leftBottom != null) leftBottom,
    ];

    Widget? column;
    if (columnList.isNotEmpty) {
      column = columnList.column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start);
    }

    right = right?.align(alignment: Alignment.centerRight);
    if (right == null) {
      column = column?.expanded();
    } else {
      right = right.expanded();
    }

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
      child: [
        if (column != null) column,
        if (right != null) right,
        if (rightIco != null && rightIco is! IgnoreWidget) rightIco
      ].row().constrainedMin(minHeight: minHeight),
    )
        .ink(
          onTap: onTap,
        )
        .material();
  }
}
