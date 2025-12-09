part of '../../flutter3_widgets.dart';

///
/// 情感图状态控制
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [WidgetBuilder]
typedef WidgetStateBuilder =
    Widget Function(
      BuildContext context,
      WidgetBuildState widgetState,
      dynamic stateData,
    );

/// 创建一个字符串
typedef GenerateString = String? Function(BuildContext context);

/// 使用一个[Widget]包裹住[child]
typedef WidgetWrapBuilder = Widget Function(BuildContext context, Widget child);

/// 请求改变状态,
/// 返回true表示拦截改变.
/// 返回false表示允许改变, 并且会更新当前的状态
typedef RequestChangeStateFn =
    bool Function(
      BuildContext context,
      WidgetBuildState oldWidgetState,
      WidgetBuildState newWidgetState,
    );

enum WidgetBuildState {
  /// 预加载状态, 会显示加载界面, 但是不会触发加载回调
  preLoading,

  /// 加载中状态
  loading,

  /// 正常数据状态
  none,

  /// 空数据状态
  empty,

  /// 错误状态
  error,

  /// 自定义状态
  custom;

  /*const WidgetState([this.data]);

  final dynamic data;*/

  /// 是否是加载状态
  bool get isLoading =>
      this == WidgetBuildState.preLoading || this == WidgetBuildState.loading;

  /// 是否是内容状态
  bool get isNoneState => this == WidgetBuildState.none;
}

/*mixin WidgetStateMixin {
  /// 当前的状态
  final ValueNotifier<WidgetState> widgetStateValue =
      ValueNotifier(WidgetState.none);

  /// 当前状态的附加信息
  dynamic stateData;

  /// 当前是否处于情感图状态, 非内容状态
  bool get isInWidgetState => !widgetStateValue.value.isNoneState;

  /// 调用此方法更新状态
  /// 通过监听[widgetStateValue]的变化, 来更新UI
  @callPoint
  void updateWidgetState(State? state, WidgetState widgetState,
      [dynamic stateData]) {
    var old = widgetStateValue.value;
    if (old == widgetState) {
      return;
    }
    this.stateData = stateData;
    widgetStateValue.value = widgetState;
    state?.updateState();
  }
}*/

/// 为child提供一个初始化的[WidgetBuildState]状态
class WidgetStateScope extends InheritedWidget {
  final WidgetBuildState? widgetState;

  const WidgetStateScope({
    super.key,
    required super.child,
    required this.widgetState,
  });

  /// 获取一个初始化的[WidgetBuildState]状态
  static WidgetBuildState? of(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<WidgetStateScope>()
        ?.widgetState;
  }

  @override
  bool updateShouldNotify(covariant WidgetStateScope oldWidget) =>
      widgetState != oldWidget.widgetState;
}

extension WidgetStateEx on Widget {
  /// 为[child]提供一个初始化的[WidgetBuildState]状态
  Widget widgetState({WidgetBuildState? widgetState, bool? loading}) {
    //debugger();
    if (widgetState == null && loading != null) {
      widgetState = loading
          ? WidgetBuildState.loading
          : WidgetBuildState.preLoading;
    }
    return WidgetStateScope(widgetState: widgetState, child: this);
  }
}

/// [WidgetBuildState]状态控制
class WidgetStateBuildWidget extends StatefulWidget {
  /// 当前的状态数据
  /// 不同状态下,携带的数据
  final dynamic stateData;

  /// 当前的状态
  final WidgetBuildState widgetState;

  /// 无数据/无更多数据时, 显示的字符串
  final GenerateString? noDataStringGenerate;

  /// 加载失败时, 显示的字符串
  final GenerateString? loadErrorStringGenerate;

  /// 请求改变状态, 拦截器
  final RequestChangeStateFn? requestChangeStateFn;

  /// 构建不同状态的Widget
  final WidgetStateBuilder? buildWidgetStateWidget;

  //---

  /// 细分的[WidgetBuildState.loading]状态
  final WidgetStateBuilder? buildLoadingWidgetState;

  /// 细分的[WidgetBuildState.empty]状态
  final WidgetStateBuilder? buildEmptyWidgetStateWidget;

  /// 细分的[WidgetBuildState.error]状态
  final WidgetStateBuilder? buildErrorWidgetStateWidget;

  const WidgetStateBuildWidget({
    super.key,
    required this.widgetState,
    this.stateData,
    this.noDataStringGenerate,
    this.loadErrorStringGenerate,
    this.requestChangeStateFn,
    this.buildWidgetStateWidget,
    this.buildLoadingWidgetState,
    this.buildEmptyWidgetStateWidget,
    this.buildErrorWidgetStateWidget,
  });

