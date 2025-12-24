part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/06
///
/// 旋转状态
enum RotateState {
  /// 开始旋转
  rotate,

  /// 在当前的旋转角度, 暂停旋转
  pause,

  /// 恢复到默认角度,停止旋转
  stop,
}

/// 无限旋转动画小部件
class RotateAnimation extends StatefulWidget {
  /// 旋转的角度步长, 角度
  final double angleStep;
  final RotateState rotateState;
  final Widget child;

  const RotateAnimation(
    this.child, {
    this.rotateState = RotateState.rotate,
    super.key,
    this.angleStep = 3,
  });

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation> {
  /// 当前旋转的角度, [0~360]
  double angle = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rotateState == RotateState.rotate) {
      angle += widget.angleStep;
      postCallback(() {
        updateState();
      });
    } else if (widget.rotateState == RotateState.stop) {
      angle = 0;
    }
    return Transform.rotate(angle: angle.hd, child: widget.child);
  }
}

/*
class RotateAnimated extends SingleChildRenderObjectWidget {
  const RotateAnimated({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RotateAnimatedBox(this);

  @override
  void updateRenderObject(
      BuildContext context, _RotateAnimatedBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject._rotateAnimated = this;
    renderObject.markNeedsPaint();
  }
}

class _RotateAnimatedBox extends RenderProxyBox {
  _RotateAnimatedBox(this._rotateAnimated);

  RotateAnimated _rotateAnimated;

  @override
  void paint(PaintingContext context, Offset offset) {}
}
*/

/// 动画旋转小部件, 参考[AnimatedContainer]
/// - 当传入的角度不一样时,自动进行旋转动画
/// - [RotationTransition] 旋转过度
/// - [Transform] 变砖
class AnimatedRotationWidget extends ImplicitlyAnimatedWidget {
  /// 当前旋转的角度, 角度单位
  final double angle;

  final Widget? child;

  final String? debugLabel;

  const AnimatedRotationWidget({
    super.key,
    this.angle = 0,
    this.child,
    super.curve,
    super.duration = kDefaultAnimationDuration,
    super.onEnd,
    this.debugLabel,
  });

  @override
  AnimatedWidgetBaseState<AnimatedRotationWidget> createState() =>
      _AnimatedRotationWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('angle', angle));
    properties.add(StringProperty('debugLabel', debugLabel));
  }
}

class _AnimatedRotationWidgetState
    extends AnimatedWidgetBaseState<AnimatedRotationWidget> {
  DoubleTween? _angle;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    debugger(when: widget.debugLabel != null);
    _angle =
        visitor(
              _angle,
              widget.angle,
              (dynamic value) => DoubleTween(begin: value),
            )
            as DoubleTween?;
  }

  @override
  void didUpdateTweens() {
    //_opacityAnimation = animation.drive(_opacity!);
    debugger(when: widget.debugLabel != null);
    super.didUpdateTweens();
  }

  @override
  void didUpdateWidget(covariant AnimatedRotationWidget oldWidget) {
    debugger(when: widget.debugLabel != null);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.animation;
    final angle = _angle?.evaluate(animation).hd ?? 0;
    /*assert(() {
      l.v("angle: $angle");
      return true;
    }());*/
    return Transform.rotate(angle: angle, child: widget.child);
  }
}

/// - [IntTween]
class DoubleTween extends Tween<double> {
  DoubleTween({super.begin, super.end});

  @override
  double lerp(double t) => begin! + (end! - begin!) * t;
}
