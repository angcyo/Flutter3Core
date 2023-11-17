part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

MutableLiveData<T?> vmData<T>([T? value]) => MutableLiveData<T?>(value);

MutableOnceLiveData<T?> vmDataOnce<T>([T? value]) =>
    MutableOnceLiveData<T?>(value);
