part of flutter3_basics;

///
/// 全局的加载提示
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

Size kDefaultLoadingSize = const Size(50, 50);

OverlayState? _overlayState;
OverlayEntry? _currentLoading;

/// 显示加载提示
showLoading({
  required BuildContext context,
  WidgetBuilder? builder,
  bool barrierDismissible = false,
  Color? barrierColor,
  Duration? duration,
  VoidCallback? onDismiss,
}) {
  if (_currentLoading != null) {
    _currentLoading?.remove();
    _currentLoading = null;
  }

  _overlayState = Overlay.of(context);
  var route = ModalRoute.of(context);

  ///创建Entry
  _currentLoading = OverlayEntry(builder: (context) {
    return _LoadingOverlay(
      route: route,
      builder: builder ??= _buildDefaultLoadingWidget,
    );
  });

  try {
    postFrameCallback((duration) {
      if (_currentLoading != null) {
        _overlayState?.insert(_currentLoading!);
      }
    });
  } catch (e) {
    l.e(e);
  }
}

/// 隐藏加载提示
void hideLoading() {
  if (_currentLoading != null) {
    try {
      _currentLoading?.remove();
    } catch (e) {
      l.e(e);
    } finally {
      _currentLoading = null;
    }
  }
}

Widget _buildDefaultLoadingWidget(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    child: SizedBox.fromSize(
      size: kDefaultLoadingSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const LoadingIndicator(),
      ),
    ),
  );
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
