part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/02
///
/// 全局常量
//region 全局常量

/// xs sm md lg xl xxl
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

/// 鼠标的宽度
/// macOS - 15
/// [dpr]
@dp
const double kMouseWidth = 15;

/// 鼠标的高度
/// macOS - 20
/// [dpr]
@dp
const double kMouseHeight = 20;

/// 最小高度
/// [kMinInteractiveHeight]
const double kMinHeight = 28;

/// 最小交互高度
/// 系统[kMinInteractiveDimension] - 48
const double kMinInteractiveHeight = 38;

/// 最小交互高度, 系统默认48
const double kButtonHeight = 45;

/// 最小item交互高度
/// [kMinInteractiveHeight]
const double kMinItemInteractiveHeight = 40;

/// 系统[kToolbarHeight] - 56
/// 系统[kInteractiveHeight] - 40
const double kTabHeight = 46;
const double kTabItemHeight = 30;
const double kTitleHeight = 56;
const double kDesktopTitleHeight = 38;

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

const kLabelMinWidth = 80.0;
const kLabelMaxWidth = 130.0;
const kNumberMinWidth = 50.0;
const kNumberMinHeight = 26.0;
const kMenuMinWidth = 160.0;

/// 系统[Dialog]最小宽度280.0
/// - [Dialog.build] 代码中写死了最小宽度
const kDialogMinWidth = 280.0;

/// 桌面[Dialog]最小宽度
@desktopLayout
const kDesktopDialogMinWidth = kDialogMinWidth * 2;

/// 桌面弹窗的宽度
@desktopLayout
const kDesktopPopupWidth = kDialogMinWidth;

//--

/// [EdgeInsets.zero]
/// [kTabLabelPadding]
const kPaddingH = EdgeInsets.symmetric(horizontal: kH, vertical: kM);
const kPaddingX = EdgeInsets.symmetric(horizontal: kX, vertical: kL);
const kXSymInsets = kPaddingX;
const kHSymInsets = kPaddingH;

const kSInsets = EdgeInsets.symmetric(horizontal: kS, vertical: kS);
const kMInsets = EdgeInsets.symmetric(horizontal: kM, vertical: kM);
const kHInsets = EdgeInsets.all(kH);
const kXInsets = EdgeInsets.all(kX);
const kXhInsets = EdgeInsets.all(kXh);

//--

/// 阴影的颜色
/// [Colors.black]
const Color kShadowColor = Color(0x0D000000);

/// 阴影的偏移量
const Offset kShadowOffset = Offset(1, 4);

/// 向上偏移的阴影
const Offset kShadowOffsetTop = Offset(0, -4);

/// [BoxShadow] 阴影
const BoxShadow kBoxShadow = BoxShadow(
  color: kShadowColor,
  offset: kShadowOffset, //阴影y轴偏移量
  blurRadius: kDefaultBlurRadius, //阴影模糊程度
  spreadRadius: kS, //阴影扩散程度
);

/// [kBoxShadow]
const BoxShadow kBoxShadowTop = BoxShadow(
  color: kShadowColor,
  offset: kShadowOffsetTop,
  blurRadius: kDefaultBorderRadiusXX,
  spreadRadius: kH,
);

//--

/// 默认的滚动物理特性/滚动行为
///
/// - [ClampingScrollPhysics] 滚动到边缘, 停止滚动
/// - [AlwaysScrollableScrollPhysics] 滚动到边缘, 允许继续滚动
/// - [BouncingScrollPhysics] 滚动到边缘, 允许继续滚动, 弹簧效果
///
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
