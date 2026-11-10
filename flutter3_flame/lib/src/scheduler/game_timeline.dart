///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 时间轴
/// 这种方式非常适合：
/// - 游戏开场剧情。
/// - Boss 出场。
/// - 新手教程。
/// - 游戏阶段切换。
/// - 关卡事件。
/// - 定时出现的特殊敌人。
/// 时间轴事件
class TimelineEvent {
  final double time;
  final String name;
  final void Function() callback;

  TimelineEvent({
    required this.time,
    required this.name,
    required this.callback,
  });
}

/// 游戏时间轴
class GameTimeline {
  final List<TimelineEvent> events = [];

  /// 已经经过的时间
  double elapsed = 0;

  /// 下一个事件的索引
  int _nextIndex = 0;

  /// 添加事件
  void addEvent(double time, String name, void Function() callback) {
    events.add(TimelineEvent(time: time, name: name, callback: callback));
    events.sort((a, b) => a.time.compareTo(b.time));
  }

  /// 更新时间轴
  void update(double dt) {
    elapsed += dt;

    while (_nextIndex < events.length) {
      final event = events[_nextIndex];

      if (elapsed < event.time) {
        break;
      }

      _nextIndex++;

      event.callback();
    }
  }

  /// 重置时间轴
  void reset() {
    elapsed = 0;
    _nextIndex = 0;
  }
}
