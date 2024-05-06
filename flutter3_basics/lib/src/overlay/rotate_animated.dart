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

/// 旋转动画小部件
class RotateAnimated extends StatefulWidget {
  /// 旋转的角度步长, 角度
  final double angleStep;
  final RotateState rotateState;
  final Widget child;

  const RotateAnimated(
    this.child, {
    this.rotateState = RotateState.rotate,
    super.key,
    this.angleStep = 3,
  });

  @override
  State<RotateAnimated> createState() => _RotateAnimatedState();
}

class _RotateAnimatedState extends State<RotateAnimated> {
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
    return Transform.rotate(
      angle: angle.hd,
      child: widget.child,
    );
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
