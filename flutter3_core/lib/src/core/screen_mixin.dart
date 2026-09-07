part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// 屏幕布局混入
/// - 支持在page中显示
/// - 支持在dialog中显示
/// - 支持在popup中显示
/// - 支持在overlay中显示
///
/// - [DialogMixin]
///
/// [ScreenMixin]
/// [ScreenStateMixin]
mixin ScreenMixin on Widget implements TranslationTypeImpl {
  //MARK: - ScreenMixin

  /// 屏幕类型
  ///
  /// ```
  /// @override
  /// final ScreenType screenTyp;
  /// ```
  ///
  /// - [buildScaffold]
  /// - [ScreenWidgetEx.showScreenWidget]
  @configProperty
  ScreenType get screenType => isDesktopOrWeb ? .centerDialog : .bottomDialog;

  /// 屏幕背景颜色
  /// - [GlobalTheme.dialogSurfaceBgColor]
  @defInjectMark
  @configProperty
  Color? get screenBackgroundColor => null;

  /// 是否显示取消按钮
  ///  - [buildTitleRow]
  @configProperty
  bool get showCancelButton => true;

  /// 是否显示确认按钮
  ///  - [buildTitleRow]
  @configProperty
  bool get showConfirmButton => false;

  /// 确认图标是否使用主题颜色
  ///
  /// - [buildConfirmButton]
  @configProperty
  bool get confirmIconUseThemeColor => true;

  /// 屏幕内容圆角
  /// - [GlobalTheme.dialogRadius]
  @defInjectMark
  @configProperty
  double? get screenBodyRadius => null;

  /// 屏幕内容阴影高度
  @defInjectMark
  @configProperty
  double? get screenBodyElevation => kDefaultElevation;

  //--api

  /// 弹出当前页面
  @api
  Future popCurrentScreen(
    ScreenStateContext screenContext, {
    dynamic popResult,
  }) async {
    final BuildContext context = screenContext.context;
    if (screenType == .overlay) {
      OverlayEntryControlStateScope.hideOverlay(context);
    } else if (screenType.isDialogType) {
      context.popDialog(
        checkCurrent: null,
        result: popResult ?? screenContext.screenPopResult,
      );
    } else {
      context.pop(
        checkCurrent: null,
        result: popResult ?? screenContext.screenPopResult,
      );
      /*context.popCurrentRoute(
        result: popResult ?? screenContext.screenPopResult,
      );*/
    }
  }

  /// 构建对应[screenType]的脚手架
  @api
  Widget buildScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    return switch (screenType) {
      .overlay => buildOverlayScaffold(screenContext, body),
      .page => throw UnimplementedError(),
      .topDialog => buildTopDialogScaffold(screenContext, body),
      .bottomDialog => buildBottomDialogScaffold(screenContext, body),
      .centerDialog => buildCenterDialogScaffold(screenContext, body),
      .rightSlideDialog => buildRightSlideDialogScaffold(screenContext, body),
      .leftSlideDialog => buildLeftSlideDialogScaffold(screenContext, body),
      .popup => buildPopupScaffold(screenContext, body),
    };
  }

  /// 构建统一的标题整行小部件. 包含所有小部件
  /// - [buildTitleRow]
  ///   - [buildTitle]
  @overridePoint
  Widget? buildTitleRow(
    ScreenStateContext screenContext,
    GlobalTheme globalTheme,
  ) {
    if (screenType == .overlay || screenType == .popup) {
      return [
        buildTitle(screenContext, globalTheme).expanded(),
        if (showCancelButton) buildCancelButton(screenContext, globalTheme),
        if (showConfirmButton) buildConfirmButton(screenContext, globalTheme),
      ].row(gap: globalTheme.x)?.overlayDragTrigger();
    } else if (screenType.isDialogType) {
      if (isMobile && screenType == .bottomDialog) {
        return LeftCenterRightLayout(
          left: showCancelButton
              ? buildCancelButton(screenContext, globalTheme)
              : null,
          center: buildTitle(screenContext, globalTheme),
          right: showConfirmButton
              ? buildConfirmButton(screenContext, globalTheme)
              : null,
        );
      }
      return [
        buildTitle(screenContext, globalTheme).expanded(),
        if (showCancelButton) buildCancelButton(screenContext, globalTheme),
        if (showConfirmButton) buildConfirmButton(screenContext, globalTheme),
      ].row(gap: globalTheme.x);
    }
    return null;
  }

  /// 构建统一的标题小部件, 不包含标题控制按钮
  /// - [buildTitleRow]
  ///   - [buildTitle]
  @overridePoint
  Widget buildTitle(ScreenStateContext context, GlobalTheme globalTheme) {
    return ("$runtimeType" * (isDebug ? 5 : 1))
        .text(style: globalTheme.textTitleStyle)
        .insets(all: globalTheme.x);
  }

  /// 构建取消按钮小部件
  @overridePoint
  Widget buildCancelButton(
    ScreenStateContext screenContext,
    GlobalTheme globalTheme,
  ) {
    final BuildContext context = screenContext.context;
    return InkButton(
      loadCoreAssetSvgPicture(
        Assets.svg.coreClose,
        tintColor: context.isThemeDark
            ? globalTheme.textTitleStyle.color
            : null,
        size: 20,
      ),
      /*enable: enableLeading,
        splashColor: showDecoration ? fillDecorationColor : null,
        minWidth: showDecoration ? null : kInteractiveHeight,
        minHeight: showDecoration ? null : kInteractiveHeight,
        padding: showDecoration ? decorationButtonPadding : buttonPadding,*/
      onTap: () {
        popCurrentScreen(screenContext);
      },
    );
  }

  /// 构建确认按钮小部件
  @overridePoint
  Widget buildConfirmButton(
    ScreenStateContext screenContext,
    GlobalTheme globalTheme,
  ) {
    final BuildContext context = screenContext.context;
    return InkButton(
      loadCoreAssetSvgPicture(
        Assets.svg.coreConfirm,
        tintColor: context.isThemeDark
            ? globalTheme.textTitleStyle.color
            : confirmIconUseThemeColor
            ? globalTheme.accentColor
            : null,
        size: 20,
      ),
      /*enable: enableTrailing,
      splashColor: showDecoration ? fillDecorationColor : null,
      minWidth: showDecoration ? null : kInteractiveHeight,
      minHeight: showDecoration ? null : kInteractiveHeight,
      padding: showDecoration ? decorationButtonPadding : buttonPadding,*/
      onTap: () {
        popCurrentScreen(screenContext);
      },
    );
  }

  //MARK: - DialogType

  double? get dialogMinHeight => null;

  double get dialogMinWidth => minOf($screenMinSize, kDialogMinWidth);

  /// - [screenWidth]
  double get dialogMaxWidth => maxOf(dialogMinWidth, kDesktopDialogMinWidth);

  double? get dialogMaxHeight => maxOf(dialogMinWidth, $screenHeight * 5 / 6);

  /// 构建[ScreenType.centerDialog]的脚手架
  /// 在桌面端, 按[LogicalKeyboardKey.escape]键, 会自动关闭对话框
  /// - [WidgetEx.interceptPopResult] 拦截对话框的返回
  @api
  Widget buildCenterDialogScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      titleWidget,
      if (titleWidget != null) hLine(screenContext.context),
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
    ];

    final minWidth = dialogMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .min)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: dialogMaxWidth,
          minHeight: dialogMinHeight,
          maxHeight: dialogMaxHeight, //最大是正方向
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        )
        .center();
  }

  /// 构建[ScreenType.topDialog]的脚手架
  /// 在桌面端, 按[LogicalKeyboardKey.escape]键, 会自动关闭对话框
  /// - [WidgetEx.interceptPopResult] 拦截对话框的返回
  @api
  Widget buildTopDialogScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
      if (titleWidget != null) hLine(screenContext.context),
      titleWidget,
    ];

    final minWidth = dialogMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .min)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: dialogMaxWidth,
          minHeight: dialogMinHeight,
          maxHeight: dialogMaxHeight,
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        )
        .align(.topCenter);
  }

  /// 构建[ScreenType.bottomDialog]的脚手架
  /// 在桌面端, 按[LogicalKeyboardKey.escape]键, 会自动关闭对话框
  /// - [WidgetEx.interceptPopResult] 拦截对话框的返回
  @api
  Widget buildBottomDialogScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      titleWidget,
      if (titleWidget != null) hLine(screenContext.context),
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
    ];

    final minWidth = dialogMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .min)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: dialogMaxWidth,
          minHeight: dialogMinHeight,
          maxHeight: dialogMaxHeight,
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        )
        .align(.bottomCenter);
  }

  /// 构建[ScreenType.rightSlideDialog]的脚手架
  /// 在桌面端, 按[LogicalKeyboardKey.escape]键, 会自动关闭对话框
  /// - [WidgetEx.interceptPopResult] 拦截对话框的返回
  @api
  Widget buildRightSlideDialogScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      titleWidget,
      if (titleWidget != null) hLine(screenContext.context),
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
    ];

    final minWidth = dialogMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .max)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: dialogMaxWidth,
          minHeight: double.infinity,
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        )
        .align(.centerRight);
  }

  /// 构建[ScreenType.leftSlideDialog]的脚手架
  /// 在桌面端, 按[LogicalKeyboardKey.escape]键, 会自动关闭对话框
  /// - [WidgetEx.interceptPopResult] 拦截对话框的返回
  @api
  Widget buildLeftSlideDialogScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      titleWidget,
      if (titleWidget != null) hLine(screenContext.context),
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
    ];

    final minWidth = dialogMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .max)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: dialogMaxWidth,
          minHeight: double.infinity,
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        )
        .align(.centerLeft);
  }

  //MARK: - OverlayType

  double? get overlayMinHeight => null;

  double get overlayMinWidth => minOf($screenMinSize, kPopupMinWidth);

  /// - [kDesktopPopupWidth]
  double get overlayMaxWidth => maxOf(overlayMinWidth, 300);

  double? get overlayMaxHeight => maxOf(overlayMinWidth, $screenHeight * 5 / 6);

  /// 构建[ScreenType.overlay]的脚手架
  @api
  Widget buildOverlayScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      titleWidget,
      if (titleWidget != null) hLine(screenContext.context),
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
    ];

    final minWidth = overlayMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .min)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: overlayMaxWidth,
          minHeight: overlayMinHeight,
          maxHeight: overlayMaxHeight, //最大是正方向
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        );
  }

  //MARK: - PopupType

  /// 构建[ScreenType.popup]的脚手架
  @api
  Widget buildPopupScaffold(
    ScreenStateContext screenContext,
    ScreenBodyWidget body,
  ) {
    assert(screenContext is BuildContext || screenContext is State);
    assert(body is Widget || body is Iterable<Widget?>);
    final globalTheme = GlobalTheme.of(screenContext.context);
    final titleWidget = buildTitleRow(screenContext, globalTheme);

    final children = [
      titleWidget,
      if (titleWidget != null) hLine(screenContext.context),
      if (body is Widget) body,
      if (body is Iterable<Widget?>) ...body,
    ];
    final minWidth = overlayMinWidth;
    final backgroundColor =
        screenBackgroundColor ?? globalTheme.dialogSurfaceBgColor;
    return children
        .column(mainAxisSize: .min)!
        .constrainedMin(
          minWidth: minWidth,
          maxWidth: overlayMaxWidth,
          minHeight: overlayMinHeight,
          maxHeight: overlayMaxHeight, //最大是正方向
        )
        .material(
          color: backgroundColor,
          radius: screenBodyRadius ?? globalTheme.dialogRadius,
          elevation: screenBodyElevation,
          enableElevation: backgroundColor != Colors.transparent,
        );
  }

  //MARK: - TranslationTypeImpl

  /// [Dialog]对话框外点击是否关闭
  @override
  bool get dialogBarrierDismissible => true;

  @override
  Color? get dialogBarrierColor => null;

  @override
  bool get dialogUseRootNavigator => true;

  /// 屏幕动画过渡类型
  /// 对话框路径过度动画
  @override
  TranslationType get translationType {
    if (screenType == .topDialog) {
      return .translationTopToBottom;
    }
    if (screenType == .bottomDialog) {
      return .translationFade;
    }
    if (screenType == .centerDialog) {
      return .scaleFade;
    }
    if (screenType == .rightSlideDialog) {
      return .slide;
    }
    if (screenType == .leftSlideDialog) {
      return .slideLeftToRight;
    }

    final type = runtimeType.toString().toLowerCase();
    //debugger();
    if (type.isScreenName) {
      return .translation;
    }
    if (type.contains("desktop")) {
      return .scaleFade;
    }
    if (type.contains("bottom")) {
      return .translationFade;
    }
    /*if (isDesktopOrWeb) {
      //桌面从右到左滑动
      if (adaptiveDialogDesktopSlideStyle == null && type.contains("slide")) {
        return .slide;
      }
      if (adaptiveDialogDesktopSlideStyle != null &&
          adaptiveDialogDesktopSlideStyle == true) {
        return .slide;
      }
    }*/
    return isDesktopOrWeb ? .scaleFade : .translationFade;
  }

  @override
  Alignment? get preferredFollowerAlignment => .bottomCenter;
}

