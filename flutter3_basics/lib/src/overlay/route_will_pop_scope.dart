part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

/// 系统的[WillPopScope]会从当前的context中获取, 有些情况下不一定获取到自己想要的
/// 这个小部件指定了路由
///
/// [WillPopScope]
/// [PopScope]
///
class RouteWillPopScope extends StatefulWidget {
  const RouteWillPopScope({
    super.key,
    this.route,
    required this.child,
    this.onWillPop,
  });

  /// 强制指定路由, 不指定则从当前的context中获取
  final ModalRoute<dynamic>? route;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  /// [WillPopScope.child]
  /// [PopScope.child]
  final Widget child;

  /// Called to veto attempts by the user to dismiss the enclosing [ModalRoute].
  ///
  /// If the callback returns a Future that resolves to false, the enclosing
  /// route will not be popped.
  /// [WillPopScope.onWillPop]
  final WillPopCallback? onWillPop;

  @override
  State<RouteWillPopScope> createState() => _RouteWillPopScopeState();
}

class _RouteWillPopScopeState extends State<RouteWillPopScope> {
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onWillPop != null) {
      _route?.removeScopedWillPopCallback(widget.onWillPop!);
    }
    _route = widget.route ?? ModalRoute.of(context);
    if (widget.onWillPop != null) {
      _route?.addScopedWillPopCallback(widget.onWillPop!);
    }
  }

  @override
  void didUpdateWidget(RouteWillPopScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onWillPop != oldWidget.onWillPop && _route != null) {
      if (oldWidget.onWillPop != null) {
        _route!.removeScopedWillPopCallback(oldWidget.onWillPop!);
      }
      if (widget.onWillPop != null) {
        _route!.addScopedWillPopCallback(widget.onWillPop!);
      }
    }
  }

  @override
  void dispose() {
    if (widget.onWillPop != null) {
      try {
        //Tried to remove a willPop callback from a route that is not currently in the tree.
        _route?.removeScopedWillPopCallback(widget.onWillPop!);
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
        //no op
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

typedef CanPopCallback = Future<bool> Function();

/// [RouteWillPopScope]
/// [PopScope]
class RoutePopScope extends StatefulWidget {
  final ModalRoute<dynamic>? route;
  final Widget child;
  final CanPopCallback? onCallPop;

  const RoutePopScope({
    super.key,
    this.route,
    required this.child,
    this.onCallPop,
  });

  @override
  State<RoutePopScope> createState() => _RoutePopScopeState();
}

class _RoutePopScopeState extends State<RoutePopScope>
    implements PopEntry<dynamic> {
  ModalRoute<dynamic>? _route;

  @override
  void onPopInvoked(bool didPop) {
    debugger();
    throw UnimplementedError();
  }

  @override
  void onPopInvokedWithResult(bool didPop, dynamic result) {
    //debugger();
    widget.onCallPop?.call().then((value) {
      canPopNotifier.value = value;
    });
  }

  @override
  late final ValueNotifier<bool> canPopNotifier;

  @override
  void initState() {
    super.initState();
    canPopNotifier = ValueNotifier<bool>(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //debugger();
    _route?.unregisterPopEntry(this);
    _route = widget.route ?? ModalRoute.of(context);
    _route?.registerPopEntry(this);
  }

  @override
  void didUpdateWidget(RoutePopScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    canPopNotifier.value = false;
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(this);
    canPopNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
