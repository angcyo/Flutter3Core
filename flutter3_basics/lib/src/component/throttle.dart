part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// 限流/节流处理, 用于控制函数的调用频率
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

/// 每隔多少毫秒, 并执行一次, 首次执行不限流
extension ThrottleEx on dynamic {
  static final Map<int, Timer> _throttleMap = {};
  static final Map<int, int> _throttleTimeMap = {};

  /// 限流, 短时间内的连续事件忽略
  void throttle(VoidCallback callback, [int millisecond = 200, int? key]) {
    //debugger();
    key ??= hashCode;
    Timer? timer = _throttleMap[key];
    int? time = _throttleTimeMap[key];
    if (timer == null || nowTime() - time! >= millisecond) {
      callback.call();
      timer?.cancel();
      timer = Timer(Duration(milliseconds: millisecond), () {
        _throttleMap.remove(key);
        _throttleTimeMap.remove(key);
      });
      _throttleMap[key] = timer;
      _throttleTimeMap[key] = nowTime();
    }
  }
}

/// https://pub.dev/packages/dev_prokit
/// [Throttle]
/// [Debounce]
extension ThrottleFunction on Function {
  /// Throttling for calling events without parameters,
  /// The default parameter is 200 milliseconds.
  ///
  /// Example :
  /// ```
  /// GestureDetector(
  ///   onTap: () {
  ///     print('throttle');
  ///   }.throttle(),
  /// )
  /// ```
  Function() throttle([int millisecond = 200]) {
    late bool isPass = true;
    return () {
      if (!isPass) return;
      isPass = false;
      this.call();
      Timer(Duration(milliseconds: millisecond), () => isPass = true);
    };
  }

  /// Throttle calling event with one argument,
  /// The default parameter is 200 milliseconds.
  ///
  /// Example :
  /// ```
  /// GestureDetector(
  ///   onTapDown: (details) {
  ///     print('throttle');
  ///   }.throttleParam(),
  /// ),
  /// ```
  Function(T) throttleParam<T>([int millisecond = 200]) {
    late bool isPass = true;
    return (t) {
      if (!isPass) return;
      isPass = false;
      this.call(t);
      Timer(Duration(milliseconds: millisecond), () => isPass = true);
    };
  }

  /// Throttle calling event with two arguments,
  /// The default parameter is 200 milliseconds.
  ///
  /// Example :
  /// ```
  /// // Define :
  /// class MethodWidget extends StatelessWidget {
  ///   const MethodWidget({super.key, this.itemMethod});
  ///   final Function(String, int)? itemMethod;
  /// }
  /// // Use :
  /// MethodWidget(
  ///   itemMethod:(name,index) {
  ///     print('$name-$index');
  ///   }.throttleParam2(),
  /// )
  /// ```
  Function(T, K) throttleParam2<T, K>([int millisecond = 200]) {
    late bool isPass = true;
    return (t, k) {
      if (!isPass) return;
      isPass = false;
      this.call(t, k);
      Timer(Duration(milliseconds: millisecond), () => isPass = true);
    };
  }
}
