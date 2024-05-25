part of '../../flutter3_core.dart';

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

  MutableErrorLiveData(super.currentValue);

  @override
  set value(T? value) {
    if (value != null) {
      // 清空错误信息
      error = null;
    }
    super.value = value;
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
        if (observers.isNotEmpty) {
          super.value = null;
        }
      });
    }
  }
}
