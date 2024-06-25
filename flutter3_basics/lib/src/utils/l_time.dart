part of '../../flutter3_basics.dart';

///
/// Debug 下用来打印耗时时间的工具类
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///

/// [Timeline]
/// [Timeline.startSync]
/// [Timeline.finishSync]
/// [Timeline.timeSync]
/// [Stopwatch]
/// ```
/// final stopwatch = Stopwatch()..start();
/// stopwatch.stop();
/// stopwatch.elapsedMilliseconds
/// ```
///
/// ```
/// lTime.tick();
/// l.d(lTime.time());
/// ```
class LTime {
  LTime._();

  static LTime? _def;

  static LTime get def => _def ??= LTime._();

  final StackList<int> stack = StackList();

  /// 计算2个毫秒时间的差值
  /// [pattern] 当前位置的值是否要输出显示. 0智能判断 1强制 -1忽略.
  static String diffTime(
    int? startTime, {
    int? endTime,
    List<int> pattern = const [0, 0, 0, 0, 0],
    List<String> unit = const ["ms", "s", "m", "h", "d"],
    String def = "--",
  }) {
    if (startTime == null) {
      return def;
    }
    final start = DateTime.fromMillisecondsSinceEpoch(startTime);
    final end = DateTime.fromMillisecondsSinceEpoch(endTime ?? nowTimestamp());
    final diff = end.difference(start);
    return diff.inMilliseconds.toPatternTime(pattern: pattern, unit: unit);
  }

  /// 记录时间
  @callPoint
  int tick() {
    var time = nowTimestamp();
    stack.push(time);
    return time;
  }

  /// 获取与最近一次时间匹配的时间间隔(ms)
  String time([int? startTime]) {
    startTime ??= stack.popOrNull();
    if (startTime == null) {
      return "0ms";
    }
    return diffTime(startTime);
  }
}

@callPoint
LTime get lTime => LTime.def;
