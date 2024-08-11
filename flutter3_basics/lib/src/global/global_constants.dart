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

/// 最小交互高度
/// [kMinInteractiveDimension] 系统48
const double kMinInteractiveHeight = 38;

/// 最小item交互高度
/// [kMinInteractiveHeight]
const double kMinItemInteractiveHeight = 40;

/// [kToolbarHeight] - 56
/// [kInteractiveHeight] - 40
const double kTabHeight = 46;
const double kTabItemHeight = 30;
const double kTitleHeight = 56;

/// 标题栏中item的交互高度
const double kTitleItemInteractiveHeight = 56;

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

//--

/// [EdgeInsets.zero]
/// [kTabLabelPadding]
const kPaddingH = EdgeInsets.symmetric(horizontal: kH, vertical: kM);
const kPaddingX = EdgeInsets.symmetric(horizontal: kX, vertical: kL);
const kXSymInsets = kPaddingX;
const kHSymInsets = kPaddingH;

const kXInsets = EdgeInsets.all(kX);
const kHInsets = EdgeInsets.all(kH);

//--

/// 默认的滚动物理特性/滚动行为
const kScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

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