/// - [Widget] or [Iterable<Widget?>]
/// - [Iterable]
/// - [List]
typedef ScreenBodyWidget = Object;

/// - [State] or [BuildContext]
typedef ScreenStateContext = Object;

/// [ScreenMixin]
/// [ScreenStateMixin]
mixin ScreenStateMixin<T extends StatefulWidget> on State<T> {
  /// 获取弹出结果
  dynamic get screenPopResult => null;
}

extension ScreenStateContextEx on ScreenStateContext {
  //MARK: - ScreenStateMixin

  /// - [ScreenStateMixin.screenPopResult]
  dynamic get screenPopResult => this is ScreenStateMixin
      ? (this as ScreenStateMixin).screenPopResult
      : null;

  //MARK: - get

  BuildContext get context =>
      this is State ? (this as State).context : this as BuildContext;

  /// 尝试更新界面
  @api
  void tryUpdateState() {
    final state = this;
    if (state is State) {
      state.updateState();
    } else {
      //context.tryUpdateState();
    }
  }
}

/// 屏幕类型
/// 当前[ScreenMixin]小部件显示在什么容器中
///
/// - [ScreenWidgetEx.showScreenWidget]
enum ScreenType {
  /// 标准的页面路由[MaterialPageRoute]
  /// - [NavigatorEx.pushWidget]
  page,

