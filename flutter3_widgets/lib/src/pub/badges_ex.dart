part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/03
///
/// 角标
extension WidgetBadgesEx on Widget {
  /// 角标
  /// [text] 角标文本, null则不显示角标, ""则显示小红点, 其他则显示文本
  /// [padding] 内部内边距
  /// [offset] 偏移量
  /// [badges.BadgeStyle] 角标样式
  Widget badge({
    String? text = "",
    TextStyle? textStyle = const TextStyle(fontSize: 10, color: Colors.white),
    Alignment alignment = Alignment.topRight,
    EdgeInsetsGeometry? padding,
    Offset? offset,
    bool? showBadge,
    //--
    double? minSize = 12,
  }) {
    showBadge ??= text != null;
    final isDot = isNullOrEmpty(text);
    final badges.BadgePosition? position;
    switch (alignment) {
      case Alignment.topLeft:
        position = badges.BadgePosition.topStart(
          top: offset?.dy ?? -5,
          start: offset?.dx ?? -10,
        );
        break;
      case Alignment.topRight:
        if (isDot) {
          offset ??= const Offset(0, 0);
        }
        position = badges.BadgePosition.topEnd(
          top: offset?.dy ?? -8,
          end: offset?.dx ?? -10,
        );
        break;
      case Alignment.bottomLeft:
        position = badges.BadgePosition.bottomStart(
          bottom: offset?.dy ?? -8,
          start: offset?.dx ?? -10,
        );
        break;
      case Alignment.bottomRight:
        position = badges.BadgePosition.bottomEnd(
          bottom: offset?.dy ?? -8,
          end: offset?.dx ?? -10,
        );
        break;
      default:
        position = badges.BadgePosition.center();
        break;
    }
    final badges.BadgeShape shape = (text?.length ?? 0) > 2 ? .square : .circle;
    return badges.Badge(
      position: position,
      badgeStyle: badges.BadgeStyle(
        shape: shape,
        borderRadius: BorderRadius.circular(kDefaultBorderRadiusL),
        padding:
            padding ??
            (shape == .circle
                ? const EdgeInsets.all(2)
                : const EdgeInsets.symmetric(horizontal: 2)),
      ),
      badgeContent: text != null && text.isNotEmpty
          ? text
                .text(style: textStyle, textAlign: .center)
                .constrainedMin(minSize: minSize)
          : null,
      showBadge: showBadge,
      child: this,
    );
  }
}
