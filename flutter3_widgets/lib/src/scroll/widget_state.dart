part of flutter3_widgets;

///
/// 情感图状态控制
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [WidgetBuilder]
typedef WidgetStateBuilder = Widget Function(
    BuildContext context, WidgetState widgetState, dynamic stateData);

/// 创建一个字符串
typedef GenerateString = String? Function(BuildContext context);

/// 使用一个[Widget]包裹住[child]
typedef WidgetWrapBuilder = Widget Function(BuildContext context, Widget child);

/// 请求改变状态,
/// 返回true表示拦截改变.
/// 返回false表示允许改变, 并且会更新当前的状态
typedef RequestChangeStateFn = bool Function(BuildContext context,
    WidgetState oldWidgetState, WidgetState newWidgetState);

enum WidgetState {
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

  bool get isNoneState => this == WidgetState.none;
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

/// [WidgetState]状态控制
class WidgetStateWidget extends StatefulWidget {
  final dynamic stateData;

  /// 当前的状态
  final WidgetState widgetState;

  /// 无数据/无更多数据时, 显示的字符串
  final GenerateString? noDataStringGenerate;

  /// 加载失败时, 显示的字符串
  final GenerateString? loadErrorStringGenerate;

  /// 请求改变状态
  final RequestChangeStateFn? requestChangeStateFn;

  /// 构建不同状态的Widget
  final WidgetStateBuilder? buildWidgetStateWidget;

  /// 细分的[WidgetState.loading]状态
  final WidgetStateBuilder? buildLoadingWidgetState;

  /// 细分的[WidgetState.empty]状态
  final WidgetStateBuilder? buildEmptyWidgetStateWidget;

  /// 细分的[WidgetState.error]状态
  final WidgetStateBuilder? buildErrorWidgetStateWidget;

  const WidgetStateWidget({
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
  State<WidgetStateWidget> createState() => WidgetStateWidgetState();
}

class WidgetStateWidgetState extends State<WidgetStateWidget> {
  /// 更新后的状态
  WidgetState? _updateState;

  WidgetState get _buildState => _updateState ?? widget.widgetState;

  /// [WidgetState.loading]状态
  Widget _buildLoadingWidget(BuildContext context) {
    return (widget.buildLoadingWidgetState ?? widget.buildWidgetStateWidget)
            ?.call(context, _buildState, widget.stateData) ??
        GlobalConfig.of(context).loadingIndicatorBuilder(context);
  }

  /// [WidgetState.empty]状态
  Widget _buildEmptyWidget(BuildContext context) {
    var result =
        (widget.buildEmptyWidgetStateWidget ?? widget.buildWidgetStateWidget)
            ?.call(context, _buildState, widget.stateData);
    if (result != null) {
      return result;
    }
    return const Placeholder();
  }

  /// [WidgetState.error]状态
  Widget _buildErrorWidget(BuildContext context) {
    var result =
        (widget.buildErrorWidgetStateWidget ?? widget.buildWidgetStateWidget)
            ?.call(context, _buildState, widget.stateData);
    if (result != null) {
      return result;
    }
    return const Placeholder();
  }

  /// 其他默认状态
  Widget _buildDefaultWidget(BuildContext context) {
    var result = (widget.buildWidgetStateWidget)
        ?.call(context, _buildState, widget.stateData);
    if (result != null) {
      return result;
    }
    return const Placeholder();
  }

  @callPoint
  void updateWidgetState(WidgetState state) {
    _updateState = state;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    switch (_buildState) {
      case WidgetState.loading:
        return _buildLoadingWidget(context);
      case WidgetState.empty:
        return _buildEmptyWidget(context);
      case WidgetState.error:
        return _buildErrorWidget(context);
      default:
        return _buildDefaultWidget(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant WidgetStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState = null;
  }
}

/// 情感图[WidgetState]状态控制
class AdapterStateWidget extends WidgetStateWidget {
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

class AdapterStateWidgetState extends WidgetStateWidgetState {
  /// [WidgetState.loading]状态
  @override
  Widget _buildLoadingWidget(BuildContext context) {
    return GlobalConfig.of(context).loadingIndicatorBuilder(context);
  }

  /// [WidgetState.empty]状态
  /// @override
  @override
  Widget _buildEmptyWidget(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    //def 360*360
    var size = 160.0;
    Widget result = loadAssetImageWidget(
      Assets.png.noData.keyName,
      package: 'flutter3_widgets',
    ).size(width: size, height: size);

    var stateData = widget.stateData ??
        widget.noDataStringGenerate?.call(context) ??
        globalTheme.noDataTip;
    if (stateData != null) {
      result = result.columnOf(
        "$stateData"
            .text(
              textAlign: TextAlign.center,
              style: globalTheme.textBodyStyle,
            )
            .padding(globalTheme.xh),
      );
    }
    return result.wrapContent();
  }

  /// [WidgetState.error]状态
  @override
  Widget _buildErrorWidget(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    //def 360*360
    var size = 160.0;
    Widget result = loadAssetImageWidget(
      Assets.png.loadError.keyName,
      package: 'flutter3_widgets',
    ).size(width: size, height: size);

    var stateData = widget.stateData ??
        widget.loadErrorStringGenerate?.call(context) ??
        globalTheme.loadDataErrorTip;

    if (stateData != null) {
      result = result.columnOf(
        "$stateData"
            .text(
              textAlign: TextAlign.center,
              style: globalTheme.textBodyStyle,
            )
            .padding(globalTheme.xh),
      );
    }
    return result.wrapContent().click(() {
      //点击重试
      if (widget.requestChangeStateFn
              ?.call(context, _buildState, WidgetState.loading) ==
          false) {
        _updateState = WidgetState.loading;
        updateState();
      }
    });
  }
}

/// 加载更多[WidgetState]状态控制
class LoadMoreStateWidget extends WidgetStateWidget {
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

class LoadMoreStateWidgetState extends WidgetStateWidgetState {
  @override
  Widget _buildDefaultWidget(BuildContext context) {
    return _buildLoadingWidget(context);
  }

  /// [WidgetState.loading]状态
  @override
  Widget _buildLoadingWidget(BuildContext context) {
    return GlobalConfig.of(context)
        .loadingIndicatorBuilder(context)
        .wrapContent(minHeight: kInteractiveHeight);
  }

  /// [WidgetState.empty]状态
  /// @override
  @override
  Widget _buildEmptyWidget(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    var stateData = widget.stateData ??
        widget.noDataStringGenerate?.call(context) ??
        globalTheme.noMoreDataTip;

    Widget result = "$stateData"
        .text(
          textAlign: TextAlign.center,
          style: globalTheme.textBodyStyle,
        )
        .padding(globalTheme.xh);

    return result.container(
        constraints: const BoxConstraints(minHeight: kInteractiveHeight));
  }

  /// [WidgetState.error]状态
  @override
  Widget _buildErrorWidget(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    var stateData = widget.stateData ??
        widget.loadErrorStringGenerate?.call(context) ??
        globalTheme.loadDataErrorTip;

    Widget result = "$stateData"
        .text(
          textAlign: TextAlign.center,
          style: globalTheme.textBodyStyle,
        )
        .padding(globalTheme.xh);

    return result
        .container(
            constraints: const BoxConstraints(minHeight: kInteractiveHeight))
        .wrapContent()
        .click(() {
      //点击重试
      if (widget.requestChangeStateFn
              ?.call(context, _buildState, WidgetState.loading) ==
          false) {
        _updateState = WidgetState.loading;
        updateState();
      }
    });
  }
}