  /// 顶部样式的对话框路由[DialogRoute]
  /// - [DialogExtension.showWidgetDialog]
  topDialog,

  /// 底部样式的对话框路由[DialogRoute]
  /// - [DialogExtension.showWidgetDialog]
  bottomDialog,

  /// 居中样式的对话框路由[DialogRoute]
  /// - [DialogExtension.showWidgetDialog]
  centerDialog,

  /// 右侧滑动样式的对话框路由[DialogRoute]
  /// - [DialogExtension.showWidgetDialog]
  rightSlideDialog,

  /// 左侧滑动样式的对话框路由[DialogRoute]
  /// - [DialogExtension.showWidgetDialog]
  leftSlideDialog,

  /// 弹窗路由[PopupRoute]
  /// - [PopupEx.showPopupDialog]
  popup,

  /// 浮窗
  /// - [OverlayEx.showOverlay]
  overlay;

  /// 是否是对话框类型
  bool get isDialogType =>
      this == .topDialog ||
      this == .bottomDialog ||
      this == .centerDialog ||
      this == .rightSlideDialog ||
      this == .leftSlideDialog;
}

extension ScreenWidgetEx on Widget {
  /// 获取[Widget]的指定的过渡类型对象
  ScreenMixin? getWidgetScreenMixin({int depth = 3}) {
    if (depth <= 0) {
      return null;
    }
    final widget = this;
    if (widget is ScreenMixin) {
      return widget;
    } else if (widget is SingleChildRenderObjectWidget) {
      final child = widget.child;
      if (child != null) {
        return child.getWidgetScreenMixin(depth: depth - 1);
      }
    } else {
      try {
        final child = (widget as dynamic).child;
        if (child is Widget) {
          return child.getWidgetScreenMixin(depth: depth - 1);
        }
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
      }
    }
    return null;
  }

