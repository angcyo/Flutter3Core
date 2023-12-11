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

extension WidgetLifecycleEx on Widget {
  /// [LifecycleWrapper]
  /// [LifecycleEvent]
  Widget lifecycle(OnLifecycleEvent onLifecycleEvent) => LifecycleWrapper(
        onLifecycleEvent: onLifecycleEvent,
        child: this,
      );

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
