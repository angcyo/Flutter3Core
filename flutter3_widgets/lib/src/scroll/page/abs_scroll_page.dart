part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 快速创建一个具有[Scaffold]脚手架和[RScrollView]滚动的页面
///
/// 重写[getTitle]设置标题, 如果需要的话
/// 一般情况下重写[buildScrollBody]构建滚动体, 即可
///
/// [RScrollView]
/// [AbsScrollPage] 基础[RScrollView]页面
/// [RScrollPage] 刷新,加载更多. 在[buildBody]中兼容[RScrollPage].
/// [RStatusScrollPage] 状态切换
///
/// [RebuildBodyMixin].[buildScaffold]
///
/// [build]->[buildScaffold]->[buildBody]->[buildScrollBody]
/// [buildScrollBody] 重写此方法实现滚动内容构建
/// [buildAppBar]     重写此方法实现标题栏构建
mixin AbsScrollPage {
  /// 直接写一个[build]方法, 也可以继承[State.build]方法
  /// @override
  ///
  /// [buildScaffold]
  /// [buildAppBar]
  /// [buildBody]
  @overridePoint
  @initialize
  Widget build(BuildContext context) {
    return buildScaffold(context);
  }

  //region Page

  /// 构建脚手架[Scaffold]
  /// [buildAppBar]
  /// [buildBody]
  @api
  @entryPoint
  Widget buildScaffold(
    BuildContext context, {
    WidgetList? children,
    bool? resizeToAvoidBottomInset,
    Color? backgroundColor,
    PreferredSizeWidget? appBar,
    Widget? body,
    //--
    bool useSafeArea = true,
    bool safeAreaTop = false,
    bool safeAreaBottom = true,
  }) {
    //debugger();
    final useSliverAppBar = this.useSliverAppBar(context) == true;
    return Scaffold(
      appBar: useSliverAppBar
          ? null
          : enableAppBar(context) == true
              ? (appBar ?? buildAppBar(context))
              : null,
      backgroundColor: backgroundColor ?? getBackgroundColor(context),
      resizeToAvoidBottomInset:
          resizeToAvoidBottomInset ?? getResizeToAvoidBottomInset(context),
      body: (body ??
              (this is RebuildBodyMixin
                  ? rebuild((this as RebuildBodyMixin).bodyUpdateSignal,
                      (context, value) => buildBody(context, children))
                  : buildBody(context, children)))
          .safeArea(
        useSafeArea: useSafeArea,
        top: safeAreaTop,
        bottom: safeAreaBottom,
        maintainBottomViewPadding: safeAreaBottom,
      ),
    );
  }

  /// 获取页面背景颜色
  @property
  Color? getBackgroundColor(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //final globalConfig = GlobalConfig.of(context);
    return globalTheme.surfaceBgColor;
  }

  /// 默认不适配底部键盘
  bool getResizeToAvoidBottomInset(BuildContext context) => false;

  //endregion Page

  //region Body

  /// [buildBody]->[RScrollView]的[RScrollView.children]更新信号
  /// [createUpdateSignal]
  ///
  /// [RebuildScrollChildrenMixin]
  ///
  UpdateValueNotifier? get pageScrollChildrenUpdateSignal =>
      this is RebuildScrollChildrenMixin
          ? (this as RebuildScrollChildrenMixin).scrollChildrenUpdateSignal
          : null;

  /// 构建滚动内容
  /// [build]->[buildScaffold]->[buildBody]->[buildScrollBody]
  /// [RScrollPage.pageRScrollView]
  ///
  /// [RebuildBodyMixin]
  ///
  /// # 底部按钮示例
  /// ```
  /// @override
  /// Widget buildBody(BuildContext context, WidgetList? children) {
  ///   return [
  ///     super.buildBody(context, children).expanded(),
  ///     GradientButton(
  ///       onTap: () {},
  ///       child: "xx".text(),
  ///     ).matchParentWidth().paddingAll(kX),
  ///   ].column()!;
  /// }
  /// ```
  ///
  @property
  @overridePoint
  Widget buildBody(BuildContext context, WidgetList? children) {
    //构建子节点
    WidgetList? buildChildren() {
      WidgetList? result = children ?? buildScrollBody(context);
      final useSliverAppBar = this.useSliverAppBar(context) == true;
      if (useSliverAppBar) {
        result = [
          buildAppBar(context, useSliverAppBar: true),
          ...?result,
        ].filterNull();
      }
      return result;
    }

    if (this is RScrollPage) {
      return (this as RScrollPage).pageRScrollView(children: buildChildren());
    }
    return RScrollView(
      /*physics: null,
      scrollBehavior: null,*/
      /*children: children,*/
      updateSignal: pageScrollChildrenUpdateSignal,
      childrenBuilder: (context) => buildChildren(),
    );
  }

  /// 如果没有指定[children]时, 则调用此方法构建滚动内容
  /// [buildBody]
  /// [pageScrollChildrenUpdateSignal]
  @property
  @overridePoint
  WidgetList? buildScrollBody(BuildContext context) {
    return null;
  }

  /// [buildBody]->[RScrollView]重构子节点更新信号
  /// 需要重写[pageScrollChildrenUpdateSignal]
  @updateSignalMark
  void updatePageScrollChildren() {
    rebuildPageScrollChildren();
  }

  @updateSignalMark
  void rebuildPageScrollChildren() {
    assert(() {
      if (pageScrollChildrenUpdateSignal == null) {
        l.w("请使用[RebuildScrollChildrenMixin]安装");
      }
      return true;
    }());
    pageScrollChildrenUpdateSignal?.update();
  }

  //endregion Body

  //region AppBar

  /// 标题更新信号
  UpdateValueNotifier? get pageTitleUpdateSignal =>
      this is RebuildPageTitleMixin
          ? (this as RebuildPageTitleMixin).titleUpdateSignal
          : null;

  /// 获取页面标题
  @property
  String? getTitle(BuildContext context) {
    if (this is State) {
      return (this as State).widget.runtimeType.toString();
    }
    return runtimeType.toString();
  }

  /// 获取标题文本的对齐方式
  @property
  TextAlign? getTitleTextAlign(BuildContext context) => ui.TextAlign.center;

  /// 获取页面标题, 支持富文本
  /// [TextSpan]
  @property
  TextSpan? getTitleTextSpan(BuildContext context) => null;

  /// 构建标题栏
  /// [buildAppBar]
  @property
  @CallFrom("buildAppBar")
  Widget? buildTitle(BuildContext context) {
    //--
    Widget? buildTitleInner() {
      final globalConfig = GlobalConfig.of(context);
      final textStyle = globalConfig.globalTheme.textTitleStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: getAppBarForegroundColor(context) ??
            globalConfig.globalTheme.appBarForegroundColor,
      );
      final titleTextSpan = getTitleTextSpan(context);
      final titleWidget = titleTextSpan != null
          ? "".text(
              textSpan: titleTextSpan,
              style: textStyle,
              textAlign: getTitleTextAlign(context),
            )
          : getTitle(context)?.text(
              style: textStyle,
              textAlign: getTitleTextAlign(context),
            );
      return titleWidget;
    }

    //--
    final signal = pageTitleUpdateSignal;
    if (signal == null) {
      return buildTitleInner();
    } else {
      return rebuild(signal, (context, value) => buildTitleInner());
    }
  }

  /// [buildBody]->[RScrollView]重构子节点更新信号
  /// 需要重写[pageScrollChildrenUpdateSignal]
  @updateSignalMark
  void updatePageTitle() {
    rebuildPageTitle();
  }

  @updateSignalMark
  void rebuildPageTitle() {
    assert(() {
      if (pageTitleUpdateSignal == null) {
        l.w("请使用[RebuildPageTitleMixin]安装");
      }
      return true;
    }());
    pageTitleUpdateSignal?.update();
  }

  /// 是否是居中标题
  @property
  bool? isCenterTitle(BuildContext context) => null;

  /// 是否激活标题栏
  @property
  bool? enableAppBar(BuildContext context) => true;

  /// 是否使用[SliverAppBar], 否则使用[buildAppBar]
  @property
  bool? useSliverAppBar(BuildContext context) => null;

  /// 构建标题栏上的返回按钮,
  /// 重写之后, 需要手动处理页面的[pop]操作
  @property
  Widget? buildAppBarLeading(BuildContext context) => null;

  /// 只在可以返回的情况下, 才会调用
  /// 重写之后, 需要手动处理页面的[pop]操作
  ///
  /// ```
  ///  @override
  ///  Widget? buildAppBarDismissal(BuildContext context) {
  ///    return ydResSvgWidget(ydCoreSvgRes.back, size: 18)?.icon(() {
  ///      context.maybePop();
  ///    });
  ///  }
  /// ```
  ///
  @property
  Widget? buildAppBarDismissal(BuildContext context) => null;

  /// 构建标题栏上的动作按钮
  @property
  List<Widget>? buildAppBarActions(BuildContext context) => null;

  /// 获取标题栏高度
  @property
  double? getAppBarElevation(BuildContext context) => null;

  /// 获取标题栏滚动时的阴影高度
  @property
  double? getAppBarScrolledUnderElevation(BuildContext context) =>
      getAppBarElevation(context);

  /// 获取标题栏阴影颜色
  @property
  Color? getAppBarShadowColor(BuildContext context) => null;

  /// 获取标题栏前景色
  @property
  Color? getAppBarForegroundColor(BuildContext context) => null;

  /// 获取标题栏背景色
  /// 要实现渐变效果请使用[buildAppBarFlexibleSpace]
  @property
  Color? getAppBarBackgroundColor(BuildContext context) => null;

  /// 构建渐变背景
  /// [FlexibleSpaceBar]
  @property
  Widget? buildAppBarFlexibleSpace(BuildContext context) {
    /*final globalTheme = GlobalTheme.of(context);
    return linearGradientWidget(
        listOf(globalTheme.themeWhiteColor));*/
    /*return listOf(globalTheme.primaryColor, globalTheme.primaryColorDark),*/
    return null;
  }

  /// 构建顶部导航[AppBar]
  /// [AppBarBuilderFn]
  ///
  /// [GlobalConfig.appBarBuilder]
  ///
  @property
  PreferredSizeWidget? buildAppBar(
    BuildContext context, {
    bool? useSliverAppBar,
    Widget? title,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool? centerTitle,
    bool? automaticallyImplyLeading,
    Widget? leading,
    Widget? dismissal,
    Widget? trailing,
    PreferredSizeWidget? bottom,
    List<Widget>? actions,
  }) {
    final globalConfig = GlobalConfig.of(context);
    //debugger();
    if (actions == null) {
      if (trailing != null) {
        actions = [trailing];
      }
    }
    return globalConfig.appBarBuilder(
      context,
      this,
      useSliverAppBar: useSliverAppBar ?? this.useSliverAppBar(context),
      leading: leading ?? buildAppBarLeading(context),
      dismissal: dismissal ?? buildAppBarDismissal(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title ?? buildTitle(context),
      centerTitle: centerTitle ?? isCenterTitle(context),
      actions: actions ?? buildAppBarActions(context),
      bottom: bottom ?? buildAppBarBottom(context),
      elevation: elevation ?? getAppBarElevation(context),
      scrolledUnderElevation:
          getAppBarScrolledUnderElevation(context) ?? elevation,
      foregroundColor: foregroundColor ?? getAppBarForegroundColor(context),
      backgroundColor: backgroundColor ?? getAppBarBackgroundColor(context),
      //阴影高度
      shadowColor: getAppBarShadowColor(context),
      flexibleSpace: buildAppBarFlexibleSpace(context), //渐变背景
    );
  }

  /// 构建顶部导航[AppBar]
  @property
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return null;
  }

