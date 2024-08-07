part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 快速创建一个具有[Scaffold]脚手架和[RScrollView]滚动的页面
/// [RScrollView]
/// [AbsScrollPage]
/// [RScrollPage] 刷新,加载更多
/// [RStatusScrollPage] 状态切换
///
/// [buildScaffold]
mixin AbsScrollPage {
  /// 直接写一个[build]方法, 也可以继承[State.build]方法
  /// @override
  @overridePoint
  @initialize
  Widget build(BuildContext context) {
    return buildScaffold(context);
  }

  //region Page

  /// 构建脚手架[Scaffold]
  @api
  @entryPoint
  Widget buildScaffold(
    BuildContext context, {
    WidgetList? children,
    bool? resizeToAvoidBottomInset,
    Color? backgroundColor,
    PreferredSizeWidget? appBar,
    Widget? body,
  }) {
    //debugger();
    return Scaffold(
      appBar: appBar ?? buildAppBar(context),
      backgroundColor: backgroundColor ?? getBackgroundColor(context),
      resizeToAvoidBottomInset:
          resizeToAvoidBottomInset ?? getResizeToAvoidBottomInset(context),
      body: body ??
          (this is RebuildBodyMixin
              ? rebuild((this as RebuildBodyMixin).bodyUpdateSignal,
                  (context, value) => buildBody(context, children))
              : buildBody(context, children)),
    );
  }

  /// 获取页面背景颜色
  @property
  Color? getBackgroundColor(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //final globalConfig = GlobalConfig.of(context);
    return globalTheme.whiteBgColor;
  }

  /// 默认不适配底部键盘
  bool getResizeToAvoidBottomInset(BuildContext context) => false;

  //endregion Page

  //region Body

  /// 构建滚动内容
  /// [buildScaffold]->[buildBody]->[buildScrollBody]
  /// [RScrollPage.pageRScrollView]
  @property
  Widget buildBody(BuildContext context, WidgetList? children) {
    children ??= buildScrollBody(context);
    if (this is RScrollPage) {
      return (this as RScrollPage).pageRScrollView(children: children);
    }
    return RScrollView(
      /*physics: null,
      scrollBehavior: null,*/
      children: children ?? [],
    );
  }

  /// 如果没有指定[children]时, 则调用此方法构建滚动内容
  @property
  WidgetList? buildScrollBody(BuildContext context) {
    return null;
  }

  //endregion Body

  //region AppBar

  /// 获取页面标题
  @property
  String? getTitle(BuildContext context) {
    return runtimeType.toString();
  }

  /// 构建标题栏
  @property
  Widget? buildTitle(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return getTitle(context)?.text(
        style: globalConfig.globalTheme.textTitleStyle.copyWith(
      color: globalConfig.globalTheme.appBarForegroundColor,
    ));
  }

  /// 是否是居中标题
  @property
  bool? isCenterTitle(BuildContext context) => null;

  /// 构建标题栏上的返回按钮
  @property
  Widget? buildAppBarLeading(BuildContext context) => null;

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
  @property
  Color? getAppBarBackgroundColor(BuildContext context) => null;

  /// 构建渐变背景
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
  @property
  PreferredSizeWidget? buildAppBar(
    BuildContext context, {
    Widget? title,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool? centerTitle,
    bool? automaticallyImplyLeading,
    Widget? leading,
    Widget? trailing,
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
      leading: leading ?? buildAppBarLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title ?? buildTitle(context),
      centerTitle: centerTitle ?? isCenterTitle(context),
      actions: actions ?? buildAppBarActions(context),
      bottom: buildAppBarBottom(context),
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
mixin RebuildBodyMixin {
  /// [buildBody]更新的信号
  final UpdateSignalNotifier bodyUpdateSignal = UpdateSignalNotifier(null);

  /// 重建[buildBody]
  @updateMark
  void updateBody() {
    bodyUpdateSignal.notify();
  }
}
