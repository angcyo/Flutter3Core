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
///
/// # [AnimationController].[Tween].[Animation]关系
/// [AnimationController] 动画控制器, 可被监听
/// [Animatable]->[Tween]/[CurveTween] 动画插值对象, 修改动画过程的值 [Animatable.animate]
/// [Animation]->[CurvedAnimation]/[AnimationController] 动画对象, 可被监听, 动画过程中的值
/// ```
/// // 1.创建一个动画控制器AnimationController
/// late final AnimationController controller = AnimationController(
///   vsync: this,
///   duration: widget.duration,
///   reverseDuration: widget.duration,
/// );
///
/// // 2. 创建一个动画插值对象Tween
/// late final Animation<double> animation = Tween<double>(begin: 0, end: 360).animate(CurvedAnimation(parent: controller, curve: widget.curve));
/// ```

/// 默认的动画时长
/// [kTabScrollDuration]
const kDefaultAnimationDuration = Duration(milliseconds: 300);

/// 慢的动画时长
const kDefaultSlowAnimationDuration = Duration(milliseconds: 3000);

/// 动画方向
/// The direction in which an animation is running.
/// [_AnimationDirection]
enum AnimationDirection {
  /// The animation is running from beginning to end.
  /// 从头到尾
  forward,

  /// The animation is running backwards, from end to beginning.
  /// 从后到前
  reverse,
}

extension AnimationEx<T> on Animation<T> {
  /// 动画是否开始了
  bool get isStarted =>
      status == AnimationStatus.forward || status == AnimationStatus.reverse;

  /// 动画是否结束了
  bool get isStopped =>
      status == AnimationStatus.completed ||
      status == AnimationStatus.dismissed;
}

extension AnimationTweenEx on Animation<double> {
  /// 动画插值
  Animation<T> tween<T>(T? begin, T? end, {Curve curve = Curves.linear}) {
    return Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: this, curve: curve));
  }
}

extension AnimationWidgetEx on Widget {
  /// 缩放动画
  /// [MatrixTransition]
  /// [ScaleTransition]
  Widget scaleTransition(
    Animation<double>? scale, {
    Alignment alignment = Alignment.center,
    //--
    double? from,
    double? to,
    Curve curve = Curves.fastOutSlowIn,
  }) {
    if (scale == null) {
      return this;
    }
    return ScaleTransition(
      scale: (from != null && to != null)
          ? scale.tween(from, to, curve: curve)
          : scale,
      alignment: alignment,
      child: this,
    );
  }

  /// 透明度动画, 渐隐动画.
  /// [out] fade out or fade in
  ///
  /// [Opacity]
  /// [AnimatedOpacity]
  /// [FadeTransition]
  Widget fadeTransition(
    Animation<double>? opacity, {
    //--
    double? from,
    double? to,
    Curve curve = Curves.fastOutSlowIn,
  }) {
    if (opacity == null) {
      return this;
    }
    return FadeTransition(
      opacity: (from != null && to != null)
          ? opacity.tween(from, to, curve: curve)
          : opacity,
      child: this,
    );
  }

