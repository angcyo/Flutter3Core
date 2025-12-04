part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/04
///
/// 全局队列, 避免多个任务同时执行, 按照顺序执行
class GlobalQueue {
  /// 待执行的队列
  final List<String> _queue = [];

  /// 待执行的任务
  final _taskMap = <String, GlobalQueueTask>{};

  GlobalQueue();

  /// 入队并执行
  /// - 如果队列中有任务正在执行, 则等待执行完毕
  /// - 如果队列中没有任务正在执行, 则立即执行
  ///
  /// - [tag] 任务的tag, 用于移除任务[remove]
  /// - [index] 插入的位置, 默认为队列末尾
  /// @return 任务的tag
  @api
  String enqueue<T>(GlobalQueueTask task, {String? tag, int? index}) {
    tag ??= $uuid;
    _taskMap[tag] = task;
    if (_queue.isEmpty) {
      _queue.add(tag);
      _execute();
    } else {
      if (index != null) {
        _queue.insert(index, tag);
      } else {
        _queue.add(tag);
      }
    }
    return tag;
  }

  @api
  void remove(String tag) {
    _queue.remove(tag);
    _taskMap.remove(tag);
  }

  //MARK: - inner

  /// 执行队列中的任务
  void _execute() async {
    final tag = _queue.firstOrNull;
    if (tag == null) {
      return;
    }
    final task = _taskMap[tag];
    if (task != null) {
      try {
        await task();
      } catch (e, stack) {
        assert(() {
          l.w('$tag execute error: $e\n$stack');
          return true;
        }());
      }
    }
    remove(tag);
    _execute();
  }
}

/// 队列执行的任务
typedef GlobalQueueTask<T> = FutureOr<T> Function();

/// [GlobalQueue]的实例
@globalInstance
final $globalQueue = GlobalQueue();
