part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// 限流处理, 用于控制函数的调用频率
/// [Throttle]
/// [Debounce]
class Throttle {
  /// 每隔多少毫秒, 并执行一次
  /// 首次执行也会延迟
  final Duration delay;

  Timer? _timer;

  Throttle(
    this.delay,
  );

  int? _lastCall;

  call(void Function() callback) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastCall == null || now - _lastCall! >= delay.inMilliseconds) {
      _lastCall = now;
      _timer?.cancel();
      _timer = Timer(delay, callback);
    } else {
      //限流
    }
  }

  dispose() {
    _timer?.cancel();
  }
}
