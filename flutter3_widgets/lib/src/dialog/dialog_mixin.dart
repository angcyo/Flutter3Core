part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
///
/// [Dialog] 对话框布局
/// [AlertDialog] 对话框组件[IntrinsicWidth]
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
  /// 系统默认的对话框内边距[_defaultInsetPadding]
  EdgeInsets get dialogMargin =>
      const EdgeInsets.symmetric(horizontal: 60, vertical: kToolbarHeight);

  /// 对话框内容内边距
  EdgeInsets get contentPadding =>
      const EdgeInsets.symmetric(horizontal: kX, vertical: kX);

  /// 对话框的最大宽度/高度限制
  /// 系统[Dialog]最小宽度280.0
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
        ).blur(sigma: blur ? kL : null).iw(),
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
  /// [bottomWidget] 放在底部的小部件, 如果有
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
    bool maybePop = false /*使用[maybePop]还是[pop]*/,
    double? pullMaxBound,
    void Function(BuildContext context)? onPullBack,
    bool useScroll = false,
    bool useRScroll = false,
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
    //--column--↓
    MainAxisAlignment? mainAxisAlignment, //MainAxisAlignment.start
    //CrossAxisAlignment.center, 需要考虑拖动手柄的样式
    CrossAxisAlignment? crossAxisAlignment,
    Widget? bottomWidget /*放在底部的小部件*/,
    //--safeArea
    bool useSafeArea = true,
  }) {
    Widget body;
    children = children.filterNull();

    if (height != null) {
      contentMinHeight = null;
      contentMaxHeight = null;
    }
    if (fullScreen) {
      contentMaxHeight = null;
    }

    //滚动内容的最小最大高度
    if (contentMinHeight != null && contentMinHeight < 1) {
      contentMinHeight = screenHeight * contentMinHeight;
    }
    if (contentMaxHeight != null && contentMaxHeight < 1) {
      contentMaxHeight = screenHeight * contentMaxHeight;
    }

    if (useRScroll) {
      useScroll = true;
    }

    if (useScroll) {
      final fixedChildren = children.subList(0, scrollChildIndex);
      final scrollChildren = children.subList(scrollChildIndex);

      Widget? scrollBody = useRScroll
          ? scrollChildren.rScroll(
              axis: Axis.vertical,
              physics: enablePullBack ? null : kScrollPhysics,
            )
          : scrollChildren.scroll(
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
        scrollBody?.expanded(
            enable: height != null || fullScreen /*固定高度时, 滚动布局需要撑满底部*/),
        bottomWidget,
      ].column()!;
    } else {
      //普通布局, 不使用滚动布局
      body = [
        if (enablePullBack && showDragHandle) buildDragHandle(context),
        ...children,
        bottomWidget,
      ]
          .column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
          )!
          .constrainedMax(
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
    final navigator = context.navigatorOf();
    final route = context.modalRoute;
    return body
        .size(height: height)
        .safeArea(useSafeArea: useSafeArea, maintainBottomViewPadding: true)
        .material(color: bgColor ?? globalTheme.dialogSurfaceBgColor)
        .clipRadius(
          radius: clipRadius,
          topRadius: clipTopRadius,
          bottomRadius: clipBottomRadius,
        )
        .shadowDecorated(
          shadowColor: showTopShadow ? kShadowColor : null,
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
                  //debugger();
                  /*if (route?.isCurrent == true) {
                    closeDialogIf(context, true, maybePop);
                  } else {*/
                  navigator.removeRouteIf(route);
                  /*}*/
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
  Future<bool> closeDialogIf(
    BuildContext? context, [
    bool close = true,
    bool maybePop = false,
    Route? route,
  ]) async {
    if (close && context?.isMounted == true) {
      if (maybePop) {
        return await context?.maybePop(popDialogResult) ?? false;
      }
      if (route == null) {
        context?.pop(popDialogResult);
      } else {
        context?.removeRouteIf(route);
      }
      return true;
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
  /// [popLast] pop弹出最后一个路由
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
    bool popLast = false,
  }) async {
    if (!mounted) {
      assert(() {
        l.w('context is not mounted');
        return true;
      }());
      return null;
    }
    final navigator = navigatorOf(useRootNavigator);
    if (popLast) {
      navigator.pop();
    }
    return navigator.showWidgetDialog<T>(
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

  /// 在指定位置弹出一个菜单
  /// [showMenu]
  /// [PopupMenuButton]
  ///
  /// 内部使用[_PopupMenuRoute]路由实现的[NavigatorState.push]
  ///
  /// [constraints]
  /// When unspecified, defaults to:
  /// ```dart
  /// const BoxConstraints(
  ///   minWidth: 2.0 * 56.0,
  ///   maxWidth: 5.0 * 56.0,
  /// )
  /// ```
  ///
  /// [requestFocus] If null, [Navigator.requestFocus] will be used instead.
  ///
  /// [_PopupMenuDefaultsM3]
  /// [menuItemPadding]
  ///
  /// [showMenus]
  /// [showWidgetMenu]
  Future<T?> showMenus<T>(
    List<Widget>? menus /*辅助生成items*/, {
    List<PopupMenuEntry<T>>? items /*菜单项*/,
    //--
    T? initialValue,
    PopupMenuPosition? menuPosition /*PopupMenuPosition.over*/,
    //--
    Offset? position /*强行指定在overlay中的位置, 此位置会自动偏移anchor的左上角偏移*/,
    //--
    Offset offset = Offset.zero /*相对锚点左上角额外偏移的量*/,
    //--
    double? elevation = kH,
    Color? color /*菜单的背景颜色*/,
    Color? shadowColor = Colors.black /*kShadowColor*/,
    Color? surfaceTintColor/*= Colors.transparent*/,
    ShapeBorder? shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0))),
    EdgeInsets? menuPadding = const EdgeInsets.symmetric(vertical: 8.0),
    BoxConstraints? constraints,
    Clip clipBehavior = Clip.none,
    //--
    bool useRootNavigator = false,
    AnimationStyle? popUpAnimationStyle,
    RouteSettings? routeSettings,
    bool? requestFocus,
  }) async {
    if (!mounted) {
      assert(() {
        l.w('context is not mounted');
        return true;
      }());
      return null;
    }

    items ??= menus?.map((e) {
      return PopupMenuItem<T>(
        value: e as dynamic,
        child: e,
      );
    }).toList();

    if (isNil(items)) {
      assert(() {
        l.w('items is null');
        return true;
      }());
      return null;
    }

    //anchor
    final anchor = findRenderObject();
    if (anchor is! RenderBox) {
      assert(() {
        l.w('anchor is null');
        return true;
      }());
      return null;
    }

    //用来定位
    final RenderBox overlay = Navigator.of(
      this,
      rootNavigator: useRootNavigator,
    ).overlay!.context.findRenderObject()! as RenderBox;

    //位置信息
    final RelativeRect relativePosition;
    if (position == null) {
      final PopupMenuPosition popupMenuPosition =
          menuPosition ?? PopupMenuPosition.over;
      switch (popupMenuPosition) {
        case PopupMenuPosition.over:
          offset = offset;
        case PopupMenuPosition.under:
          offset = Offset(0.0, anchor.size.height) + offset;
      }
      relativePosition = RelativeRect.fromRect(
        Rect.fromPoints(
          anchor.localToGlobal(offset, ancestor: overlay),
          anchor.localToGlobal(
            anchor.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay,
          ),
        ),
        Offset.zero & overlay.size,
      );
    } else {
      final anchorLT = anchor.localToGlobal(offset, ancestor: overlay);
      relativePosition = RelativeRect.fromRect(
        Rect.fromPoints(
          anchorLT + position + offset,
          anchorLT + position + offset,
        ),
        Offset.zero & overlay.size,
      );
    }

    return showMenu<T?>(
      context: this,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      items: items ?? [],
      initialValue: initialValue,
      position: relativePosition,
      shape: shape,
      menuPadding: menuPadding,
      color: color,
      constraints: constraints,
      clipBehavior: clipBehavior,
      useRootNavigator: useRootNavigator,
      popUpAnimationStyle: popUpAnimationStyle,
      routeSettings: routeSettings,
      requestFocus: requestFocus,
    );
  }

  /// [showMenus]
  /// [showWidgetMenu]
  Future<T?> showWidgetMenu<T>(
    Widget menu, {
    PopupMenuPosition? menuPosition /*PopupMenuPosition.over*/,
    //--
    Offset? position /*强行指定在overlay中的位置, 此位置会自动偏移anchor的左上角偏移*/,
    //--
    Offset offset = Offset.zero /*相对锚点左上角额外偏移的量*/,
    //--
    double? elevation = kH,
    Color? color /*菜单的背景颜色*/,
    Color? shadowColor = Colors.black /*kShadowColor*/,
    Color? surfaceTintColor/*= Colors.transparent*/,
    ShapeBorder? shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0))),
    EdgeInsets? menuPadding = const EdgeInsets.symmetric(vertical: 8.0),
    BoxConstraints? constraints,
    Clip clipBehavior = Clip.none,
    //--
    bool useRootNavigator = false,
    AnimationStyle? popUpAnimationStyle,
    RouteSettings? routeSettings,
    bool? requestFocus,
  }) async {
    if (!mounted) {
      assert(() {
        l.w('context is not mounted');
        return true;
      }());
      return null;
    }

    //anchor
    final anchor = findRenderObject();
    if (anchor is! RenderBox) {
      assert(() {
        l.w('anchor is null');
        return true;
      }());
      return null;
    }

    //用来定位
    final RenderBox overlay = Navigator.of(
      this,
      rootNavigator: useRootNavigator,
    ).overlay!.context.findRenderObject()! as RenderBox;

    //位置信息
    final RelativeRect relativePosition;
    if (position == null) {
      final PopupMenuPosition popupMenuPosition =
          menuPosition ?? PopupMenuPosition.over;
      switch (popupMenuPosition) {
        case PopupMenuPosition.over:
          offset = offset;
        case PopupMenuPosition.under:
          offset = Offset(0.0, anchor.size.height) + offset;
      }
      relativePosition = RelativeRect.fromRect(
        Rect.fromPoints(
          anchor.localToGlobal(offset, ancestor: overlay),
          anchor.localToGlobal(
            anchor.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay,
          ),
        ),
        Offset.zero & overlay.size,
      );
    } else {
      final anchorLT = anchor.localToGlobal(offset, ancestor: overlay);
      relativePosition = RelativeRect.fromRect(
        Rect.fromPoints(
          anchorLT + position + offset,
          anchorLT + position + offset,
        ),
        Offset.zero & overlay.size,
      );
    }

    return pushRoute<T>(
      PopupMenuRoute(
        menu: menu,
        position: relativePosition,
        clipBehavior: clipBehavior,
        popUpAnimationStyle: popUpAnimationStyle,
        shape: shape,
        elevation: elevation,
        color: color,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        settings: routeSettings,
        requestFocus: requestFocus,
      ),
      rootNavigator: useRootNavigator,
    );
  }
}

extension NavigatorStateDialogEx on NavigatorState {
  //--dialog

  /// 对话框的一些基础方法
  /// [barrierDismissible] 窗口外是否可以销毁对话框
  /// [barrierColor] 障碍的颜色, 默认是[Colors.black54]
  ///
  /// 内部使用路由实现的[NavigatorState.push]
  ///
  /// [useSafeArea] 是否使用安全区域
  ///
  /// [DialogRoute]
  /// [DialogPageRoute]
  /// [showDialog]
  /// [DialogExtension.showWidgetDialog]
  ///
  /// [PopupRoute]
  /// [showMenu]
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