  @override
  State<WidgetStateBuildWidget> createState() => WidgetStateBuildWidgetState();
}

class WidgetStateBuildWidgetState extends State<WidgetStateBuildWidget>
    with StateWidgetBuildMixin {
  /// 更新后的状态
  WidgetBuildState? _updateState;

  WidgetBuildState get _buildState => _updateState ?? widget.widgetState;

  /// [WidgetBuildState.loading]状态
  @override
  Widget defBuildLoadingWidget(
    BuildContext context, [
    dynamic data,
    double? progressValue,
    Color? color,
  ]) {
    return (widget.buildLoadingWidgetState ?? widget.buildWidgetStateWidget)
            ?.call(context, _buildState, widget.stateData) ??
        super.defBuildLoadingWidget(
          context,
          widget.stateData,
          progressValue,
          color,
        );
  }

  /// [WidgetBuildState.empty]状态
  @override
  Widget defBuildEmptyWidget(BuildContext context, [dynamic data]) {
    return (widget.buildEmptyWidgetStateWidget ?? widget.buildWidgetStateWidget)
            ?.call(context, _buildState, widget.stateData) ??
        super.defBuildEmptyWidget(context, widget.stateData);
  }

  /// [WidgetBuildState.error]状态
  @override
  Widget defBuildErrorWidget(BuildContext context, [dynamic error]) {
    return (widget.buildErrorWidgetStateWidget ?? widget.buildWidgetStateWidget)
            ?.call(context, _buildState, widget.stateData) ??
        super.defBuildErrorWidget(context, error);
  }

  /// 其他默认状态
  Widget _buildDefaultWidget(BuildContext context) {
    var result = widget.buildWidgetStateWidget?.call(
      context,
      _buildState,
      widget.stateData,
    );
    if (result != null) {
      return result;
    }
    return const Placeholder();
  }

  @callPoint
  void updateWidgetState(WidgetBuildState state) {
    _updateState = state;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    return buildStateWidget(context, _buildState, widget.stateData) ??
        _buildDefaultWidget(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant WidgetStateBuildWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState = null;
  }
}

/// 情感图[WidgetBuildState]状态控制
class AdapterStateWidget extends WidgetStateBuildWidget {
  const AdapterStateWidget({
    super.key,
    required super.widgetState,
    super.stateData,
    super.noDataStringGenerate,
    super.loadErrorStringGenerate,
    super.requestChangeStateFn,
  });

  @override
  AdapterStateWidgetState createState() => AdapterStateWidgetState();
}

class AdapterStateWidgetState extends WidgetStateBuildWidgetState {
  /// [WidgetBuildState.loading]状态
  @override
  Widget defBuildLoadingWidget(
    BuildContext context, [
    dynamic data,
    double? progressValue,
    Color? color,
  ]) {
    return GlobalConfig.of(
      context,
    ).loadingIndicatorBuilder(context, data, progressValue, color);
  }

  /// [WidgetBuildState.empty]状态
  /// @override
  @override
  Widget defBuildEmptyWidget(BuildContext context, [dynamic data]) {
    final globalTheme = GlobalTheme.of(context);
    //def 360*360
    const size = 160.0;
    Widget result = loadAssetImageWidget(
      libAssetsStateNoDataKey,
      package: 'flutter3_basics',
    )!.size(width: size, height: size);

    final stateData =
        widget.stateData ??
        widget.noDataStringGenerate?.call(context) ??
        LibRes.of(context).libAdapterNoData;
    if (stateData != null) {
      result = result.columnOf(
        "$stateData"
            .text(
              textAlign: TextAlign.center,
              style: globalTheme.textSubTitleStyle,
            )
            .padding(globalTheme.xh),
      );
    }
    return result.align(Alignment.center).matchParent();
  }

  /// [WidgetBuildState.error]状态
  @override
  Widget defBuildErrorWidget(BuildContext context, [dynamic error]) {
    final globalTheme = GlobalTheme.of(context);
    //def 360*360
    const size = 160.0;
    Widget result = loadAssetImageWidget(
      libAssetsStateLoadErrorKey,
      package: 'flutter3_basics',
    )!.size(width: size, height: size);

    final stateData =
        widget.stateData ??
        widget.loadErrorStringGenerate?.call(context) ??
        LibRes.of(context).libAdapterLoadMoreError;

    if (stateData != null) {
      result = result.columnOf(
        "$stateData"
            .text(textAlign: TextAlign.center, style: globalTheme.textBodyStyle)
            .padding(globalTheme.xh),
      );
    }
    return result.align(Alignment.center).matchParent().click(() {
      //点击重试
      if (widget.requestChangeStateFn?.call(
            context,
            _buildState,
            WidgetBuildState.loading,
          ) ==
          false) {
        _updateState = WidgetBuildState.loading;
        updateState();
      }
    });
  }
}

/// 加载更多[WidgetBuildState]状态控制
class LoadMoreStateWidget extends WidgetStateBuildWidget {
  const LoadMoreStateWidget({
    super.key,
    required super.widgetState,
    super.stateData,
    super.noDataStringGenerate,
    super.loadErrorStringGenerate,
    super.requestChangeStateFn,
  });

  @override
  LoadMoreStateWidgetState createState() => LoadMoreStateWidgetState();
}

class LoadMoreStateWidgetState extends WidgetStateBuildWidgetState {
  @override
  Widget _buildDefaultWidget(BuildContext context) {
    return defBuildLoadingWidget(context);
  }

  /// [WidgetBuildState.loading]状态
  @override
  Widget defBuildLoadingWidget(
    BuildContext context, [
    dynamic data,
    double? progressValue,
    Color? color,
  ]) {
    return GlobalConfig.of(context)
        .loadingIndicatorBuilder(context, data, progressValue, color)
        .wrapContent(minHeight: kInteractiveHeight)
        .paddingAll(kH);
  }

  /// [WidgetBuildState.empty]状态
  /// @override
  @override
  Widget defBuildEmptyWidget(BuildContext context, [dynamic data]) {
    final globalTheme = GlobalTheme.of(context);
    final stateData =
        widget.stateData ??
        widget.noDataStringGenerate?.call(context) ??
        LibRes.of(context).libAdapterNoMoreData;

    Widget result = "$stateData"
        .text(textAlign: TextAlign.center, style: globalTheme.textSubTitleStyle)
        .padding(globalTheme.xh);

    return result.container(
      constraints: const BoxConstraints(minHeight: kInteractiveHeight),
    );
  }

  /// [WidgetBuildState.error]状态
  @override
  Widget defBuildErrorWidget(BuildContext context, [dynamic error]) {
    final globalTheme = GlobalTheme.of(context);
    final stateData =
        widget.stateData ??
        widget.loadErrorStringGenerate?.call(context) ??
        LibRes.of(context).libAdapterLoadMoreError;

    Widget result = "$stateData"
        .text(textAlign: TextAlign.center, style: globalTheme.textBodyStyle)
        .padding(globalTheme.xh);

    return result
        .container(
          constraints: const BoxConstraints(minHeight: kInteractiveHeight),
        )
        .wrapContent()
        .click(() {
          //点击重试
          if (widget.requestChangeStateFn?.call(
                context,
                _buildState,
                WidgetBuildState.loading,
              ) ==
              false) {
            _updateState = WidgetBuildState.loading;
            updateState();
          }
        });
  }
}

/// 情感图状态切换混入
mixin StateWidgetBuildMixin {
  /// 根据传入的状态, 构建对应的[Widget]
  /// [otherBuilder] 用来构建其他未处理状态的[Widget]
  ///
  /// [WidgetBuildState]
  @entryPoint
  Widget? buildStateWidget(
    BuildContext context,
    WidgetBuildState state,
    dynamic stateData, [
    WidgetStateBuilder? otherBuilder,
  ]) {
    switch (state) {
      case WidgetBuildState.preLoading:
      case WidgetBuildState.loading:
        return defBuildLoadingWidget(context, stateData);
      case WidgetBuildState.empty:
        return defBuildEmptyWidget(context, stateData);
      case WidgetBuildState.error:
        return defBuildErrorWidget(context, stateData);
      default:
        return otherBuilder?.call(context, state, stateData);
    }
  }

  /// [WidgetBuildState.loading]状态
  Widget defBuildLoadingWidget(
    BuildContext context, [
    dynamic data,
    double? progressValue,
    Color? color,
  ]) {
    return GlobalConfig.of(
      context,
    ).loadingIndicatorBuilder(context, data, progressValue, color);
  }

  /// [WidgetBuildState.empty]状态
  Widget defBuildEmptyWidget(BuildContext context, [dynamic data]) {
    return GlobalConfig.of(context).emptyPlaceholderBuilder(context, data);
  }

  /// [WidgetBuildState.error]状态
  Widget defBuildErrorWidget(BuildContext context, [dynamic error]) {
    return GlobalConfig.of(context).errorPlaceholderBuilder(context, error);
  }
}
