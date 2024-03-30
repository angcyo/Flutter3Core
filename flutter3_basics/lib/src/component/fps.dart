part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/30
///

class Fps {
  Duration? previous;
  List<Duration> timings = [];

  late int framesToDisplay = 30;

  /// 帧率
  String get fps => timings.lastOrNull?.fps.toStringAsFixed(0) ?? "--";

  /// 请在一帧内触发此方法
  void update() {
    Duration duration = nowTime().milliseconds;
    if (previous != null) {
      timings.add(duration - previous!);
      if (timings.length > framesToDisplay) {
        timings = timings.sublist(timings.length - framesToDisplay - 1);
      }
    }
    previous = duration;
  }
}

extension _FPS on Duration {
  double get fps => (1000 / inMilliseconds);
}
