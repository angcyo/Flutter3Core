part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/02
///
/// 全局常量
//region 全局常量

@dp
const double kS = 2;
const double kM = 4;
const double kL = 6;
const double kH = 8;
const double kX = 12;
const double kXh = 16;
const double kXx = 24;
const double kXxh = 32;
const double kXxx = 48;

/// 最小高度
/// [kMinInteractiveHeight]
const double kMinHeight = 28;

/// [kMinInteractiveDimension] 最小交互高度
const double kMinInteractiveHeight = 36;

/// 最小item交互高度
/// [kMinInteractiveHeight]
const double kMinItemInteractiveHeight = 40;

/// [kToolbarHeight]
/// [kInteractiveHeight]
const double kTabHeight = 46;
const double kTabItemHeight = 30;

/// 设计最佳最小交互高度
const double kInteractiveHeight = kMinItemInteractiveHeight;

/// 默认的模糊半径
const double kDefaultBlurRadius = 4.0;

/// 默认的高度
const double kDefaultElevation = 4.0;

const double kDefaultBorderRadius = 2.0;
const double kDefaultBorderRadiusL = 4.0;
const double kDefaultBorderRadiusH = 6.0;
const double kDefaultBorderRadiusX = 8.0;
const double kDefaultBorderRadiusXX = 12.0;
const double kDefaultBorderRadiusXXX = 24.0;

/// 最大圆角边框半径
const double kMaxBorderRadius = 45.0;

/// 情感图的默认的最大大小
const double kStateImageSize = 160.0;

/// [EdgeInsets.zero]
/// [kTabLabelPadding]
const kPaddingH = EdgeInsets.symmetric(horizontal: kH, vertical: kM);
const kPaddingX = EdgeInsets.symmetric(horizontal: kX, vertical: kL);

/// 是否是debug模式
/// 性能优化: https://juejin.cn/post/7066954522655981581
/// 性能检查视图: https://docs.flutter.dev/tools/devtools/inspector
///
/// ```
/// assert(() {
///   final List<DebugPaintCallback> localCallbacks = _debugPaintCallbacks.toList();
///   for (final DebugPaintCallback paintCallback in localCallbacks) {
///     if (_debugPaintCallbacks.contains(paintCallback)) {
///       paintCallback(context, offset, this);
///     }
///   }
///   return true;
/// }());
/// ```
/// [RenderView.paint]
/// [debugAddPaintCallback]
/// [isDebugFlag]
const bool isDebug = kDebugMode;

/// 随机数生成器
final random = math.Random();

/// 最小值/最大值
/// [double.maxFinite]
/// [9223372036854775807]
/// [intMax32Value]
/// [intMax64Value]
int intMaxValue = double.maxFinite.toInt();

/// [-9223372036854775807]
int intMinValue = -double.maxFinite.toInt();

/// 最小值/最大值
/// [1.7976931348623157e+308]
double doubleMaxValue = double.maxFinite;

///[-1.7976931348623157e+308]
double doubleMinValue = -double.maxFinite;

/// 32位整数最大值/最小值
const int intMax32Value = 2147483647;
const int intMin32Value = -2147483648;

/// 64位整数最大值/最小值
const int intMax64Value = 9223372036854775807;
const int intMin64Value = -9223372036854775807;

//endregion 全局常量

//region Fn Callback

/// 只有返回值的回调
typedef ResultCallback<T> = T Function();

/// 返回值和一个参数的回调
typedef ResultValueCallback<R, T> = R Function(T value);

/// [Future] 返回值的回调
typedef FutureResultCallback<R, T> = Future<R> Function(T value);

/// 只有一个值回调
typedef ValueCallback<T> = dynamic Function([T value]);

/// [ValueCallback]
/// [FutureOr]
typedef FutureValueCallback<T> = FutureOr<T> Function([T value]);

/// 回调一个值和一个错误
typedef ValueErrorCallback = dynamic Function(dynamic value, dynamic error);

/// 进度回调
/// [count] 已发送的数据量
/// [total] 总数据量, 有可能为0
typedef ProgressAction = void Function(int count, int total);

/// 进度回调[0~1]
typedef ProgressRatioCallback = void Function(double progress);

//endregion Fn
