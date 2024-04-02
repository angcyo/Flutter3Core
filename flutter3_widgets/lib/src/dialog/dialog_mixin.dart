part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
///

const String kDialogCancel = '取消';
const String kDialogConfirm = '确定';
const String kDialogSave = '保存';

/// 对话框的一些基础方法,一些基础约束
mixin DialogMixin implements TranslationTypeImpl {
  @override
  TranslationType get translationType => TranslationType.translationFade;

  /// 对话框外边距
  EdgeInsets get dialogMargin =>
      const EdgeInsets.symmetric(horizontal: 60, vertical: kToolbarHeight);

  /// 对话框内容内边距
  EdgeInsets get contentPadding =>
      const EdgeInsets.symmetric(horizontal: kX, vertical: kX);

  /// 对话框的最大宽度/高度限制
  BoxConstraints get dialogConstraints => BoxConstraints(
      minWidth: 0,
      maxWidth: min(screenWidth, screenHeight),
      minHeight: 0,
      maxHeight: max(screenWidth, screenHeight));

  /// 对话框的容器, 带圆角, 带margin
  /// [color] 背景颜色
  /// [margin] 整体外边距
  /// [padding] 内容内边距
  /// [fillDecoration]
  /// [strokeDecoration]
  @property
  Widget buildDialogContainer(
    BuildContext context,
    Widget child, {
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? color,
    Decoration? decoration,
    BoxConstraints? constraints,
    BorderRadiusGeometry? borderRadius,
    double radius = kDefaultBorderRadiusXX,
  }) {
    var globalTheme = GlobalTheme.of(context);
    borderRadius ??= BorderRadius.circular(radius);
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
          child: child.paddingInsets(padding ?? contentPadding),
        ),
      ).clip(borderRadius: borderRadius),
    );
  }

  /// 居中显示的对话框样式
  /// [buildCenterDialog]
  @api
  @entryPoint
  Widget buildCenterDialog(
    BuildContext context,
    Widget child, {
    double radius = kDefaultBorderRadiusXX,
  }) {
    return Center(
      child: buildDialogContainer(
        context,
        child.matchParent(matchHeight: false),
        radius: radius,
      ).material(),
    );
  }

  /// 底部全屏显示的对话框样式
  /// [child] 小部件
  @api
  Widget buildBottomDialog(
    BuildContext context,
    Widget child, {
    double radius = kDefaultBorderRadiusXX,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: buildDialogContainer(
        context,
        child.matchParent(matchHeight: false),
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
      ) /*.material()*/,
    );
  }

  /// 构建一个底部弹出的对话框, 支持一组小部件[WidgetList]
  /// [children] 一组小部件
  /// [clipRadius] 整体圆角
  /// [clipTopRadius] 顶部圆角
  /// [clipBottomRadius] 底部圆角
  @api
  @entryPoint
  Widget buildBottomColumnDialog(
    BuildContext context,
    WidgetList children, {
    double? clipRadius,
    double? clipTopRadius,
    double? clipBottomRadius,
  }) {
    return children
        .column()!
        .container(color: Colors.white)
        .clipRadius(
          radius: clipRadius,
          topRadius: clipTopRadius,
          bottomRadius: clipBottomRadius,
        )
        .matchParent(matchHeight: false)
        .align(Alignment.bottomCenter);
  }

  //region 辅助方法

  /// 关闭一个对话框, 如果[close]为true
  @callPoint
  void closeDialogIf(BuildContext context, [bool close = true]) {
    if (close) {
      Navigator.of(context).pop();
    }
  }

//endregion 辅助方法
}

/// 对话框的一些基础方法
/// [barrierDismissible] 窗口外是否可以销毁对话框
/// [barrierColor] 障碍的颜色, 默认是[Colors.black54]
///
/// [useSafeArea] 是否使用安全区域
///
/// [DialogRoute]
/// [DialogPageRoute]
/// [showDialog]
/// [DialogExtension.showWidgetDialog]
Future<T?> showDialogWidget<T>(
  BuildContext context,
  Widget widget, {
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  Offset? anchorPoint,
  TranslationType? type,
}) async {
  if (!context.mounted) {
    assert(() {
      l.w('context is not mounted');
      return true;
    }());
    return null;
  }

  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  if (type == null) {
    if (widget is TranslationTypeImpl) {
      type = (widget as TranslationTypeImpl).translationType;
    }
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(DialogPageRoute<T>(
    context: context,
    builder: (context) {
      return widget;
    },
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    settings: routeSettings,
    themes: themes,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior:
        traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
    type: type,
  ));

  /*return showDialog<T>(
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
  );*/
}

extension DialogExtension on BuildContext {
  /// 显示对话框
  /// [showDialogWidget]
  Future<T?> showWidgetDialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Offset? anchorPoint,
    TranslationType? type,
  }) async {
    if (!mounted) {
      assert(() {
        l.w('context is not mounted');
        return true;
      }());
      return null;
    }
    return showDialogWidget<T>(
      this,
      widget,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      traversalEdgeBehavior: traversalEdgeBehavior,
      anchorPoint: anchorPoint,
      type: type,
    );
  }
}
