part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/09/08
///
/// [MediaQueryData]数据改变监听小部件
/// - [MediaQueryDataChangeMixin]
///
/// - 当[MediaQueryData]改变时通知
///   - 包含窗口大小改变时, 通知, 并重建界面
class MediaQueryDataBuilderWidget extends StatefulWidget {
  /// 监听的[ui.FlutterView]
  /// - 多窗口时需要
  final ui.FlutterView? view;

  /// [WidgetBuilder]
  final MediaQueryDataWidgetBuilder builder;

  /// 当[MediaQueryData]改变时触发的回调
  /// - 默认处理: 刷新界面
  /// @return true 表示拦截默认处理
  final bool Function(BuildContext context, MediaQueryData mediaQueryData)?
  onChange;

  const MediaQueryDataBuilderWidget({
    super.key,
    this.view,
    this.onChange,
    required this.builder,
  });

  @override
  State<MediaQueryDataBuilderWidget> createState() =>
      _MediaQueryDataBuilderWidgetState();
}

class _MediaQueryDataBuilderWidgetState
    extends State<MediaQueryDataBuilderWidget>
    with WidgetsBindingObserver {
  ui.FlutterView? _view;
  late MediaQueryData _mediaQueryData;

  @override
  void initState() {
    _view =
        widget.view ??
        WidgetsBinding.instance.platformDispatcher.views.firstOrNull ??
        flutterViews.firstOrNull ??
        flutterView;
    _mediaQueryData = MediaQueryData.fromView(_view!);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _mediaQueryData);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final mediaQueryData = MediaQueryData.fromView(_view!);
    if (_mediaQueryData != mediaQueryData) {
      _mediaQueryData = mediaQueryData;
      if (widget.onChange?.call(context, mediaQueryData) != true) {
        updateState();
      }
    }
    //debugger();
  }
}

typedef MediaQueryDataWidgetBuilder =
    Widget Function(BuildContext context, MediaQueryData mediaQueryData);

/// [MediaQueryData]数据改变监听小部件
/// - 屏幕大小改变
/// - 窗口大小改变
/// - 窗口方向改变
mixin MediaQueryDataChangeMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  /// 当前视图
  @output
  ui.FlutterView? viewMixin;

  /// 当前查询到媒体数据
  @output
  MediaQueryData? mediaQueryDataMixin;

  @override
  void initState() {
    viewMixin =
        WidgetsBinding.instance.platformDispatcher.views.firstOrNull ??
        flutterViews.firstOrNull ??
        flutterView;
    if (viewMixin != null) {
      mediaQueryDataMixin = MediaQueryData.fromView(viewMixin!);
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    //super.didChangeMetrics();
    if (viewMixin != null) {
      final mediaQueryData = MediaQueryData.fromView(viewMixin!);
      if (mediaQueryDataMixin != mediaQueryData) {
        final old = mediaQueryDataMixin;
        mediaQueryDataMixin = mediaQueryData;
        onSelfMediaQueryDataChanged(old, mediaQueryData);
      }
    }
    //debugger();
  }

  /// [MediaQueryData]数据改变
  @overridePoint
  void onSelfMediaQueryDataChanged(MediaQueryData? from, MediaQueryData to) {
    updateState();
  }
}
