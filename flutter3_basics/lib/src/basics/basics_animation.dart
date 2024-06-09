part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///
/// 动画相关小部件
/// [ShaderMask]->[ShaderMaskLayer]着色器,遮罩. 可以实现闪光灯效果 https://pub.dev/packages/shimmer
/// - [WheelPicker]
/// - [_WheelPickerState._centerColorShaderMaskWrapper]
/// - [flutter_animate]
/// - [ShimmerEffect]
///
/// [ColorFiltered] 颜色过滤器. 可以实现黑白/灰度效果
/// - [WidgetEx.colorFiltered]
///
/// [ImageFilter] 图片过滤器. 可以实现高斯模糊效果

/// 默认的动画时长
/// [kTabScrollDuration]
const kDefaultAnimationDuration = Duration(milliseconds: 300);

/// 慢的动画时长
const kDefaultSlowAnimationDuration = Duration(milliseconds: 3000);

extension AnimationEx on Animation {
  /// 动画是否开始了
  bool get isStarted =>
      status == AnimationStatus.forward || status == AnimationStatus.reverse;

  /// 动画是否结束了
  bool get isStopped =>
      status == AnimationStatus.completed ||
      status == AnimationStatus.dismissed;
}

extension AnimationWidgetEx on Widget {
  /// 透明度动画, 渐隐动画.
  /// [out] fade out or fade in
  Widget fade({
    Animation<double>? opacity,
    bool out = false,
  }) {
    return FadeTransition(
      opacity: opacity ??
          Tween(begin: out ? 1.0 : 0.0, end: out ? 0.0 : 1.0).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(out ? 0 : 1),
              curve: Curves.easeIn,
            ),
          ),
      child: this,
    );
  }

  /// 滑动动画
  Widget slide({
    Animation<Offset>? offset,
    Offset? from,
    Offset? to,
    bool out = false,
  }) {
    return SlideTransition(
      position: offset ??
          Tween<Offset>(
            begin: from ?? (out ? Offset.zero : const Offset(0, 1)),
            end: to ?? (out ? const Offset(0, 1) : Offset.zero),
          ).animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(out ? 0 : 1),
            curve: Curves.easeIn,
          )),
      child: this,
    );
  }

  /// 旋转动画
  Widget rotation({
    Animation<double>? rotate,
    double? from,
    double? to,
    bool out = false,
  }) {
    return RotationTransition(
      turns: rotate ??
          Tween(
            begin: from ?? (out ? 360 : 0),
            end: to ?? (out ? 360 : 0),
          ).animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(out ? 0 : 360),
            curve: Curves.easeIn,
          )),
      child: this,
    );
  }

  /// 不透明动画, 不需要动画控制
  /// [AnimatedContainer]
  /// [AnimatedOpacity]
  Widget animatedOpacity({required double opacity}) => AnimatedOpacity(
        opacity: opacity,
        duration: kDefaultAnimationDuration,
        child: this,
      );

  /// 动画切换2个[Widget].[AnimatedSwitcher]
  Widget animatedSwitcher({
    Key? key,
    Duration? duration,
    Duration? reverseDuration,
    Curve switchInCurve = Curves.linear,
    Curve switchOutCurve = Curves.linear,
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
    AnimatedSwitcherLayoutBuilder layoutBuilder =
        AnimatedSwitcher.defaultLayoutBuilder,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: duration ?? kDefaultAnimationDuration,
      reverseDuration: reverseDuration,
      transitionBuilder: transitionBuilder,
      layoutBuilder: layoutBuilder,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      child: this,
    );
  }
}

/// 创建一个控制动画, 指定时间
/// 在指定的时间内, 从[0~1]的动画变化回调
/// [value] 初始值
/// [lowerBound] 最小值
/// [upperBound] 最大值
/// [curve] 动画曲线
/// [AnimationController.stop] 停止动画
/// [AnimationController.dispose] 释放资源
AnimationController animation(
  TickerProvider vsync,
  void Function(double value, bool isCompleted) listener, {
  Duration duration = kDefaultAnimationDuration,
  double? value,
  double lowerBound = 0.0,
  double upperBound = 1.0,
  Curve? curve,
  Curve? reverseCurve,
}) {
  final controller = AnimationController(
    value: value,
    lowerBound: lowerBound,
    upperBound: upperBound,
    duration: duration,
    vsync: vsync,
  );

  //动画曲线
  final CurvedAnimation? animation = curve == null
      ? null
      : CurvedAnimation(
          parent: controller, curve: curve, reverseCurve: reverseCurve);

  //监听动画值变化
  controller
    ..addListener(() {
      assert(() {
        // [0~1] 变化
        //l.d('动画值改变: ${controller.value}');
        return true;
      }());
      listener(animation?.value ?? controller.value, false);
    })
    ..addStatusListener((status) {
      assert(() {
        //AnimationStatus.forward -> AnimationStatus.completed
        l.d('动画状态改变: $status');
        return true;
      }());
      listener(animation?.value ?? controller.value,
          status == AnimationStatus.completed);
    })
    ..forward();
  //释放资源
  //controller.dispose();
  return controller;
}
