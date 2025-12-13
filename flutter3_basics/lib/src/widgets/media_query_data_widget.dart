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

/// - [MediaQueryDataBuilderWidget]
class _MediaQueryDataBuilderWidgetState
    extends MediaQueryDataState<MediaQueryDataBuilderWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      mediaQueryDataMixin ?? platformMediaQueryData,
    );
  }

  @override
  void onSelfMediaQueryDataChanged(MediaQueryData? from, MediaQueryData to) {
    if (widget.onChange?.call(context, to) != true) {
      updateState();
    }
  }
}

typedef MediaQueryDataWidgetBuilder =
    Widget Function(BuildContext context, MediaQueryData mediaQueryData);

/// [MediaQueryData]数据改变监听小部件
/// - 屏幕大小改变
/// - 窗口大小改变
/// - 窗口方向改变
/// - [MediaQueryDataState]
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
        if (old?.platformBrightness != mediaQueryData.platformBrightness) {
          onSelfPlatformBrightnessChanged(
            old?.platformBrightness,
            mediaQueryData.platformBrightness,
          );
        }
      }
    }
    //debugger();
  }

  /// [MediaQueryData]数据改变
  @overridePoint
  void onSelfMediaQueryDataChanged(MediaQueryData? from, MediaQueryData to) {
    updateState();
  }

  /// 平台[Brightness]暗色模式发生改变
  @overridePoint
  void onSelfPlatformBrightnessChanged(Brightness? from, Brightness to) {
    debugger();
  }
}

/// - [MediaQueryDataChangeMixin]
abstract class MediaQueryDataState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver, MediaQueryDataChangeMixin<T> {}
