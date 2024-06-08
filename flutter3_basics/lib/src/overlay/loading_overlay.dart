part of '../../flutter3_basics.dart';

///
/// 全局的加载提示
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

Size kDefaultLoadingSize = const Size(50, 50);

/// 弱引用
WeakReference<OverlayEntry>? _currentLoadingEntryRef;

/// 显示加载提示
/// [showStrokeLoading]
/// [postShow] 是否要延迟显示
/// [wrapLoading]
/// [wrapLoadingTimeout]
@api
OverlayEntry? showLoading({
  BuildContext? context,
  LoadingValueNotifier? loadingInfoNotifier,
  DataWidgetBuilder<LoadingInfo>? builder,
  bool barrierDismissible = false,
  Color? barrierColor,
  Duration? duration,
  VoidCallback? onDismiss,
  double? progressValue,
  bool postShow = true,
}) {
  var currentLoadingEntry = _currentLoadingEntryRef?.target;
  if (currentLoadingEntry != null) {
    currentLoadingEntry.remove();
    currentLoadingEntry = null;
  }

  var overlayState = context == null
      ? GlobalConfig.def.findOverlayState()
      : Overlay.of(context);
  if (overlayState == null) {
    assert(() {
      debugPrint('overlayState is null, dispose this call.');
      return true;
    }());
    return currentLoadingEntry;
  }

  var route = context == null
      ? GlobalConfig.def.findModalRouteList().lastOrNull
      : ModalRoute.of(context);

  ///创建Entry
  currentLoadingEntry = OverlayEntry(builder: (context) {
    return _LoadingOverlay(
        route: route,
        loadingInfoNotifier: loadingInfoNotifier,
        builder: builder ??= (context, loadingInfo) {
          Widget result = GlobalConfig.of(context).loadingOverlayWidgetBuilder(
            context,
            OverlayEntry,
            progressValue,
          );
          final message = loadingInfo?.message;
          if (message != null) {
            final globalTheme = GlobalTheme.of(context);
            result = result
                .stackOf(message.text(
                    style: globalTheme.textPlaceStyle
                        .copyWith(color: globalTheme.whiteColor)))
                .material();
          }
          return result;
        });
  });
  _currentLoadingEntryRef = WeakReference(currentLoadingEntry);

  void insert() {
    try {
      if (currentLoadingEntry != null) {
        overlayState.insert(currentLoadingEntry);
      }
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
  }

  if (postShow) {
    postFrameCallback((duration) {
      insert();
    });
  } else {
    insert();
  }

  return currentLoadingEntry;
}

/// 隐藏加载提示
@api
void hideLoading() {
  final currentLoadingEntry = _currentLoadingEntryRef?.target;
  if (currentLoadingEntry != null) {
    try {
      currentLoadingEntry.remove(); //移除
      currentLoadingEntry.dispose(); //释放资源, 之后不可用
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    } finally {
      _currentLoadingEntryRef = null;
    }
  }
}

/// 包裹[showLoading].[hideLoading].[Future]
/// [future] 需要包裹的[Future], 等带这个[future]的返回结果
/// [onStart] 自定义开始时的回调, 拦截默认显示加载提示
/// [delay] 延迟多久后显示加载提示
/// [timeout] 超时多久后触发[onEnd]回调, 并阻止[Future]的返回值,
/// [showTime] 是否显示倒计时
/// [wrapLoading]
/// [wrapLoadingTimeout]
Future wrapLoading(
  Future future, {
  Duration? delay,
  Duration? timeout,
  VoidCallback? onStart,
  ValueCallback? onEnd,
  bool showTime = false,
}) {
  Timer? timer;
  bool isTimeout = false;
  bool isEnd = false;
  LoadingValueNotifier? loadingInfoNotifier;
  if (onStart == null) {
    if (timeout != null) {
      loadingInfoNotifier =
          LoadingValueNotifier(LoadingInfo(message: "${timeout.inSeconds}"));
    }
    if (delay != null) {
      postDelayCallback(() {
        //debugger();
        //l.w("delay end");
        if (isEnd || isTimeout) {
        } else {
          showLoading(
            postShow: false,
            loadingInfoNotifier: loadingInfoNotifier,
          );
        }
      }, delay);
    } else {
      showLoading(
        loadingInfoNotifier: loadingInfoNotifier,
      );
    }
  } else {
    onStart.call();
  }
  //--
  if (timeout != null) {
    if (showTime) {
      //需要显示倒计时
      timer = countdownCallback(timeout, (duration) {
        loadingInfoNotifier?.value =
            LoadingInfo(message: "${duration.inSeconds}");
      });
    }

    //需要检查超时
    postDelayCallback(() {
      if (!isEnd) {
        isTimeout = true;
        timer?.cancel();
        hideLoading();
        onEnd?.call(RTimeoutException(message: 'wrapLoading timeout.'));
      }
    }, timeout);
  }
  return future.get((value, error) {
    //debugger();
    //l.w("future end");
    if (isTimeout) {
      assert(() {
        l.w('忽略结果, 因为已经超时了.');
        return true;
      }());
      return;
    }
    isEnd = true;
    timer?.cancel();
    if (onEnd == null) {
      hideLoading();
    } else {
      onEnd.call(null);
    }
    if (error != null) {
      throw error;
    }
    return value;
  });
}

/// 自动超时, 自动延时
/// [wrapLoading]
Future wrapLoadingTimeout(
  Future future, {
  Duration? delay = const Duration(seconds: 1),
  Duration? timeout = const Duration(seconds: 30),
  bool showTime = false,
}) {
  return wrapLoading(
    future,
    delay: delay,
    timeout: timeout,
    showTime: showTime,
  );
}

/// 加载框支持的数据
/// [_LoadingOverlay]
class LoadingInfo {
  /// 指定进度的值
  /// [0~1]
  double? progress;

  /// 指定需要显示的消息
  String? message;

  LoadingInfo({this.progress, this.message});
}

/// 通知值改变的桥梁
class LoadingValueNotifier extends ValueNotifier<LoadingInfo?> {
  LoadingValueNotifier(super.value);
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay({
    super.key,
    required this.builder,
    this.route,
    this.loadingInfoNotifier,
  });

  final ModalRoute<dynamic>? route;
  final DataWidgetBuilder<LoadingInfo> builder;
  final LoadingValueNotifier? loadingInfoNotifier;

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  @override
  void initState() {
    widget.loadingInfoNotifier?.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() {
    //debugger();
    widget.loadingInfoNotifier?.removeListener(_rebuild);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    //debugger();
    oldWidget.loadingInfoNotifier?.removeListener(_rebuild);
    widget.loadingInfoNotifier?.removeListener(_rebuild);
    widget.loadingInfoNotifier?.addListener(_rebuild);
  }

  void _rebuild() {
    //debugger();
    updateState();
  }

  /// 拦截返回键
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RouteWillPopScope(
      route: widget.route,
      onWillPop: _onWillPop,
      child: AbsorbPointer(
        absorbing: true,
        child: widget.builder(context, widget.loadingInfoNotifier?.value),
      ), // 拦截手势
    );
  }
}
