part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/09
///
/// 支持存储最后一个值的[StreamController], 广播流
/// 支持自动清理
/// 支持错误状态存储
class LiveStreamController<T> {
  /// 是否自动清空最后一个值
  @configProperty
  bool autoClearValue = false;

  /// 如果上一次是null, 这一次也是null, 是否还要通知?
  @configProperty
  bool ignoreLastNullNotify = true;

  /// 当有值更新时, 会调用此方法
  @configProperty
  ValueCallback<T>? onUpdateValueAction;

  //--

  /// 最后一个值
  @output
  T latestValue;

  /// 最后一个错误, 在每次[add]时, 清空
  @output
  Object? latestError;

  //--

  final StreamController<T> controller = StreamController<T>.broadcast();

  LiveStreamController(
    T initialValue, {
    this.autoClearValue = false,
    this.onUpdateValueAction,
  }) : latestValue = initialValue;

  /// 流
  Stream<T> get stream {
    if (latestValue != null) {
      return controller.stream.newStreamWithInitialValue(latestValue!);
    } else {
      return controller.stream;
    }
  }

  /// 获取当前最新的值
  T get value => latestValue;

  /// 获取当前最新的错误
  Object? get error => latestError;

  /// 是否有错误
  bool get hasError => latestError != null;

  /// 是否为空
  bool get isEmpty => latestValue == null || isNil(latestValue);

  @callPoint
  void updateValue(T newValue) {
    add(newValue);
  }

  /// 发送数据
  @callPoint
  void add(T newValue) {
    latestError = null;
    if (ignoreLastNullNotify && latestValue == null && newValue == null) {
      return;
    }
    latestValue = newValue;
    onValueChanged(newValue);
    controller.add(newValue);
    try {
      onUpdateValueAction?.call(newValue);
    } catch (e) {
      assert(() {
        print(e);
        return true;
      }());
    }
    if (autoClearValue) {
      try {
        dynamic clear;
        latestError = null;
        latestValue = clear;
        onValueChanged(clear);
        controller.add(clear);
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
      }
    }
  }

  /// 当值改变后触发
  @overridePoint
  void onValueChanged(T value) {}

  /// 使用最后一次的[value]进行通知
  @callPoint
  void notify() {
    add(latestValue);
  }

  /// 发送错误事件
  @callPoint
  void addError(Object error) {
    latestError = error;
    controller.addError(error);
  }

  /// 监听流
  /// [allowBackward] 是否允许回溯, 是否发送最后一个值
  /// [autoCancel] 当[onData]返回true时, 是否自动取消监听
  @callPoint
  StreamSubscription<T> listen(
    dynamic Function(T data) onData, {
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
      subscription = controller.stream.listen(
        (event) async {
          final cancel = await onData(event);
          if (cancel is bool && cancel) {
            //debugger();
            subscription?.cancel();
          }
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
      return subscription;
    } else {
      return controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    }
  }

  /// 清空数据
  void clear() {
    dynamic clear;
    add(clear);
  }

  /// 关闭流, 关闭之后不能调用[add]方法
  @callPoint
  Future<void> close() {
    return controller.close();
  }

  //--

  /// 如果[latestValue]是一个[List]类型, 则塞到[latestValue]中
  @callPoint
  void addSub(dynamic subValue) {
    if (latestValue is List) {
      (latestValue as List).add(subValue);
      add(latestValue);
    } else {
      assert(() {
        l.w("无效的[addSub]操作, 之前的数据类型不是[List]->${latestValue?.runtimeType}");
        return true;
      }());
    }
  }

  /// [addSub]
  @callPoint
  void removeSub(dynamic subValue) {
    if (latestValue is List) {
      (latestValue as List).remove(subValue);
      add(latestValue);
    } else {
      assert(() {
        l.w("无效的[removeSub]操作, 之前的数据类型不是[List]->${latestValue?.runtimeType}");
        return true;
      }());
    }
  }

  /// [addSub]
  @callPoint
  bool haveSubValue(dynamic subValue) {
    if (latestValue is List) {
      return (latestValue as List).contains(subValue);
    }
    return false;
  }
}

/// 用来调试
class DebugLiveStreamController<T> extends LiveStreamController<T> {
  DebugLiveStreamController(super.initialValue, {super.autoClearValue});

  @override
  void add(T newValue) {
    debugger();
    super.add(newValue);
  }

  @override
  void addError(Object error) {
    debugger();
    super.addError(error);
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

/// [ListenableMixin]
/// [StreamSubscriptionMixin]
mixin StreamSubscriptionMixin<T extends StatefulWidget> on State<T> {
  @autoDispose
  final List<StreamSubscription> _streamSubscriptions = [];

  /// 在[dispose]时, 取消所有的[StreamSubscription]
  @api
  @autoDispose
  void hookStreamSubscription(StreamSubscription? subscription) {
    if (subscription == null) return;
    _streamSubscriptions.add(subscription);
  }

  @override
  void dispose() {
    try {
      for (final element in _streamSubscriptions) {
        try {
          element.cancel();
        } catch (e) {
          printError(e);
        }
      }
    } finally {
      _streamSubscriptions.clear();
    }
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

/// 别名
typedef LiveStream<T> = LiveStreamController<T>;

/// [LiveStreamController]
LiveStream<T?> $live<T>([T? initialValue, bool autoClearValue = false]) =>
    LiveStream<T?>(initialValue, autoClearValue: autoClearValue);

/// [LiveStreamController]
LiveStream<T?> $liveOnce<T>([T? initialValue, bool autoClearValue = true]) =>
    LiveStream<T?>(initialValue, autoClearValue: autoClearValue);

extension LiveStreamControllerEx<T> on LiveStreamController<T> {
  /// [RebuildWidget]
  Widget build(
    DynamicDataWidgetBuilder builder, {
    bool allowBackward = true,
  }) =>
      StreamBuilder(
          stream: stream,
          initialData: allowBackward ? latestValue : null,
          builder: (context, snapshot) {
            return builder(context, snapshot.data) ?? empty;
          });

  /// [RebuildWidget]
  ///
  /// [RebuildEx.buildFn]
  Widget buildFn(
    Widget? Function() builder, {
    bool allowBackward = true,
  }) =>
      StreamBuilder(
          stream: stream,
          initialData: allowBackward ? latestValue : null,
          builder: (_, __) {
            return builder() ?? empty;
          });

  /// [RebuildWidget]
  ///
  /// [RebuildEx.buildDataFn]
  Widget buildDataFn(
    Widget? Function(T? data) builder, {
    bool allowBackward = true,
  }) =>
      StreamBuilder(
          stream: stream,
          initialData: allowBackward ? latestValue : null,
          builder: (_, snapshot) {
            return builder(snapshot.data) ?? empty;
          });
}

extension LiveStreamControllerIterableEx<T>
    on Iterable<LiveStreamController<T>> {
  /// [StreamGroup]
  /// [StreamZip]
  ///
  /// [RebuildWidget]
  ///
  /// [RebuildIterableEx.buildFn]
  /// [LiveStreamControllerIterableEx.buildFn]
  Widget buildFn(Widget? Function() builder) => StreamBuilder(
      stream: StreamGroup.mergeBroadcast(map((e) => e.stream)),
      initialData: null,
      builder: (_, __) {
        return builder() ?? empty;
      });
}
