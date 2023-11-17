part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 数值只保留一次, 在set之后, 立即置空
class MutableOnceLiveData<T> extends MutableLiveData<T?> {
  MutableOnceLiveData(super.currentValue);

  final Set<LiveDataObserver<T>> _observers = {};

  @override
  void observe(LiveDataObserver<T?> observer, {bool emitCurrentValue = true}) {
    _observers.add(observer);
    super.observe(observer, emitCurrentValue: emitCurrentValue);
  }

  @override
  void removeObserver(LiveDataObserver<T?> observer) {
    _observers.remove(observer);
    super.removeObserver(observer);
  }

  @override
  set value(T? value) {
    super.value = value;
    postCallback(() {
      if (value != null && _observers.isNotEmpty) {
        super.value = null;
      }
    });
  }
}
