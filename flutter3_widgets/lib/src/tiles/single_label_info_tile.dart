part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/13
///
///
/// 左[label]/下[des]  右[info]. 右[endWidget]的信息展示tile
class SingleLabelInfoTile extends StatelessWidget {
  /// 标签
  final String? label;
  final Widget? labelWidget;
  final TextStyle? labelTextStyle;

  /// 标签下面的描述信息
  final String? des;
  final Widget? desWidget;
  final TextStyle? desTextStyle;

  /// [des]与[label]之间的间隙
  final double desGap;

  /// 信息
  final String? info;
  final Widget? infoWidget;

  /// [GlobalTheme.textGeneralStyle]
  @defInjectMark
  final TextStyle? infoTextStyle;

  /// 整体的内边距
  @defInjectMark
  final EdgeInsetsGeometry? padding;

  /// 信息右边的箭头
  /// 如果设置了[onTap], 自动会注入`右箭头图标`
  @defInjectMark
  final Widget? endWidget;

  /// 最小高度
  final double? minHeight;

  /// 点击事件, 同时决定是否要显示默认的箭头
  final GestureTapCallback? onTap;

  const SingleLabelInfoTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.desGap = kL,
    this.des,
    this.desWidget,
    this.desTextStyle,
    this.info,
    this.infoWidget,
    this.infoTextStyle,
    this.padding,
    this.endWidget,
    this.onTap,
    this.minHeight = kMinInteractiveHeight,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final labelWidget = this.labelWidget ??
        label?.text(style: labelTextStyle ?? globalTheme.textLabelStyle);
    final desWidget = this.desWidget ??
        des?.text(style: desTextStyle ?? globalTheme.textDesStyle);

    final infoTextStyle = this.infoTextStyle ?? globalTheme.textGeneralStyle;
    var infoWidget = this.infoWidget ?? info?.text(style: infoTextStyle);

    final endWidget = this.endWidget ??
        (onTap == null
            ? null
            : Icon(
                Icons.arrow_forward_ios /*Icons.navigate_next_sharp*/,
                size: 14.0,
                color: infoTextStyle.color,
              ));

    final columnList = [
      if (labelWidget != null) labelWidget,
      if (desWidget != null) desWidget,
    ];
    Widget? column;
    if (columnList.isNotEmpty) {
      column = columnList.column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        gap: desGap,
      );
    }

    infoWidget = infoWidget?.align(Alignment.centerRight);
    if (infoWidget == null) {
      column = column?.expanded();
    } else {
      infoWidget = infoWidget.expanded();
    }

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
      child: [
        if (column != null) column,
        if (infoWidget != null) infoWidget,
        if (endWidget != null && endWidget is! IgnoreWidget) endWidget
      ].row(gap: kM)!.constrainedMin(minHeight: minHeight),
    ).ink(onTap).material();
  }
}
