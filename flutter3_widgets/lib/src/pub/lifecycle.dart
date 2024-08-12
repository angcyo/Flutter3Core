part of '../../flutter3_widgets.dart';

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

/// 每次都创建新的[LifecycleObserver]对象
/// [lifecycleNavigatorObserver] 单例
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
  /// child 需要使用[ChildPageLifecycleWrapper]包裹
  /// [PageView]
  /// [PageViewLifecycleWrapper]
  /// [pageChildLifecycle]
  Widget pageLifecycle([
    bool enable = true,
    OnLifecycleEvent? onLifecycleEvent,
  ]) =>
      enable
          ? PageViewLifecycleWrapper(
              onLifecycleEvent: onLifecycleEvent,
              child: this,
            )
          : this;

  /// 将[PageView]的child界面使用[ChildPageLifecycleWrapper]包裹起来,
  /// 使得对应的[child]可以接收到[LifecycleAware]生命周期回调
  /// [PageView]需要使用[PageViewLifecycleWrapper]包裹
  /// [ChildPageLifecycleWrapper]
  /// [LifecycleWrapper]
  ///
  /// [ScrollViewItemLifecycleWrapper]
  ///
  Widget pageChildLifecycle({
    required int index,
    OnLifecycleEvent? onLifecycleEvent,
    bool? wantKeepAlive = true,
  }) =>
      ChildPageLifecycleWrapper(
        index: index,
        wantKeepAlive: wantKeepAlive,
        onLifecycleEvent: onLifecycleEvent,
        child: this,
      );
}

/// 生命周期状态基类
/// https://github.com/chenenyu/lifecycle
/// https://github.com/zhaolongs/flutter_life_state
abstract class BaseLifecycleState<T extends StatefulWidget> extends State<T>
    with LifecycleAware, LifecycleMixin {
  int _lifecycleVisibleCount = 0;

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.visible) {
      buildContext?.let((it) {
        if (_lifecycleVisibleCount++ == 0) {
          onLifecycleFirstVisible(it);
        }
        onLifecycleVisible(it);
      });
    } else if (event == LifecycleEvent.invisible) {
      buildContext?.let((it) {
        onLifecycleInvisible(it);
      });
    }
  }

  /// 页面首次可见的回调
  @overridePoint
  void onLifecycleFirstVisible(BuildContext context) {}

  /// 页面可见的回调
  @overridePoint
  void onLifecycleVisible(BuildContext context) {}

  /// 页面不可见的回调
  @overridePoint
  void onLifecycleInvisible(BuildContext context) {}
}
