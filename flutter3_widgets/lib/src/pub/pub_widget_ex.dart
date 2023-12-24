part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/22
///

extension PubStringEx on String {
  /// 有个问题: 显示全部 会被切行
  /// [RichReadMoreText]
  Widget toRichReadMore({
    int? trimLines = 2,
    int? trimLength,
    String trimCollapsedText = '...显示全部',
    String trimExpandedText = ' 收起',
    TextStyle? textStyle,
    BuildContext? context,
    TextStyle? moreStyle = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    TextStyle? lessStyle = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  }) =>
      RichReadMoreText(
        toTextSpan(style: textStyle),
        settings: trimLines != null
            ? LineModeSettings(
                trimLines: trimLines,
                trimExpandedText: trimExpandedText,
                trimCollapsedText: trimCollapsedText,
                moreStyle: moreStyle,
                lessStyle: lessStyle,
                textScaler: TextScaler.noScaling,
              )
            : LengthModeSettings(
                trimLength: trimLength!,
                trimExpandedText: trimExpandedText,
                trimCollapsedText: trimCollapsedText,
                moreStyle: moreStyle,
                lessStyle: lessStyle,
                textScaler: TextScaler.noScaling,
              ),
      );
}

/// [Slidable] 侧滑菜单action
SlidableAction slideAction({
  BuildContext? context,
  String? label,
  IconData? icon,
  Color? backgroundColor,
  Color? foregroundColor,
  SlidableActionCallback? onPressed,
  bool autoClose = true,
  int flex = 1,
  double spacing = 4,
  BorderRadius borderRadius = BorderRadius.zero,
  EdgeInsets? padding,
}) =>
    SlidableAction(
      onPressed: onPressed ??
          (context) {
            l.i('点击action:$label');
          },
      backgroundColor: backgroundColor ?? GlobalTheme.of(context).accentColor,
      foregroundColor:
          foregroundColor ?? GlobalTheme.of(context).themeWhiteColor,
      icon: icon,
      label: label,
      autoClose: autoClose,
      flex: flex,
      spacing: spacing,
      padding: padding,
      borderRadius: borderRadius,
    );

extension PubWidgetEx on Widget {
  /// [Slidable] 侧滑删除小部件
  /// [slideAction] 侧滑菜单action
  /// 几种效果: https://pub.dev/packages/flutter_slidable#motions
  /// [BehindMotion]
  /// [StretchMotion]
  /// [DrawerMotion]
  /// [ScrollMotion]
  /// [startExtentRatio].[endExtentRatio] 侧滑菜单的宽度比例
  /// [onStartDismissed].[onEndDismissed] 配置这个之后, 侧滑菜单支持整条滑动删除
  Widget slideActions({
    Key? key,
    List<SlidableAction>? startActions,
    Widget? startMotion,
    VoidCallback? onStartDismissed,
    List<SlidableAction>? endActions,
    Widget? endMotion,
    VoidCallback? onEndDismissed,
    bool closeOnScroll = true,
    bool enabled = true,
    Axis direction = Axis.horizontal,
    double startExtentRatio = 0.5,
    double endExtentRatio = 0.5,
  }) =>
      Slidable(
        key: key,
        startActionPane: isNullOrEmpty(startActions)
            ? null
            : ActionPane(
                extentRatio: startExtentRatio,
                motion: startMotion ?? const DrawerMotion(),
                dismissible: isNullOrEmpty(onStartDismissed)
                    ? null
                    : DismissiblePane(onDismissed: onStartDismissed!),
                children: startActions!,
              ),
        endActionPane: isNullOrEmpty(endActions)
            ? null
            : ActionPane(
                extentRatio: endExtentRatio,
                motion: endMotion ?? const DrawerMotion(),
                dismissible: isNullOrEmpty(onEndDismissed)
                    ? null
                    : DismissiblePane(onDismissed: onEndDismissed!),
                children: endActions!,
              ),
        direction: direction,
        closeOnScroll: closeOnScroll,
        enabled: enabled,
        child: this,
      );
}
