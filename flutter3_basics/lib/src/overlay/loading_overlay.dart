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
OverlayEntry? showLoading({
  BuildContext? context,
  WidgetBuilder? builder,
  bool barrierDismissible = false,
  Color? barrierColor,
  Duration? duration,
  VoidCallback? onDismiss,
  double? progressValue,
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
        builder: builder ??= (context) {
          return GlobalConfig.of(context).loadingOverlayWidgetBuilder(
              context, OverlayEntry, progressValue);
        });
  });
  _currentLoadingEntryRef = WeakReference(currentLoadingEntry);

  postFrameCallback((duration) {
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
  });

  return currentLoadingEntry;
}

/// 隐藏加载提示
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
/// [timeout] 超时时间
Future wrapLoading<T>(
  Future<T?> future, {
  Duration? timeout,
  VoidCallback? onStart,
  ValueCallback? onEnd,
}) {
  if (onStart == null) {
    showLoading();
  } else {
    onStart.call();
  }
  bool isTimeout = false;
  bool isEnd = false;
  if (timeout != null) {
    //需要检查超时
    postDelayCallback(() {
      if (!isEnd) {
        isTimeout = true;
        hideLoading();
        onEnd?.call(const RTimeoutException(message: 'wrapLoading timeout.'));
      }
    }, timeout);
  }
  return future.get((value, error) {
    if (isTimeout) {
      assert(() {
        l.w('忽略结果, 因为已经超时了.');
        return true;
      }());
      return;
    }
    if (onEnd == null) {
      hideLoading();
    } else {
      onEnd.call();
    }
    if (error != null) {
      throw error;
    }
    return value;
  });
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay({
    super.key,
    required this.builder,
    this.route,
  });

  final ModalRoute<dynamic>? route;

  final WidgetBuilder builder;

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
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
        child: widget.builder(context),
      ), // 拦截手势
    );
  }
}
