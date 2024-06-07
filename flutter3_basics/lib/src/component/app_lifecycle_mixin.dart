part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/06/07
///
/// App生命周期混入
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
    l.d('onAppLifecycleShow');
  }

  @overridePoint
  void onAppLifecycleResume() {
    l.d('onAppLifecycleResume');
  }

  /// [onAppLifecycleHide]->[onAppLifecyclePause]
  @overridePoint
  void onAppLifecycleHide() {
    l.d('onAppLifecycleHide');
  }

  @overridePoint
  void onAppLifecyclePause() {
    l.d('onAppLifecyclePause');
  }

  ///[AppLifecycleState]
  @overridePoint
  void onAppLifecycleStateChange(AppLifecycleState state) {
    //l.d('onAppLifecycleStateChange$state');
  }
}
