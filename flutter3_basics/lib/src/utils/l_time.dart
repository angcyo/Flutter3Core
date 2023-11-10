part of flutter3_basics;

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
///
class LTime {
  LTime._();

  static LTime? _def;

  static LTime get def => _def ??= LTime._();

  final StackList<int> stack = StackList();

  /// 计算2个毫秒时间的差值
  static String diffTime(
    int startTime, {
    int? endTime,
    List<String> unit = const ["ms", "s", "m", "h", "d"],
  }) {
    DateTime start = DateTime.fromMillisecondsSinceEpoch(startTime);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(endTime ?? nowTime());
    Duration diff = end.difference(start);
    var times = diff.inMilliseconds.toPartTimes();
    final ms = times[0];
    final s = times[1];
    final m = times[2];
    final h = times[3];
    final d = times[4];
    return stringBuilder((builder) {
      if (d > 0) {
        builder.write("$d${unit[4]}");
      }
      if (h > 0) {
        builder.write("$h${unit[3]}");
      }
      if (m > 0) {
        builder.write("$m${unit[2]}");
      }
      //if (s > 0) {
      builder.write("$s${unit[1]}");
      //}
      //if (ms > 0) {
      builder.write("$ms${unit[0]}");
      //}
    });
    return "$d天 $h时 $m分 $s秒 $ms毫秒";
  }

  /// 记录时间
  @callPoint
  int tick() {
    var time = nowTime();
    stack.push(time);
    return time;
  }

  /// 获取与最近一次时间匹配的时间间隔(ms)
  String time() {
    var lastTime = stack.popOrNull();
    if (lastTime == null) {
      return "0ms";
    }
    return diffTime(lastTime);
  }
}

@callPoint
LTime get lTime => LTime.def;
