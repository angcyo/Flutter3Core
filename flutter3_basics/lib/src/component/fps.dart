part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/30
///

class Fps {
  Duration? previous;

  late int framesToDisplay = 30;

  /// 当前的帧数
  int _fpsCount = 0;

  /// 1秒内的帧率
  String fps = "--";

  /// 请在一帧内触发此方法
  void update() {
    _fpsCount++;
    Duration duration = nowTimestamp().milliseconds;
    if (previous != null) {
      final time = duration - previous!;
      final milliseconds = time.inMilliseconds;
      if (milliseconds >= 1000) {
        //debugger();
        previous = duration;
        final fps_ = _fpsCount * 1.0 / time.inMilliseconds * 1000;
        fps = fps_.toStringAsFixed(0);
        _fpsCount = 0;
      }
    } else {
      previous = duration;
    }
  }
}
