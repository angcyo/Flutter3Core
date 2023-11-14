part of flutter3_basics;

///
/// 全局的加载提示
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

Size kDefaultLoadingSize = const Size(50, 50);

WeakReference<OverlayEntry>? _currentLoadingEntryRef;

/// 显示加载提示
showLoading({
  required BuildContext context,
  WidgetBuilder? builder,
  bool barrierDismissible = false,
  Color? barrierColor,
  Duration? duration,
  VoidCallback? onDismiss,
}) {
  var currentLoadingEntry = _currentLoadingEntryRef?.target;
  if (currentLoadingEntry != null) {
    currentLoadingEntry.remove();
    currentLoadingEntry = null;
  }

  var overlayState = Overlay.of(context);
  /*if (overlayState == null) {
    assert(() {
      debugPrint('overlayState is null, dispose this call');
      return true;
    }());
    return;
  }*/
  var route = ModalRoute.of(context);

  ///创建Entry
  currentLoadingEntry = OverlayEntry(builder: (context) {
    return _LoadingOverlay(
        route: route,
        builder: builder ??= (context) {
          return GlobalConfig.of(context).loadingWidgetBuilder(context);
        });
  });
  _currentLoadingEntryRef = WeakReference(currentLoadingEntry);

  postFrameCallback((duration) {
    try {
      if (currentLoadingEntry != null) {
        overlayState.insert(currentLoadingEntry);
      }
    } catch (e) {
      l.e(e);
    }
  });
}

/// 隐藏加载提示
void hideLoading() {
  var currentLoadingEntry = _currentLoadingEntryRef?.target;
  if (currentLoadingEntry != null) {
    try {
      currentLoadingEntry.remove();
    } catch (e) {
      l.e(e);
    } finally {
      _currentLoadingEntryRef = null;
    }
  }
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