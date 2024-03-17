part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/17
///
/// 支持宽高动画变化的小部件
class SizeAnimationWidget extends StatefulWidget {
  /// 激活宽度动画
  final bool enableWidthAnimation;

  /// 激活高度动画
  final bool enableHeightAnimation;

  final Widget child;

  final AnimateAction? onComplete;

  /// 动画控制器
  final AnimationController? controller;

  const SizeAnimationWidget({
    super.key,
    required this.child,
    this.enableWidthAnimation = false,
    this.enableHeightAnimation = false,
    this.controller,
    this.onComplete,
  });

  @override
  State<SizeAnimationWidget> createState() => _SizeAnimationWidgetState();
}

class _SizeAnimationWidgetState extends State<SizeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = widget.controller ??
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        );
    _controller.addListener(_handleAnimationChange);
    _controller.addStatusListener(_handleAnimationStatus);
    super.initState();
    //_controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeListener(_handleAnimationChange);
    _controller.removeStatusListener(_handleAnimationStatus);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SizeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*if (oldWidget.enableWidthAnimation != widget.enableWidthAnimation ||
        oldWidget.enableHeightAnimation != widget.enableHeightAnimation) {
      _controller.reset();
      _controller.forward();
    }*/
  }

  void _handleAnimationChange() {
    setState(() {});
  }

  void _handleAnimationStatus(status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete?.call(_controller);
    }
  }

  /// 开始显示动画
  void _show() {
    //debugger();
    _controller.forward(from: 0);
  }

  /// 开始隐藏动画
  void _hide() {
    _controller.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    //l.d('value:${_controller.value}');
    return _SizeAnimation(
        enableWidthAnimation: widget.enableWidthAnimation,
        enableHeightAnimation: widget.enableHeightAnimation,
        animateValue: _controller.value,
        child: widget.child);
  }
}

class _SizeAnimation extends SingleChildRenderObjectWidget {
  final bool enableWidthAnimation;
  final bool enableHeightAnimation;
  final double animateValue;

  const _SizeAnimation({
    super.key,
    super.child,
    this.enableWidthAnimation = false,
    this.enableHeightAnimation = false,
    this.animateValue = 1,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeAnimation(
      enableWidthAnimation: enableWidthAnimation,
      enableHeightAnimation: enableHeightAnimation,
      animateValue: animateValue,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderSizeAnimation renderObject) {
    renderObject
      ..enableWidthAnimation = enableWidthAnimation
      ..enableHeightAnimation = enableHeightAnimation
      ..animateValue = animateValue
      ..markNeedsLayout();
  }
}

class _RenderSizeAnimation extends RenderProxyBox {
  /// 是否激活对应的动画
  bool enableWidthAnimation;
  bool enableHeightAnimation;

  /// 动画当前的值[0~1]
  double animateValue;

  _RenderSizeAnimation({
    this.enableWidthAnimation = false,
    this.enableHeightAnimation = false,
    this.animateValue = 1,
  });

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.biggest;
    } else {
      child.layout(constraints, parentUsesSize: true);
      final size = child.size;
      if (enableWidthAnimation || enableHeightAnimation) {
        this.size = ui.Size(
            enableWidthAnimation ? size.width * animateValue : size.width,
            enableHeightAnimation ? size.height * animateValue : size.height);
      } else {
        this.size = size;
      }
    }
  }
}
