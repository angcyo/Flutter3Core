part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
/// 对话框的一些基础方法,一些基础约束
///
/// - [Dialog] 对话框布局
/// - [AlertDialog] 对话框组件[IntrinsicWidth]
///
/// - [DialogMixin]
/// - [DesktopDialogMixin]
///
mixin DialogMixin implements TranslationTypeImpl {
  /// [Dialog]对话框外点击是否关闭
  @override
  bool get dialogBarrierDismissible => true;

  @override
  Color? get dialogBarrierColor => null;

  @override
  bool get dialogUseRootNavigator => true;

  /// 对话框路径过度动画
  @override
  TranslationType get translationType {
    final type = runtimeType.toString().toLowerCase();
    //debugger();
    if (type.isScreenName) {
      return TranslationType.translation;
    }
    if (type.contains("desktop")) {
      return TranslationType.scaleFade;
    }
    if (type.contains("bottom")) {
      return TranslationType.translationFade;
    }
    return isDesktopOrWeb
        ? TranslationType.scaleFade
        : TranslationType.translationFade;
  }

  @override
  Alignment? get popupPreferredAlignment => .bottomCenter;

  //MARK: -

  /// 弹出对话框时, 返回对话框的结果
  dynamic get popDialogResult => null;

  //region ---对话框包裹---

  /// 对话框外边距
  /// 系统默认的对话框内边距[_defaultInsetPadding]
  EdgeInsets get dialogMargin =>
      const EdgeInsets.symmetric(horizontal: 60, vertical: kToolbarHeight);

  /// 对话框内容内边距
  EdgeInsets get dialogContentPadding =>
      const EdgeInsets.symmetric(horizontal: kX, vertical: kX);

  /// 对话框的最小宽度限制
  /// - [dialogConstraints]
  double get dialogMinWidth => kDialogMinWidth;

  /// 对话框的最小高度限制
  /// - [dialogConstraints]
  double get dialogMinHeight => 0;

  /// 对话框的最大宽度/高度限制
  /// 系统[Dialog]最小宽度280.0
  BoxConstraints get dialogConstraints => BoxConstraints(
    minWidth: dialogMinWidth,
    maxWidth: min(screenWidth, screenHeight),
    minHeight: dialogMinHeight,
    maxHeight: min(screenWidth, screenHeight),
  );

  /// 是否背景模糊处理
  bool get dialogBlur => false;

  /// 对话框的容器, 带圆角, 带[margin]
  /// - [decorationColor] 背景颜色
  /// - [margin] 整体外边距
  /// - [padding] 内容内边距
  /// - [blur] 是否使用模糊
  /// - [showCloseButton] 是否显示关闭按钮
  ///
  /// - [fillDecoration]
  /// - [strokeDecoration]
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
    bool? blur /*是否启用模糊*/,
    bool? shadow = true /*是否启用阴影*/,
    bool? showCloseButton,
  }) {
    final globalTheme = GlobalTheme.of(context);
    borderRadius ??= BorderRadius.circular(radius);
    margin ??= dialogMargin;
    padding ??= dialogContentPadding;
    constraints ??= dialogConstraints;
    blur ??= dialogBlur;
    return Padding(
      padding: margin,
      child:
          ConstrainedBox(
                constraints: constraints,
                child: DecoratedBox(
                  decoration:
                      decoration ??
                      BoxDecoration(
                        color:
                            decorationColor ??
                            globalTheme.themeWhiteColor.withOpacity(
                              blur ? 0.85 : 1.0,
                            ),
                        borderRadius: borderRadius,
                        /*boxShadow: [kBoxShadow],*/
                      ),
                  child: child
                      .paddingInsets(padding)
                      .stackOf(
                        showCloseButton == true
                            ? IconButton(
                                onPressed: () {
                                  closeDialogIf(context);
                                },
                                icon: const Icon(Icons.close),
                              ).insets(all: kL).position(right: 0, top: 0)
                            : null,
                      )
                      .material(),
                ).blur(sigma: blur ? kL : null).iw(),
              )
              .clip(borderRadius: borderRadius)
              .shadowDecorated(
                radius: kDefaultBorderRadiusXX,
                decorationColor: decorationColor,
                /*shadowColor: shadow,*/
                enable: shadow == true,
              ),
    );
  }

  /// 自动适配居中显示的对话框
  /// - [buildCenterDialog]
  /// - [buildDesktopCenterDialog]
  @api
  @entryPoint
  @adaptiveLayout
  Widget buildAdaptiveCenterDialog(
    BuildContext context,
    Widget content, {
    EdgeInsets? margin,
    EdgeInsets? contentPadding = EdgeInsets.zero,
    Color? decorationColor,
    bool? blur /*是否启用模糊*/,
    bool? shadow = true /*是否启用阴影*/,
    double radius = kDefaultBorderRadiusXX,
    BoxConstraints? contentConstraints,
    //--
    FocusOnKeyEventCallback? onKeyEvent,
    dynamic result,
    bool? autoCloseDialog,
    bool? showCloseButton,
  }) {
    return buildDesktopCenterDialog(
      context,
      content,
      margin: margin,
      contentPadding: contentPadding,
      decorationColor: decorationColor,
      blur: blur,
      shadow: shadow,
      radius: radius,
      contentConstraints: contentConstraints,
      onKeyEvent: onKeyEvent,
      result: result,
      autoCloseDialog: autoCloseDialog,
      showCloseButton: showCloseButton,
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
    bool? blur,
    double radius = kDefaultBorderRadiusXX,
    BoxConstraints? contentConstraints,
    //--
    dynamic result,
    //--
    bool? autoCloseDialog,
  }) {
    return Center(
          child: buildDialogContainer(
            context,
            margin: margin,
            padding: padding,
            child.matchParent(matchHeight: false),
            constraints: contentConstraints,
            radius: radius,
            decorationColor: decorationColor,
          ),
        )
        .blur(enable: blur == true)
        .autoCloseDialog(
          context,
          result: result,
          rootNavigator: dialogUseRootNavigator,
          enable: autoCloseDialog ?? dialogBarrierDismissible,
          tag: classHash(),
        );
  }

  /// 居中显示的桌面样式的对话框
  /// [buildCenterDialog]
  @api
  @entryPoint
  @desktopLayout
  Widget buildDesktopCenterDialog(
    BuildContext context,
    Widget content, {
    EdgeInsets? margin,
    EdgeInsets? contentPadding = EdgeInsets.zero,
    Color? decorationColor,
    bool? blur /*是否启用模糊*/,
    bool? shadow = true /*是否启用阴影*/,
    double radius = kDefaultBorderRadiusXX,
    BoxConstraints? contentConstraints,
    //--
    FocusOnKeyEventCallback? onKeyEvent,
    dynamic result,
    bool? autoCloseDialog,
    bool? showCloseButton,
  }) {
    //debugger();
    return Center(
          child: buildDialogContainer(
            context,
            margin: margin,
            padding: contentPadding,
            content.desktopConstrained().matchParent(matchHeight: false),
            constraints: contentConstraints,
            radius: radius,
            decorationColor: decorationColor,
            shadow: shadow,
            showCloseButton: showCloseButton,
          ),
        )
        .blur(enable: blur == true)
        .autoCloseDialog(
          context,
          onKeyEvent: onKeyEvent,
          result: result,
          tag: classHash(),
          enable: autoCloseDialog ?? dialogBarrierDismissible,
        );
  }

  /// 底部撑满显示的对话框样式
  /// [child] 内容小部件
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
    ).autoCloseDialog(context, enable: dialogBarrierDismissible);
  }

  /// 底部撑满显示的对话框样式
  /// [child] 内容小部件
  @api
  Widget buildBottomDialog2(
    BuildContext context,
    Widget child, {
    double? height /*固定高度*/,
    double radius = kDefaultBorderRadiusXX,
    Color? bgColor /*背景颜色, 不指定默认[globalTheme.surfaceBgColor]*/,
    bool animatedSize = true,
    bool fullScreen = false /*是否全屏*/,
    //--pull back
    bool enablePullBack = false,
    bool useScrollConsume = true,
    double? pullMaxBound,
    void Function(BuildContext context)? onPullBack,
    //--clip--↓
    double? clipRadius,
    double? clipTopRadius = kDefaultBorderRadiusXXX,
    double? clipBottomRadius,
    //--shadow--↓
    bool showTopShadow = true /*是否显示顶部阴影*/,
    //--
    bool? blur,
    //--safeArea
    bool useSafeArea = true,
  }) {
    blur ??= dialogBlur;

    final body = child;

    final globalTheme = GlobalTheme.of(context);
    final navigator = context.navigatorOf();
    final route = context.modalRoute;

    if (height != null) {
      if (height < 1) {
        height = screenHeight * height;
      }
    }

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
          useScrollConsume: useScrollConsume,
          pullMaxBound: pullMaxBound,
          onPullBack:
              onPullBack ??
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
        .adaptiveTablet(context)
        .blur(sigma: blur ? kL : null)
        .autoCloseDialog(context, enable: dialogBarrierDismissible);
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
  /// [stackBeforeWidget] 堆在内容下的小部件, 如果有
  /// [stackAfterWidget] 堆在内容上的小部件, 如果有
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
    bool showDragHandle = true,
    //--pull back
    bool enablePullBack = true,
    bool useScrollConsume = true,
    bool maybePop = false /*使用[maybePop]还是[pop]*/,
    double? pullMaxBound /*可以下拉的最大比例, 或者底部需要预留的高度*/,
    void Function(BuildContext context)? onPullBack,
    bool useScroll = false,
    bool useRScroll = false,
    bool animatedSize = false,
    int scrollChildIndex = 1,
    double? height /*固定高度*/,
    double? contentMinHeight,
    double? contentMaxHeight = 0.8,
    bool? blur,
    //--clip--↓
    double? clipRadius,
    double? clipTopRadius = kDefaultBorderRadiusXXX,
    double? clipBottomRadius,
    Widget? stackBeforeWidget,
    Widget? stackAfterWidget,
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
    bool maintainBottomViewPadding = true,
    //--
    TransformWidgetBuilder? contentBuilder /*将内容变换成其它, 建议开启滚动体*/,
    //--
    ChildrenBuilder? scrollContentBuilder,
    /*需要[useRScroll]支持*/
    Listenable? contentUpdateSignal /*内容更新信号, 需要[useRScroll]支持*/,
    String? debugLabel,
  }) {
    blur ??= dialogBlur;

    Widget body;
    children = children.filterNull();

    //debugger();
    if (height != null) {
      if (height < 1) {
        height = screenHeight * height;
      }
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
      //顶部固定的内容
      final fixedChildren = children.subList(0, scrollChildIndex);
      //滚动的内容
      final scrollChildren = children.subList(scrollChildIndex);

      //debugger();
      Widget? scrollBody = useRScroll
          ? scrollChildren.rScroll(
              axis: Axis.vertical,
              physics: enablePullBack ? null : kScrollPhysics,
              childrenBuilder: scrollContentBuilder,
              updateSignal: contentUpdateSignal,
            )
          : scrollChildren.scroll(
              axis: Axis.vertical,
              physics: enablePullBack ? null : kScrollPhysics,
            );
      /*if (debugLabel != null) {
        debugger(when: debugLabel != null);
        scrollBody = scrollBody?.wrapContentHeight(debugLabel: debugLabel);
      }*/
      //约束高度
      scrollBody = scrollBody?.constrainedMax(
        minWidth: null,
        maxWidth: null,
        minHeight: contentMinHeight,
        maxHeight: contentMaxHeight,
      );

      //堆叠小部件
      if (stackAfterWidget != null || stackBeforeWidget != null) {
        //debugger();
        scrollBody =
            (scrollBody
                        ?.position(all: children.isEmpty ? null : 0)
                        .stackOf(
                          stackAfterWidget,
                          before: stackBeforeWidget,
                          fit: StackFit.expand,
                        ) ??
                    stackAfterWidget ??
                    stackBeforeWidget)
                ?.constrainedMax(
                  minWidth: null,
                  maxWidth: null,
                  minHeight: contentMinHeight,
                  maxHeight: contentMaxHeight,
                );
      }

      //内容重构
      if (scrollBody != null && contentBuilder != null) {
        scrollBody = contentBuilder(context, scrollBody);
      }

      body = [
        if (enablePullBack && showDragHandle) buildDragHandle(context),
        ...fixedChildren,
        scrollBody?.expanded(
          enable: height != null || fullScreen /*固定高度时, 滚动布局需要撑满底部*/,
        ),
        bottomWidget,
      ].column()!;
    } else {
      //普通布局, 不使用滚动布局
      body =
          [
                if (enablePullBack && showDragHandle) buildDragHandle(context),
                ...children,
                bottomWidget,
              ]
              .column(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: crossAxisAlignment,
              )!
              .constrainedMax(
                minWidth: null,
                maxWidth: null,
                minHeight: contentMinHeight,
                maxHeight: contentMaxHeight,
              );

      //内容重构
      if (contentBuilder != null) {
        body = contentBuilder(context, body);
      }

      //堆叠小部件
      if (stackAfterWidget != null || stackBeforeWidget != null) {
        body = body
            .position(all: children.isEmpty ? null : 0)
            .stackOf(
              stackAfterWidget,
              before: stackBeforeWidget,
              fit: StackFit.expand,
            );
      }
    }

    final globalTheme = GlobalTheme.of(context);
    final navigator = context.navigatorOf();
    final route = context.modalRoute;
    return body
        .size(height: height)
        .safeArea(
          useSafeArea: useSafeArea,
          maintainBottomViewPadding: maintainBottomViewPadding,
        )
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
          useScrollConsume: useScrollConsume,
          pullMaxBound: pullMaxBound,
          useMaybePop: maybePop,
          onPullBack:
              onPullBack ??
              (context) {
                //debugger();
                if (pullMaxBound == null) {
                  //debugger();
                  /*if (route?.isCurrent == true) {
                    closeDialogIf(context, true, maybePop);
                  } else {*/
                  /*}*/
                  if (maybePop) {
                    navigator.maybePop();
                  } else {
                    navigator.removeRouteIf(route);
                  }
                }
              },
        )
        .matchParent(matchHeight: fullScreen)
        .align(Alignment.bottomCenter)
        .animatedSize(duration: animatedSize ? kDefaultAnimationDuration : null)
        .adaptiveTablet(context)
        .blur(sigma: blur ? kL : null)
        .autoCloseDialog(context, enable: dialogBarrierDismissible);
  }

  /// 构建桌面端右边侧滑全屏高度显示的对话框布局
  @api
  @callPoint
  @desktopLayout
  Widget buildSlideDialog(
    BuildContext context,
    Widget content, {
    bool? blur /*是否启用模糊*/,
    Color? decorationColor,
    Decoration? decoration,
    double? width,
    AlignmentGeometry? alignment /*slide内容对齐的方向*/,
    //--
    FocusOnKeyEventCallback? onKeyEvent,
    dynamic result,
    bool? autoCloseDialog,
    bool? showCloseButton,
  }) {
    final globalTheme = GlobalTheme.of(context);
    blur ??= dialogBlur;
    return content
        .animatedContainer(
          decoration:
              decoration ??
              BoxDecoration(
                color: decorationColor ?? globalTheme.dialogSurfaceBgColor,
                /*boxShadow: [kBoxShadow],*/
              ),
          width: width ?? $ecwBp(),
          height: double.infinity,
        )
        .align(alignment ?? .centerRight)
        .blur(enable: blur == true)
        .autoCloseDialog(
          context,
          onKeyEvent: onKeyEvent,
          result: result,
          tag: classHash(),
          enable: autoCloseDialog ?? dialogBarrierDismissible,
        );
  }

  //endregion ---对话框包裹---

  //region ---小部件---

  Widget buildDialogIconTitle(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    bool enableConfirm = true,
    FutureOr Function()? onConfirm,
    //--
    bool? useConfirmThemeColor,
    Widget? cancelWidget,
    Widget? confirmWidget,
    bool invisibleCancel = false,
    bool invisibleConfirm = false,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return [
      CancelButton(
        useIcon: true,
        widget: cancelWidget,
        onTap: () {
          closeDialogIf(context);
        },
      ).invisible(invisible: invisibleCancel),
      (titleWidget ??
              (title ?? "").text(
                style: globalTheme.textTitleStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ))
          ?.expanded(),
      ConfirmButton(
        useIcon: true,
        useThemeColor: useConfirmThemeColor,
        enable: enableConfirm,
        widget: confirmWidget,
        onTap: () async {
          final result = await onConfirm?.call();
          closeDialogIf(context, result: result);
        },
      ).invisible(invisible: invisibleConfirm),
    ].row()!;
  }

  //endregion ---小部件---

  //region 辅助方法

  /// 关闭一个对话框, 如果[close]为true
  @callPoint
  Future<bool> closeDialogIf(
    BuildContext? context, {
    bool close = true,
    bool maybePop = false,
    Route? route,
    dynamic result,
  }) async {
    if (close && context?.isMounted == true) {
      if (maybePop) {
        return await context?.maybePop(
              rootNavigator: dialogUseRootNavigator,
              result: result ?? popDialogResult,
            ) ??
            false;
      }
      if (route == null) {
        context?.pop(
          rootNavigator: dialogUseRootNavigator,
          result: result ?? popDialogResult,
        );
      } else {
        context?.removeRouteIf(route, rootNavigator: dialogUseRootNavigator);
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
  /// [maintainBottomViewPadding] 是否保留系统默认的底部填充, 否则需要自行填充底部内容
  /// [popLast] pop弹出最后一个路由
  ///
  /// [DialogRoute]
  /// [DialogPageRoute]
  /// [showDialog]
  /// [DialogExtension.showWidgetDialog]
  Future<T?> showWidgetDialog<T>(
    Widget widget, {
    bool? barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool maintainBottomViewPadding = false,
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
      maintainBottomViewPadding: maintainBottomViewPadding,
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
    Color? surfaceTintColor /*= Colors.transparent*/,
    ShapeBorder? shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
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
      return PopupMenuItem<T>(value: e as dynamic, child: e);
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
    final RenderBox overlay =
        Navigator.of(
              this,
              rootNavigator: useRootNavigator,
            ).overlay!.context.findRenderObject()!
            as RenderBox;

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
    Color? surfaceTintColor /*= Colors.transparent*/,
    ShapeBorder? shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
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
    final RenderBox overlay =
        Navigator.of(
              this,
              rootNavigator: useRootNavigator,
            ).overlay!.context.findRenderObject()!
            as RenderBox;

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
  /// - [useSafeArea] 是否使用安全区域
  /// - [maintainBottomViewPadding] 是否保留系统默认的底部填充, 否则需要自行填充底部内容
  /// - [traversalEdgeBehavior] : [ModalRoute.traversalEdgeBehavior]
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
    bool? barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool maintainBottomViewPadding = false,
    bool useBarrierColorAnimate = true,
    bool? useRootNavigator,
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

    type ??= widget.getWidgetTranslationType();
    barrierDismissible ??= widget.getWidgetDialogBarrierDismissible() ?? true;
    barrierColor ??= widget.getWidgetDialogBarrierColor() ?? Colors.black54;
    useRootNavigator ??= widget.getWidgetDialogUseRootNavigator() ?? true;

    CapturedThemes? capturedThemes;
    try {
      final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
      capturedThemes = InheritedTheme.capture(
        from: context,
        to: navigator.context,
      );
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
    }

    return push<T>(
      DialogPageRoute<T>(
        context: this.context,
        builder: (context) {
          return widget;
        },
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        maintainBottomViewPadding: maintainBottomViewPadding,
        useBarrierColorAnimate: useBarrierColorAnimate,
        settings: routeSettings,
        themes: capturedThemes,
        anchorPoint: anchorPoint,
        traversalEdgeBehavior:
            traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
        type: type,
        barrierIgnorePointerType: barrierIgnorePointerType,
      ),
    );

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
