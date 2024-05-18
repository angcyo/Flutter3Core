part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/09
///
/// ```
///  // Only allow a single ble operation to be underway at a time
///  MutexKey mtx = MutexKeyFactory.getMutexForKey("global");
///  await mtx.take();
///  try {
///     ...// critical section
///  } finally {
///    mtx.give();
///  }
/// ```
///
/// 互斥锁
/// [Mutex]
/// Create mutexes in a parallel-safe way,
class MutexKeyFactory {
  static final Map<String, MutexKey> _all = {};

  static MutexKey getMutexForKey(String key) {
    _all[key] ??= MutexKey();
    return _all[key]!;
  }
}

/// dart is single threaded, but still has task switching.
/// this mutex lets a single task through at a time.
class MutexKey {
  final StreamController _controller = StreamController.broadcast();
  int execute = 0;
  int issued = 0;

  Future<bool> take() async {
    int mine = issued;
    issued++;
    // tasks are executed in the same order they call take()
    while (mine != execute) {
      await _controller.stream.first; // wait
    }
    return true;
  }

  bool give() {
    execute++;
    _controller.add(null); // release waiting tasks
    return false;
  }
}
