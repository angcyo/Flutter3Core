part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/09
///
/// 支持存储最后一个值的[StreamController], 广播流
/// 支持自动清理
/// 支持错误状态存储
class LiveStreamController<T> {
  /// 最后一个值
  T latestValue;

  /// 最后一个错误, 在每次[add]时, 清空
  Object? latestError;

  /// 是否自动清空最后一个值
  bool autoClearValue = false;

  final StreamController<T> _controller = StreamController<T>.broadcast();

  LiveStreamController(T initialValue, {this.autoClearValue = false})
      : latestValue = initialValue;

  /// 流
  Stream<T> get stream {
    if (latestValue != null) {
      return _controller.stream.newStreamWithInitialValue(latestValue!);
    } else {
      return _controller.stream;
    }
  }

  /// 获取当前最新的值
  T get value => latestValue;

  /// 获取当前最新的错误
  Object? get error => latestError;

  /// 发送数据
  @callPoint
  void add(T newValue) {
    latestError = null;
    latestValue = newValue;
    _controller.add(newValue);
    if (autoClearValue) {
      try {
        dynamic clear;
        latestError = null;
        latestValue = clear;
        _controller.add(clear);
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
      }
    }
  }

  /// 发送错误事件
  @callPoint
  void addError(Object error) {
    latestError = error;
    _controller.addError(error);
  }

  /// 监听流
  /// [allowBackward] 是否允许回溯, 是否发送最后一个值
  /// [autoCancel] 当[onData]返回true时, 是否自动取消监听
  @callPoint
  StreamSubscription<T> listen(
    Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    bool allowBackward = true,
    bool autoCancel = false,
  }) {
    if (!autoClearValue && allowBackward) {
      onData(latestValue);
    }
    if (autoCancel) {
      StreamSubscription<T>? subscription;
      subscription = _controller.stream.listen((event) async {
        final cancel = await onData(event);
        if (cancel) {
          subscription?.cancel();
        }
      }, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
      return subscription;
    } else {
      return _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    }
  }

  /// 关闭流, 关闭之后不能调用[add]方法
  @callPoint
  Future<void> close() {
    return _controller.close();
  }
}

// Helper for 'newStreamWithInitialValue' method for streams.
class _NewStreamWithInitialValueTransformer<T>
    extends StreamTransformerBase<T, T> {
  /// the initial value to push to the new stream
  final T initialValue;

  /// controller for the new stream
  late StreamController<T> controller;

  /// subscription to the original stream
  late StreamSubscription<T> subscription;

  /// new stream listener count
  var listenerCount = 0;

  _NewStreamWithInitialValueTransformer(this.initialValue);

  @override
  Stream<T> bind(Stream<T> stream) {
    if (stream.isBroadcast) {
      return _bind(stream, broadcast: true);
    } else {
      return _bind(stream);
    }
  }

  Stream<T> _bind(Stream<T> stream, {bool broadcast = false}) {
    /////////////////////////////////////////
    /// Original Stream Subscription Callbacks
    ///

    /// When the original stream emits data, forward it to our new stream
    void onData(T data) {
      controller.add(data);
    }

    /// When the original stream is done, close our new stream
    void onDone() {
      controller.close();
    }

    /// When the original stream has an error, forward it to our new stream
    void onError(Object error) {
      controller.addError(error);
    }

    /// When a client listens to our new stream, emit the
    /// initial value and subscribe to original stream if needed
    void onListen() {
      // Emit the initial value to our new stream
      controller.add(initialValue);

      // listen to the original stream, if needed
      if (listenerCount == 0) {
        subscription = stream.listen(
          onData,
          onError: onError,
          onDone: onDone,
        );
      }

      // count listeners of the new stream
      listenerCount++;
    }

    //////////////////////////////////////
    ///  New Stream Controller Callbacks
    ///

    /// (Single Subscription Only) When a client pauses
    /// the new stream, pause the original stream
    void onPause() {
      subscription.pause();
    }

    /// (Single Subscription Only) When a client resumes
    /// the new stream, resume the original stream
    void onResume() {
      subscription.resume();
    }

    /// Called when a client cancels their
    /// subscription to the new stream,
    void onCancel() {
      // count listeners of the new stream
      listenerCount--;

      // when there are no more listeners of the new stream,
      // cancel the subscription to the original stream,
      // and close the new stream controller
      if (listenerCount == 0) {
        subscription.cancel();
        controller.close();
      }
    }

    //////////////////////////////////////
    /// Return New Stream
    ///

    // create a new stream controller
    if (broadcast) {
      controller = StreamController<T>.broadcast(
        onListen: onListen,
        onCancel: onCancel,
      );
    } else {
      controller = StreamController<T>(
        onListen: onListen,
        onPause: onPause,
        onResume: onResume,
        onCancel: onCancel,
      );
    }

    return controller.stream;
  }
}

extension _StreamNewStreamWithInitialValue<T> on Stream<T> {
  Stream<T> newStreamWithInitialValue(T initialValue) {
    return transform(_NewStreamWithInitialValueTransformer(initialValue));
  }
}

mixin StreamSubscriptionMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _streamSubscriptions = [];

  hookStreamSubscription(StreamSubscription subscription) {
    _streamSubscriptions.add(subscription);
  }

  @override
  void dispose() {
    for (var element in _streamSubscriptions) {
      element.cancel();
    }
    _streamSubscriptions.clear();
    super.dispose();
  }
}

extension StreamSubscriptionEx<T> on StreamSubscription<T> {
  /// 取消订阅
  void cancelWhen(StreamSubscription? other) {
    other?.onDone(() {
      cancel();
    });
  }
}
