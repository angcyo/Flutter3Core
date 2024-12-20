part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///

//region Fn Callback

typedef Action = VoidCallback;
typedef VoidAction = Action;

/// [Action]
/// [VoidAction]
/// [VoidCallback]
typedef ClickAction = void Function(BuildContext context);

/// 国际化文本构建器
typedef IntlTextBuilder = String Function(BuildContext context);

/// [VoidAction]
typedef FutureVoidAction = FutureOr Function();

/// [BoolCallback]
typedef FutureBoolAction = FutureOr Function(bool value);

/// 回调一个错误, 没错误就是null
typedef ErrorAction = void Function(dynamic error);

/// 只有返回值的回调
typedef ResultCallback<T> = T Function();

/// 返回值和一个参数的回调
typedef ResultValueCallback<R, T> = R Function(T value);

/// [Future] 返回值的回调
typedef FutureResultCallback<R, T> = Future<R> Function(T value);

/// [FutureOr] 返回值的回调
typedef FutureOrResultCallback<R, T> = FutureOr<R> Function(T value);

/// 只有一个值回调
typedef ValueCallback<T> = dynamic Function(T value);

/// [ValueChanged]
typedef ContextValueChanged<T> = void Function(BuildContext context, T value);

/// 两个值改变回调
/// [ValueChanged]
typedef DoubleValueChanged<T1, T2> = void Function(T1 value1, T2 value2);

/// [ValueCallback]
/// [FutureOr]
typedef FutureValueCallback<T> = FutureOr Function(T value);

/// 回调一个值和一个错误
typedef ValueErrorCallback = dynamic Function(dynamic value, dynamic error);

/// 进度回调
/// [count] 已发送的数据量
/// [total] 总数据量, 有可能为0
/// [ProgressCallback]
typedef ProgressAction = void Function(int count, int total);

/// 发送数据的进度回调, 通常发送的字节数据, 参数就是字节的长度
/// [ProgressAction]
typedef ProgressDataAction = void Function(DataChunkInfo chunkInfo);

/// 进度回调[0~1]
typedef ProgressRatioCallback = void Function(double progress);

/// 索引类型的回调
typedef IndexCallback = void Function(int index);

/// [num]数字类型的回调
typedef NumCallback = void Function(num number);
typedef NumNullCallback = void Function(num? number);
typedef ContextNumNullCallback = void Function(
    BuildContext? context, num? number);
typedef RangeNumCallback = void Function(num startValue, num endValue);

/// [bool]类型的回调
typedef BoolCallback = void Function(bool value);

/// [Duration]类型的回调
typedef DurationCallback = void Function(Duration value);

/// [Offset]类型的回调
typedef OffsetCallback = void Function(Offset offset);

/// [String]类型的回调
typedef StringCallback = void Function(String text);

/// 转变一个[widget]
typedef TransformWidgetBuilder = Widget Function(
    BuildContext context, Widget widget);

/// 转变一个[widget], 携带一个[data]参数
typedef TransformDataWidgetBuilder = Widget Function(
    BuildContext context, Widget widget, dynamic data);

/// [TransformWidgetBuilder] 的支持null版本
typedef TransformChildWidgetBuilder = Widget? Function(
    BuildContext context, Widget? child);

/// [TransformDataWidgetBuilder] 的支持null版本
typedef TransformChildDataWidgetBuilder = Widget? Function(
    BuildContext context, Widget? child, dynamic data);

/// 支持返回null的[WidgetBuilder]
typedef WidgetNullBuilder = Widget? Function(BuildContext context);

/// [RoutePageBuilder]
/// [ModalRoute.buildTransitions]
/// [RouteTransitionsBuilder]
///
/// [child] 用来传递不需要重新build的[Widget].
/// 此方法里面只rebuild动画处理相关的[Widget].
///
typedef TransitionsBuilder = Widget Function(
    BuildContext context, Animation<double> animation, Widget? child);

/// [WidgetBuilder]
typedef ChildrenBuilder = List<Widget>? Function(BuildContext context);

/// [IndexedWidgetBuilder]
typedef IndexChildrenBuilder = List<Widget>? Function(
    BuildContext context, int index);

//endregion Fn
