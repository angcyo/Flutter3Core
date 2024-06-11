part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/06/07
///
/// App生命周期混入
/// [WidgetsBindingObserver]
/// [AppLifecycleListener]
mixin AppLifecycleMixin<T extends StatefulWidget> on State<T> {
  AppLifecycleListener? _appLifecycleListener;

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(
      onShow: onAppLifecycleShow,
      onResume: onAppLifecycleResume,
      onHide: onAppLifecycleHide,
      onPause: onAppLifecyclePause,
      onStateChange: onAppLifecycleStateChange,
    );
    super.initState();
  }

  @override
  void dispose() {
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  //---override

  /// [onAppLifecycleShow]->[onAppLifecycleResume]
  @overridePoint
  void onAppLifecycleShow() {
    assert(() {
      l.d('onAppLifecycleShow');
      return true;
    }());
  }

  @overridePoint
  void onAppLifecycleResume() {
    assert(() {
      l.d('onAppLifecycleResume');
      return true;
    }());
  }

  /// [onAppLifecycleHide]->[onAppLifecyclePause]
  @overridePoint
  void onAppLifecycleHide() {
    assert(() {
      l.d('onAppLifecycleHide');
      return true;
    }());
  }

  @overridePoint
  void onAppLifecyclePause() {
    assert(() {
      l.d('onAppLifecyclePause');
      return true;
    }());
  }

  ///[AppLifecycleState]
  @overridePoint
  void onAppLifecycleStateChange(AppLifecycleState state) {
    //l.d('onAppLifecycleStateChange$state');
  }
}
