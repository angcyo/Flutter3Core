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
  ///
  /// [onLifecycleEvent] 回调函数回调的生命周期是正确的
  ///
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

/// [LifecycleAware]
mixin VisibleLifecycleAware on LifecycleAware {
  /// 页面可见的次数, 可以用来统计页面显示次数
  int _lifecycleVisibleCount = 0;

  /// 页面不可见的次数, 可以用来统计页面隐藏次数
  int _lifecycleInvisibleCount = 0;

  /// 页面是否可见
  bool get isLifecycleVisible =>
      _lifecycleVisibleCount > _lifecycleInvisibleCount;

  @mustCallSuper
  @entryPoint
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (this is State) {
      if (event == LifecycleEvent.visible) {
        (this as State).buildContext?.let((it) {
          if (_lifecycleVisibleCount++ == 0) {
            onLifecycleFirstVisible(it);
          }
          onLifecycleVisible(it);
        });
      } else if (event == LifecycleEvent.invisible) {
        (this as State).buildContext?.let((it) {
          _lifecycleInvisibleCount++;
          onLifecycleInvisible(it);
        });
      }
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

/// 生命周期状态基类, 当前类只能感知整体页面的生命周期
/// https://github.com/chenenyu/lifecycle
/// https://github.com/zhaolongs/flutter_life_state
abstract class BaseLifecycleState<T extends StatefulWidget> extends State<T>
    with LifecycleAware, LifecycleMixin, VisibleLifecycleAware {}

/// [BasePageChildLifecycleState]
/// [ChildPageLifecycleWrapper]
abstract class BasePageChildLifecycleWidget extends StatefulWidget {
  /// 页面索引
  final int pageIndex;

  /// 是否需要缓存[AutomaticKeepAliveClientMixin]
  /// [KeepAlive]
  final bool? wantKeepAlive;

  /// 生命周期回调
  final OnLifecycleEvent? onLifecycleEvent;

  const BasePageChildLifecycleWidget({
    super.key,
    required this.pageIndex,
    this.wantKeepAlive,
    this.onLifecycleEvent,
  });
}

/// 生命周期状态基类, 用于[PageView]的子页面生命周期感知
/// [PageView]需要使用[PageViewLifecycleWrapper]包裹
/// [_ChildPageLifecycleWrapperState]
abstract class BasePageChildLifecycleState<
        T extends BasePageChildLifecycleWidget> extends State<T>
    with
        LifecycleAware,
        ChildPageSubscribeLifecycleMixin,
        WidgetDispatchLifecycleMixin,
        AutomaticKeepAliveClientMixin,
        VisibleLifecycleAware {
  bool _keepAlive = false;

  @override
  int get itemIndex => widget.pageIndex;

  @override
  bool get wantKeepAlive => _keepAlive;

  @override
  void initState() {
    super.initState();
    _updateKeepAlive();
  }

  void _updateKeepAlive() {
    if (widget.wantKeepAlive != null) {
      _keepAlive = widget.wantKeepAlive!;
      updateKeepAlive();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.visitChildElements((element) {
          if (element is StatefulElement &&
              element.state is AutomaticKeepAliveClientMixin) {
            _keepAlive =
                (element.state as AutomaticKeepAliveClientMixin).wantKeepAlive;
            updateKeepAlive();
          }
        });
      });
    }
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    super.onLifecycleEvent(event);
    widget.onLifecycleEvent?.call(event);
  }
}
