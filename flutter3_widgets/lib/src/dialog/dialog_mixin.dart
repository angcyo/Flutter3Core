part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
///
/// 对话框的一些基础方法,一些基础约束
mixin DialogMixin implements TranslationTypeImpl {
  /// 对话框路径过度动画
  @override
  TranslationType get translationType {
    final type = runtimeType.toString();
    //debugger();
    if (type.endsWith("Page")) {
      return TranslationType.translation;
    }
    return TranslationType.translationFade;
  }

  /// 弹出对话框时, 返回对话框的结果
  dynamic get popDialogResult => null;

  //region ---对话框包裹---

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
      maxHeight: min(screenWidth, screenHeight));

  /// 对话框的容器, 带圆角, 带margin
  /// [decorationColor] 背景颜色
  /// [margin] 整体外边距
  /// [padding] 内容内边距
  /// [blur] 是否使用模糊
  /// [fillDecoration]
  /// [strokeDecoration]
  @property
  Widget buildDialogContainer(
    BuildContext context,
    Widget child, {
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? decorationColor,
    Decoration? decoration,
    BoxConstraints? constraints,
    BorderRadiusGeometry? borderRadius,
    double radius = kDefaultBorderRadiusXX,
    bool blur = false,
  }) {
    final globalTheme = GlobalTheme.of(context);
    borderRadius ??= BorderRadius.circular(radius);
    return Padding(
      padding: margin ?? dialogMargin,
      child: ConstrainedBox(
        constraints: constraints ?? dialogConstraints,
        child: DecoratedBox(
          decoration: decoration ??
              BoxDecoration(
                color: decorationColor ??
                    globalTheme.themeWhiteColor.withOpacity(blur ? 0.85 : 1.0),
                borderRadius: borderRadius,
              ),
          child: child.paddingInsets(padding ?? contentPadding).material(),
        ).blur(sigma: blur ? kL : null),
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
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? decorationColor,
    bool blur = false,
    double radius = kDefaultBorderRadiusXX,
  }) {
    return Center(
      child: buildDialogContainer(
        context,
        margin: margin,
        padding: padding,
        child.matchParent(matchHeight: false),
        radius: radius,
        decorationColor: decorationColor,
        blur: blur,
      ),
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
      ),
    );
  }

  /// 构建一个底部弹出的对话框, 支持一组小部件[WidgetList]
  /// [children] 一组小部件
  /// [enablePullBack] 是否支持下拉关闭
  /// [showDragHandle] 激活下拉关闭时, 是否显示拖拽句柄
  /// [useScroll] 是否使用滚动容器
  /// [animatedSize] 当[children]大小改变时, 是否使用动画大小
  /// [scrollChildIndex] 使用滚动容器时, [children]索引>=此值的child才放大滚动容器中
  /// [contentMinHeight] 滚动容器的最小的高度, 如果小于1, 表示屏幕高度的百分比
  /// [contentMaxHeight] 滚动容器最大的高度, 如果小于1, 表示屏幕高度的百分比
  /// [clipRadius] 整体圆角
  /// [clipTopRadius] 顶部圆角
  /// [clipBottomRadius] 底部圆角
  /// [stackWidget] 堆在内容上的小部件, 如果有
  ///
  /// 如果需要弹出键盘, 可能需要使用[Scaffold]包裹返回的小部件
  ///
  @api
  @entryPoint
  Widget buildBottomChildrenDialog(
    BuildContext context,
    WidgetNullList children, {
    Color? bgColor /*背景颜色, 不指定默认[globalTheme.surfaceBgColor]*/,
    bool enablePullBack = true,
    bool showDragHandle = true,
    double? pullMaxBound,
    void Function(BuildContext context)? onPullBack,
    bool useScroll = false,
    bool animatedSize = false,
    int scrollChildIndex = 1,
    double? height /*固定高度*/,
    double? contentMinHeight,
    double? contentMaxHeight = 0.8,
    //--clip--↓
    double? clipRadius,
    double? clipTopRadius = kDefaultBorderRadiusXXX,
    double? clipBottomRadius,
    Widget? stackWidget,
    bool fullScreen = false /*是否全屏*/,
    //--shadow--↓
    bool showTopShadow = true /*是否显示顶部阴影*/,
  }) {
    Widget body;
    children = children.filterNull();

    if (height != null) {
      contentMinHeight = null;
      contentMaxHeight = null;
    }

    //滚动内容的最小最大高度
    if (contentMinHeight != null && contentMinHeight < 1) {
      contentMinHeight = screenHeight * contentMinHeight;
    }
    if (contentMaxHeight != null && contentMaxHeight < 1) {
      contentMaxHeight = screenHeight * contentMaxHeight;
    }

    if (useScroll) {
      final fixedChildren = children.subList(0, scrollChildIndex);
      final scrollChildren = children.subList(scrollChildIndex);

      Widget? scrollBody = scrollChildren.scroll(
        axis: Axis.vertical,
        physics: enablePullBack ? null : kScrollPhysics,
      );
      //约束高度
      scrollBody = scrollBody?.constrainedMax(
        minHeight: contentMinHeight,
        maxHeight: contentMaxHeight,
      );

      //堆叠小部件
      if (stackWidget != null) {
        scrollBody = scrollBody
                ?.position(all: children.isEmpty ? null : 0)
                .stackOf(stackWidget) ??
            stackWidget.constrainedMax(
              minHeight: contentMinHeight,
              maxHeight: contentMaxHeight,
            );
      }

      body = [
        if (enablePullBack && showDragHandle) buildDragHandle(context),
        ...fixedChildren,
        scrollBody?.expanded(enable: height != null /*固定高度时, 滚动布局需要撑满底部*/),
      ].column()!;
    } else {
      body = [
        if (enablePullBack && showDragHandle) buildDragHandle(context),
        ...children
      ].column()!.constrainedMax(
            minHeight: contentMinHeight,
            maxHeight: contentMaxHeight,
          );

      //堆叠小部件
      if (stackWidget != null) {
        body = body
            .position(all: children.isEmpty ? null : 0)
            .stackOf(stackWidget);
      }
    }

    final globalTheme = GlobalTheme.of(context);
    return body
        .size(height: height)
        .material(color: bgColor ?? globalTheme.surfaceBgColor)
        .clipRadius(
          radius: clipRadius,
          topRadius: clipTopRadius,
          bottomRadius: clipBottomRadius,
        )
        .shadowDecorated(
          shadowColor: showTopShadow ? const Color(0x06000000) : null,
          radius: clipTopRadius == null ? 8 : clipTopRadius / 2,
          decorationColor: Colors.transparent,
          shadowOffset: const Offset(0, -4),
        )
        .pullBack(
          enablePullBack: enablePullBack,
          pullMaxBound: pullMaxBound,
          onPullBack: onPullBack ??
              (context) {
                if (pullMaxBound == null) {
                  closeDialogIf(context);
                }
              },
        )
        .matchParent(matchHeight: fullScreen)
        .align(Alignment.bottomCenter)
        .animatedSize(duration: animatedSize ? kDefaultAnimationDuration : null)
        .adaptiveTablet(context);
  }

  //endregion ---对话框包裹---

  //region ---小部件---

  Widget buildDialogIconTitle(
    BuildContext context, {
    String? title,
    bool enableConfirm = true,
    FutureOr Function()? onConfirm,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return [
      CancelButton(
        useIcon: true,
        onTap: () {
          closeDialogIf(context);
        },
      ),
      title
          ?.text(
            style: globalTheme.textTitleStyle
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )
          .expanded(),
      ConfirmButton(
        useIcon: true,
        enable: enableConfirm,
        onTap: () {
          onConfirm?.call();
          closeDialogIf(context);
        },
      ),
    ].row()!;
  }

  //endregion ---小部件---

  //region 辅助方法

  /// 关闭一个对话框, 如果[close]为true
  @callPoint
  Future<bool> closeDialogIf(BuildContext? context, [bool close = true]) async {
    if (close && context?.isMounted == true) {
      //context?.pop(popDialogResult);
      return await context?.maybePop(popDialogResult) ?? false;
    }
    return false;
  }

//endregion 辅助方法
}