//endregion AppBar
}

/// 更新body混入, 配合[AbsScrollPage]使用
/// [AbsScrollPage.buildScaffold]
///
/// 使用[updateBody]方法更新body
///
mixin RebuildBodyMixin {
  /// [buildBody]更新的信号
  final bodyUpdateSignal = UpdateSignalNotifier<Object?>(null);

  /// 重建[buildBody]
  @updateMark
  void updateBody() {
    rebuildBody();
  }

  @updateMark
  void rebuildBody() {
    bodyUpdateSignal.notify();
  }
}

/// 更新body混入, 配合[AbsScrollPage]使用
/// [AbsScrollPage.buildScaffold]
///
/// 使用[updateScrollChildren]方法更新滚动体
///
mixin RebuildScrollChildrenMixin {
  /// [buildBody]更新的信号
  final scrollChildrenUpdateSignal = UpdateSignalNotifier<Object?>(null);

  /// 重建[RScrollView]的滚动体内容
  @updateMark
  void updateScrollChildren() {
    rebuildScrollChildren();
  }

  @updateMark
  void rebuildScrollChildren() {
    scrollChildrenUpdateSignal.notify();
  }
}

mixin RebuildPageTitleMixin {
  /// 标题更新的信号
  final titleUpdateSignal = UpdateSignalNotifier<Object?>(null);

  /// 重建[RScrollView]的滚动体内容
  @updateMark
  void updateTitle() {
    rebuildTitle();
  }

  @updateMark
  void rebuildTitle() {
    titleUpdateSignal.notify();
  }
}
