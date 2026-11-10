///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 时间调度器
/// - 下面实现一套可以直接放入 Flame 项目的时间调度器。
///
/// 支持：
/// - 延迟执行。
/// - 一次性执行。
/// - 无限循环执行。
/// - 指定执行次数。
/// - 任务取消。
/// - 任务暂停和恢复。
/// - 游戏时间缩放。
/// - 同一帧多个任务执行。
/// - 定时器执行过程中添加新任务。
enum ScheduleType {
  /// 一次性执行
  once,

  /// 重复执行
  repeat,
}

/// 调度任务
class ScheduledTask {
  final int id;
  final String name;

  /// 时间间隔 s
  final double interval;
  final ScheduleType type;

  /// [ScheduleType.repeat]最大执行次数
  final int? maxCount;
  final void Function(ScheduledTask task) callback;

  /// 任务经过的时间
  double elapsed = 0;

  /// 已经执行的次数
  int executeCount = 0;

  /// 任务是否取消 / 已完成
  bool cancelled = false;
  bool paused = false;

  ScheduledTask({
    required this.id,
    required this.name,
    required this.interval,
    required this.type,
    required this.callback,
    this.maxCount,
  });
}

/// 时间调度器
/// # 添加调度任务
/// - [TimeScheduler.delay] 延迟执行
/// - [TimeScheduler.every] 重复执行
/// # 驱动
/// - [TimeScheduler.update] 每帧更新
class TimeScheduler {
  final List<ScheduledTask> _tasks = [];

  int _nextId = 0;

  /// 游戏累计时间
  double elapsedTime = 0;

  /// 游戏时间缩放
  double timeScale = 1;

  bool paused = false;

  /// 延迟执行
  ScheduledTask delay(
    double seconds,
    void Function(ScheduledTask task) callback, {
    String name = '',
  }) {
    return _addTask(
      name: name,
      interval: seconds,
      type: .once,
      callback: callback,
    );
  }

  /// 每隔一段时间执行
  ScheduledTask every(
    double seconds,
    void Function(ScheduledTask task) callback, {
    String name = '',
    int? count,
  }) {
    return _addTask(
      name: name,
      interval: seconds,
      type: .repeat,
      callback: callback,
      maxCount: count,
    );
  }

  /// 内部创建任务
  ScheduledTask _addTask({
    required String name,
    required double interval,
    required ScheduleType type,
    required void Function(ScheduledTask task) callback,
    int? maxCount,
  }) {
    if (interval <= 0) {
      throw ArgumentError('interval 必须大于 0');
    }

    if (maxCount != null && maxCount <= 0) {
      throw ArgumentError('maxCount 必须大于 0');
    }

    final task = ScheduledTask(
      id: ++_nextId,
      name: name,
      interval: interval,
      type: type,
      callback: callback,
      maxCount: maxCount,
    );

    _tasks.add(task);

    return task;
  }

  /// 每帧更新
  void update(double dt) {
    if (paused) return;

    final gameDt = dt * timeScale;
    elapsedTime += gameDt;
    // 避免遍历过程中任务列表发生变化
    final snapshot = List<ScheduledTask>.of(_tasks);

    for (final task in snapshot) {
      if (task.cancelled || task.paused) {
        continue;
      }

      task.elapsed += gameDt;

      // 使用 while，处理一帧跨过多个时间间隔的情况
      while (task.elapsed >= task.interval && !task.cancelled && !task.paused) {
        task.elapsed -= task.interval;
        task.executeCount++;
        task.callback(task);

        // 一次性任务
        if (task.type == .once) {
          task.cancelled = true;
          break;
        }

        // 达到执行次数
        if (task.maxCount != null && task.executeCount >= task.maxCount!) {
          task.cancelled = true;
          break;
        }
      }
    }

    // 清理已结束任务
    _tasks.removeWhere((task) => task.cancelled);
  }

  /// 取消任务
  void cancel(ScheduledTask task) {
    task.cancelled = true;
  }

  /// 暂停任务
  void pauseTask(ScheduledTask task) {
    task.paused = true;
  }

  /// 恢复任务
  void resumeTask(ScheduledTask task) {
    task.paused = false;
  }

  /// 暂停所有任务
  void pause() {
    paused = true;
  }

  /// 恢复所有任务
  void resume() {
    paused = false;
  }

  /// 清除所有任务
  void clear() {
    _tasks.clear();
  }

  /// 当前任务数量
  int get taskCount => _tasks.length;
}