  ScreenType? getWidgetScreenType({int depth = 3}) {
    if (depth <= 0) {
      return null;
    }
    final widget = this;
    /*try {
      return (this as dynamic).screenType;
    } catch (e) {
      //no op
    }*/
    if (widget is ScreenMixin) {
      return widget.screenType;
    } else if (widget is SingleChildRenderObjectWidget) {
      final child = widget.child;
      if (child != null) {
        return child.getWidgetScreenType(depth: depth - 1);
      }
    } else {
      try {
        final child = (widget as dynamic).child;
        if (child is Widget) {
          return child.getWidgetScreenType(depth: depth - 1);
        }
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
      }
    }
    return null;
  }

  /// 根据[screenType]类型, 自动显示界面
  @api
  Future showScreenWidget(
    BuildContext? context, {
    bool? useRootNavigator,
    //MARK: - dialog
    bool? barrierDismissible,
    Color? barrierColor,
    bool useBarrierColorAnimate = true,
    //MARK: - popup
    GlobalKey? popupAnchorKey,
    Rect? popupAnchorRect,
    @defInjectMark Color? popupBackgroundColor,
    Alignment? popupPreferredFollowerAlignment,
    bool popupShowArrow = false /*是否显示箭头*/,
    @defInjectMark Color? popupArrowColor /*箭头颜色*/,
    @defInjectMark AxisDirection? popupArrowDirection /*箭头方向*/,
    //MARK: - overlay
    bool? useRootOverlay,
    @defInjectMark Offset? edgeOffset,
    //--
    BuildContext? anchorChild,
    @defInjectMark Alignment? targetAnchor,
    @defInjectMark Alignment? followerAnchor,
    Offset? alignmentOffset,
  }) async {
    final screenMixin = getWidgetScreenMixin();
    final screenType = screenMixin?.screenType;
    //debugger();
    if (screenType == null) {
      return null;
    }
    final body = this;
    dynamic future;
    if (screenType == .popup) {
      future = context?.showPopupDialog(
        body,
        rootNavigator: useRootNavigator == true,
        anchorKey: popupAnchorKey,
        anchorRect: popupAnchorRect,
        anchorChild: anchorChild ?? context,
        targetAnchor: targetAnchor ?? .bottomLeft,
        preferredFollowerAlignment:
            popupPreferredFollowerAlignment ?? .topRight,
        followerAnchor: followerAnchor,
        alignmentOffset: alignmentOffset ?? .zero,
        backgroundColor: popupBackgroundColor,
        showArrow: popupShowArrow,
        arrowColor: popupArrowColor,
        arrowDirection: popupArrowDirection,
        contentPadding: .zero,
      );
    } else if (screenType == .overlay) {
      future = context?.showOverlay(
        (ctx, entry) {
          return body;
        },
        tag: screenMixin.runtimeType.toString(),
        rootOverlay: useRootOverlay == true,
        edgeOffset: edgeOffset,
        anchorChild: anchorChild ?? context,
        targetAnchor: targetAnchor,
        followerAnchor: followerAnchor,
        alignmentOffset: alignmentOffset,
      );
    } else if (screenType.isDialogType) {
      future = context?.showWidgetDialog(
        body,
        useRootNavigator: useRootNavigator,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useBarrierColorAnimate: useBarrierColorAnimate,
      );
    } else {
      //ScreenType.page
      future = context?.pushWidget(body);
    }
    final result = await future;
    assert(() {
      l.i("[${body.classHash()}]返回[${result.runtimeType}]->$result");
      return true;
    }());
    return future;
  }
}
