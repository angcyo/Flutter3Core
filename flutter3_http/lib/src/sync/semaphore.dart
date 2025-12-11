///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// sync: ^0.3.0
/// - https://pub.dev/packages/sync
/// - Mutex & ReadWriteMutex  互斥锁和读写互斥锁
/// - Semaphore  信号
/// - WaitGroup  候补组
///
/// ```
/// final semaphore = Semaphore(simultaneousUploads);
/// await semaphore.acquire();
/// semaphore.release();
/// ```
///
/// synchronized: ^3.4.0
/// - https://pub.dev/packages/synchronized
/// - 基本的锁定机制，用于防止并发访问异步代码。
///
/// ```
/// var lock = new Lock(reentrant: true);
/// // ...
/// await lock.synchronized(() async {
///   // do some stuff
///   // ...
///
///   await lock.synchronized(() async {
///     // other stuff
///   }
/// });
/// ```
///
import "dart:async";
import "dart:collection";

/// A Semaphore class.
class Semaphore {
  final int maxCount;

  int _counter = 0;
  final Queue<Completer> _waitQueue = Queue<Completer>();

  Semaphore([this.maxCount = 1]) {
    if (maxCount < 1) {
      throw RangeError.value(maxCount, "maxCount");
    }
  }

  /// Acquires a permit from this semaphore, asynchronously blocking until one
  /// is available.
  Future acquire() {
    final completer = Completer();
    if (_counter + 1 <= maxCount) {
      _counter++;
      completer.complete();
    } else {
      _waitQueue.add(completer);
    }
    return completer.future;
  }

  /// Releases a permit, returning it to the semaphore.
  void release() {
    if (_counter == 0) {
      throw StateError("Unable to release semaphore.");
    }
    _counter--;
    if (_waitQueue.isNotEmpty) {
      _counter++;
      final completer = _waitQueue.removeFirst();
      completer.complete();
    }
  }
}
