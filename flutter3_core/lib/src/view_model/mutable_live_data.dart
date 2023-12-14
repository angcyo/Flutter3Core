part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 支持错误信息的[LiveData]
class MutableErrorLiveData<T> extends MutableLiveData<T?> {
  /// 错误信息
  Object? _error;

  Object? get error => _error;

  set error(Object? value) {
    _error = value;
    //this.value = null; //清空数据, 触发通知
    notifyObservers();
  }

  final Set<LiveDataObserver<T?>> _observers = {};

  MutableErrorLiveData(super.currentValue);

  @override
  set value(T? value) {
    if (value != null) {
      // 清空错误信息
      error = null;
    }
    super.value = value;
  }

  @override
  void observe(LiveDataObserver<T?> observer, {bool emitCurrentValue = true}) {
    _observers.add(observer);
    super.observe(observer, emitCurrentValue: emitCurrentValue);
    if (emitCurrentValue) {
      observer(value);
    }
  }

  @override
  void removeObserver(LiveDataObserver<T?> observer) {
    _observers.remove(observer);
    super.removeObserver(observer);
  }

  void notifyObservers() {
    // copying to allow for observers to call `removeObserver` during iteration
    final observersToNotify = Set.of(_observers);
    for (final LiveDataObserver<T> observer in observersToNotify) {
      observer(value as T);
    }
  }
}

/// 数值只保留一次, 在set之后, 立即置空
class MutableOnceLiveData<T> extends MutableErrorLiveData<T?> {
  MutableOnceLiveData(super.currentValue);

  @override
  set value(T? value) {
    super.value = value;
    if (value != null) {
      postCallback(() {
        if (_observers.isNotEmpty) {
          super.value = null;
        }
      });
    }
  }
}
