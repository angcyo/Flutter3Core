part of flutter3_widgets;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/11
///

/// 初始化
/// ```
/// MaterialApp(
///   navigatorObservers: [lifecycleNavigatorObserver],
///   ...
/// );
/// ```
final NavigatorObserver lifecycleNavigatorObserver = defaultLifecycleObserver;

NavigatorObserver get lifecycleNavigatorObserverGet => LifecycleObserver();

/// https://pub.dev/packages/lifecycle
/// https://github.com/chenenyu/lifecycle
extension WidgetLifecycleEx on Widget {
  /// 监听当前页面的生命周期
  /// [LifecycleWrapper]
  /// [LifecycleEvent]
  Widget lifecycle(OnLifecycleEvent onLifecycleEvent) => LifecycleWrapper(
        onLifecycleEvent: onLifecycleEvent,
        child: this,
      );

  /// 为[PageView]提供生命周期支持
  /// Wrap PageView
  /// [PageView]
  /// [PageViewLifecycleWrapper]
  /// [pageLifecycleChild]
  Widget pageLifecycle([OnLifecycleEvent? onLifecycleEvent]) =>
      PageViewLifecycleWrapper(
        onLifecycleEvent: onLifecycleEvent,
        child: this,
      );

  /// [ChildPageLifecycleWrapper]
  /// [LifecycleWrapper]
  Widget pageLifecycleChild({
    required int index,
    OnLifecycleEvent? onLifecycleEvent,
    bool wantKeepAlive = true,
  }) =>
      ChildPageLifecycleWrapper(
        index: index,
        wantKeepAlive: wantKeepAlive,
        onLifecycleEvent: onLifecycleEvent,
        child: this,
      );
}
