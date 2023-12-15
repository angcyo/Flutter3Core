part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///

/// 对话框的一下基础约束
mixin DialogConstraintMixin {
  /// 对话框外边距
  EdgeInsets get dialogMargin =>
      const EdgeInsets.symmetric(horizontal: 61, vertical: kToolbarHeight);

  /// 对话框的最大宽度/高度限制
  BoxConstraints get dialogConstraints => BoxConstraints(
      minWidth: 0,
      maxWidth: min(screenWidth, screenHeight),
      minHeight: 0,
      maxHeight: max(screenWidth, screenHeight));

  /// 对话框的容器
  /// [fillDecoration]
  /// [strokeDecoration]
  Widget dialogContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? color,
    Decoration? decoration,
    AlignmentGeometry? alignment = Alignment.center,
    BoxConstraints? constraints,
    Matrix4? transform,
    BorderRadiusGeometry? borderRadius,
  }) {
    var globalTheme = GlobalTheme.of(context);
    borderRadius ??= BorderRadius.circular(kDefaultBorderRadiusXX);
    return Padding(
      padding: margin ?? dialogMargin,
      child: ConstrainedBox(
        constraints: constraints ?? dialogConstraints,
        child: DecoratedBox(
          decoration: decoration ??
              BoxDecoration(
                color: color ?? globalTheme.themeWhiteColor,
                borderRadius: borderRadius,
              ),
          child: child,
        ),
      ).clip(borderRadius: borderRadius),
    );
  }
}

/// 对话框的一些基础方法
Future<T?> showDialogWidget<T>({
  required BuildContext context,
  required Widget widget,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) =>
    showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      builder: (context) {
        return widget;
      },
    );