extension DialogExtension on BuildContext {
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
    IgnorePointerType? barrierIgnorePointerType,
  }) async {
    if (!mounted) {
      assert(() {
        l.w('context is not mounted');
        return true;
      }());
      return null;
    }
    return navigatorOf(useRootNavigator).showWidgetDialog<T>(
      widget,
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      traversalEdgeBehavior: traversalEdgeBehavior,
      anchorPoint: anchorPoint,
      type: type,
      barrierIgnorePointerType: barrierIgnorePointerType,
    );
  }
}

extension NavigatorStateDialogEx on NavigatorState {
  //--dialog

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
  Future<T?> showWidgetDialog<T>(
    Widget widget, {
    BuildContext? context,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useBarrierColorAnimate = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Offset? anchorPoint,
    TranslationType? type,
    IgnorePointerType? barrierIgnorePointerType,
  }) async {
    context ??= context?.buildContext ?? buildContext;
    if (context == null || !context.mounted) {
      assert(() {
        l.w('context is null or not mounted');
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

    type ??= widget.getWidgetTranslationType();

    return push<T>(DialogPageRoute<T>(
      context: context,
      builder: (context) {
        return widget;
      },
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useBarrierColorAnimate: useBarrierColorAnimate,
      settings: routeSettings,
      themes: themes,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior:
          traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
      type: type,
      barrierIgnorePointerType: barrierIgnorePointerType,
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
}
