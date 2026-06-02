part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/04
///
/// 任务队列, 避免多个任务同时执行, 按照顺序执行
/// - 一个一个执行
class TaskQueue {
  /// 待执行的队列
  /// - tag / uuid
  final List<String> _queue = [];

  /// 待执行的任务
  final _taskMap = <String, TaskQueueAction?>{};

  /// 待执行的任务数据
  final _taskDataMap = <String, dynamic>{};

  /// 当前正在执行的任务tag
  final taskTagLive = $live<String?>();

  /// 当前正在执行的任务data
  final taskDataLive = $live<dynamic>();

  TaskQueue();

  /// 批量入队, 并等待执行
  /// - [next] 开始执行
  @api
  void enqueueList(
    List? list, {
    //是否立即执行
    bool execute = true,
  }) {
    if (list == null || list.isEmpty) {
      return;
    }
    for (final item in list) {
      enqueue(null, data: item, execute: false);
    }
    if (execute) {
      next();
    }
  }

  /// 入队并执行
  /// - 如果队列中有任务正在执行, 则等待执行完毕
  /// - 如果队列中没有任务正在执行, 则立即执行
  ///
  /// - [tag] 任务的tag, 用于移除任务[remove]
  /// - [index] 插入的位置, 默认为队列末尾
  /// @return 任务的tag
  @api
  String enqueue<T>(
    TaskQueueAction? task, {
    String? tag,
    int? index,
    dynamic data,
    //是否立即执行
    bool execute = true,
  }) {
    tag ??= $uuid;
    _taskMap[tag] = task;
    _taskDataMap[tag] = data;
    if (_queue.isEmpty) {
      _queue.add(tag);
    } else {
      if (index != null) {
        _queue.insert(index, tag);
      } else {
        _queue.add(tag);
      }
    }
    if (execute) {
      next();
    }
    return tag;
  }

  @api
  void remove(String? tag) {
    _queue.remove(tag);
    _taskMap.remove(tag);
  }

  /// 手动触发下一个任务
  @api
  void next() {
    if (_isRunning) {
      return;
    }
    final tag = taskTagLive.value;
    taskTagLive << null;
    taskDataLive << null;
    remove(tag);
    _execute();
  }

  /// 清空队列
  @api
  void clear() {
    _isRunning = false;
    _queue.clear();
    _taskMap.clear();
    _taskDataMap.clear();
    taskTagLive << null;
    taskDataLive << null;
  }

  //MARK: - inner

  bool _isRunning = false;

  /// 执行队列中的任务
  void _execute() async {
    final tag = _queue.firstOrNull;
    if (tag == null || _isRunning) {
      return;
    }
    final data = _taskDataMap[tag];
    taskTagLive << tag;
    taskDataLive << data;
    final task = _taskMap[tag];
    if (task != null) {
      //自动执行任务
      try {
        _isRunning = true;
        await task(data);
      } catch (e, stack) {
        assert(() {
          l.w('$tag execute error: $e\n$stack');
          return true;
        }());
      } finally {
        _isRunning = false;
        taskTagLive << null;
        taskDataLive << null;
      }
      remove(tag);
      _execute();
    } else {
      //no op 需要手动调用 [next]
    }
  }
}

/// 队列执行的任务
typedef TaskQueueAction<R, D> = FutureOr<R?> Function(D? data);

/// [GlobalQueue]的实例
@globalInstance
final $globalQueue = TaskQueue();