  /// 滑动动画
  Widget slideTransition({
    Animation<Offset>? offset,
    Offset? from,
    Offset? to,
    bool out = false,
  }) {
    return SlideTransition(
      position:
          offset ??
          Tween<Offset>(
            begin: from ?? (out ? Offset.zero : const Offset(0, 1)),
            end: to ?? (out ? const Offset(0, 1) : Offset.zero),
          ).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(out ? 0 : 1),
              curve: Curves.easeIn,
            ),
          ),
      child: this,
    );
  }

  /// 旋转动画
  /// [from] 旋转角度, 角度单位
  /// [to] 旋转角度, 角度单位
  ///
  /// [MatrixTransition]
  /// [RotationTransition]
  Widget rotationTransition(
    Animation<double>? rotate, {
    double? from,
    double? to,
    Curve curve = Curves.fastOutSlowIn,
  }) {
    if (rotate == null) {
      return this;
    }
    return RotationTransition(
      turns: (from != null && to != null)
          ? rotate.tween(from / 360, to / 360, curve: curve)
          : rotate,
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

//--

/// 创建一个控制动画, 指定时间
/// 在指定的时间内, 从[0~1]的动画变化回调
/// - [value] 初始值
/// - [lowerBound] 最小值
/// - [upperBound] 最大值
/// - [curve] 动画曲线[Curves.easeInOut].[Curves.easeOut]
/// - [vsync].[TickerProviderStateMixin].[SingleTickerProviderStateMixin]
///
/// - [AnimationController.stop] 停止动画
/// - [AnimationController.dispose] 释放资源
///
/// - [startValueAnimation]
AnimationController animation(
  TickerProvider vsync,
  void Function(double value, bool isCompleted) listener, {
  Duration duration = kDefaultAnimationDuration,
  double? value,
  double lowerBound = 0.0,
  double upperBound = 1.0,
  Curve? curve,
  Curve? reverseCurve,
  //--
  String? tag,
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
          parent: controller,
          curve: curve,
          reverseCurve: reverseCurve,
        );

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
        if (status.isCompleted) {
          l.d(
            '[$tag]动画状态改变: $status isCompleted:${status.isCompleted.toDC()} isDismissed:${status.isDismissed.toDC()}',
          );
        } else {
          l.v(
            '[$tag]动画状态改变: $status isCompleted:${status.isCompleted.toDC()} isDismissed:${status.isDismissed.toDC()}',
          );
        }
        return true;
      }());
      listener(
        animation?.value ?? controller.value,
        status == AnimationStatus.completed,
      );
    })
    ..forward();
  //释放资源
  //controller.dispose();
  return controller;
}

/// 矩阵动画
/// [Matrix4Tween]
AnimationController matrixAnimation(
  TickerProvider vsync,
  Matrix4 begin,
  Matrix4 end,
  void Function(Matrix4 value, bool isCompleted) listener, {
  Duration duration = kDefaultAnimationDuration,
  Curve? curve,
}) {
  final matrixTween = Matrix4Tween(begin: begin, end: end);
  return animation(vsync, (value, isCompleted) {
    final matrix = matrixTween.lerp(value);
    listener(matrix, isCompleted);
  });
}

/// 启动一个值从[from]到[to]的变化动画
/// [AnimationController.stop] 停止动画
/// [AnimationController.dispose] 释放资源
AnimationController startValueAnimation(
  double from,
  double to,
  TickerProvider vsync,
  void Function(double value, bool isCompleted) listener, {
  Duration duration = kDefaultAnimationDuration,
  double? value,
  double lowerBound = 0.0,
  double upperBound = 1.0,
  Curve? curve,
}) {
  return animation(
    vsync,
    (value, isCompleted) {
      listener(from + (to - from) * value, isCompleted);
    },
    duration: duration,
    value: value,
    lowerBound: lowerBound,
    upperBound: upperBound,
    curve: curve,
  );
}

//--

/// 动画控制混入
/// [SingleTickerProviderStateMixin]
/// [TickerProviderStateMixin]
mixin AnimationMixin<T extends StatefulWidget> on State<T> {
  /// 开始一个在指定时间内完成的动画
  /// [curve] 动画曲线
  /// [animation]
  AnimationController startTimeAnimation(
    void Function(double value, bool isCompleted) listener, {
    Duration duration = kDefaultAnimationDuration,
    double? value,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    Curve? curve,
    TickerProvider? vsync,
  }) {
    final controller = animation(
      vsync ?? this as TickerProvider /*必须*/,
      listener,
      duration: duration,
      value: value,
      lowerBound: lowerBound,
      upperBound: upperBound,
      curve: curve,
    );
    controller.addStatusListener((status) {
      if (status.isDismissed || status.isCompleted) {
        disposeAnimationController(controller);
      }
    });
    hookAnimationController(controller);
    return controller;
  }

  /// 动画控制器, 用来自动释放资源
  @autoDispose
  final List<AnimationController> _animationControllerList = [];

  /// 在[dispose]时, 取消所有的[AnimationController]
  @api
  @autoDispose
  void hookAnimationController(AnimationController controller) {
    _animationControllerList.add(controller);
  }

  /// 释放指定的[AnimationController]
  @api
  void disposeAnimationController(AnimationController controller) {
    try {
      controller.dispose();
    } catch (e) {
      printError(e);
    }
    _animationControllerList.remove(controller);
  }

  @override
  void dispose() {
    try {
      for (final element in _animationControllerList) {
        try {
          element.dispose();
        } catch (e) {
          printError(e);
        }
      }
    } finally {
      _animationControllerList.clear();
    }
    super.dispose();
  }
}
