part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/11/25
///
/// [Widget]可见性探测
///
/// ```dart
/// WidgetVisibilityDetector(
///       onAppear: () {
///         print('tab1 onAppear');
///       },
///       onDisappear: () {
///         print('tab1 onDisappear');
///       },
///       child: Scaffold(
///         appBar: AppBar(),
///         body: Center(
///             child: Container(
///           child: Column(
///             mainAxisSize: MainAxisSize.min,
///             children: [
///               Text('tab1'),
///             ],
///           ),
///         )),
///       ),
///     )
/// ```
///
/// - https://pub.dev/packages/visibility_detector
/// - https://pub.dev/packages/widget_visibility_detector
/// - https://pub.dev/packages/on_visibility_detector_extension
class WidgetVisibilityDetector extends StatefulWidget {
  const WidgetVisibilityDetector({
    super.key,
    required this.child,
    this.onAppear,
    this.onDisappear,
    this.visibleFraction = 1,
  });

  final Widget child;

  /// 当可见时候调用
  final VoidCallback? onAppear;

  /// 当不可见时候调用
  final VoidCallback? onDisappear;

  /// 默认可见比例
  final double visibleFraction;

  @override
  State<WidgetVisibilityDetector> createState() =>
      _WidgetVisibilityDetectorState();
}

class _WidgetVisibilityDetectorState extends State<WidgetVisibilityDetector>
    with WidgetsBindingObserver {
  final _key = UniqueKey();
  VisibilityInfo? _info;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isShowing()) {
        widget.onDisappear?.call();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isShowing()) {
        widget.onAppear?.call();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  bool _isShowing() {
    return (_info?.visibleFraction ?? 0) == widget.visibleFraction;
  }

  void _handleVisibilityInfoChanged(VisibilityInfo info) {
    _info = info;

    if (info.visibleFraction == widget.visibleFraction) {
      //完全可见
      widget.onAppear?.call();
      return;
    }
    if (info.visibleFraction == 0) {
      //完全不可见
      widget.onDisappear?.call();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _handleVisibilityInfoChanged,
      child: widget.child,
    );
  }
}

/// https://pub.dev/packages/on_visibility_detector_extension
/// https://github.com/Kiruel/on_visibility_detector_extension
extension OnVisibilityDetectorExtension on Widget {
  /// Adds an action to perform after this view appears.
  ///
  /// [action] The action to perform. If action is nil, the call has no effect.
  Widget onAppear(VoidCallback? action) =>
      WidgetVisibilityDetector(onAppear: action, child: this);

  /// Adds an action to perform after this view disappears.
  ///
  /// [action] The action to perform. If action is nil, the call has no effect.
  Widget onDisappear(VoidCallback? action) =>
      WidgetVisibilityDetector(onDisappear: action, child: this);
}
