part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/17
///
/// 支持宽高动画变化的小部件
/// [AnimatedSize] 动画容器
/// [AnimatedContainer] 动画容器
/// [AnimatedCrossFade] 交叉淡入淡出动画容器
class SizeAnimationWidget extends StatefulWidget {
  /// 激活透明度动画
  final bool enableOpacityAnimation;

  /// 激活宽度动画
  final bool enableWidthAnimation;

  /// 激活高度动画
  final bool enableHeightAnimation;

  /// 是否使用平移
  final bool useTranslation;

  final Widget child;

  final AnimateAction? onComplete;

  /// 动画控制器
  final AnimationController? controller;

  const SizeAnimationWidget({
    super.key,
    required this.child,
    this.enableOpacityAnimation = false,
    this.enableWidthAnimation = false,
    this.enableHeightAnimation = false,
    this.useTranslation = false,
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
    //debugger();
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
      enableOpacityAnimation: widget.enableOpacityAnimation,
      enableWidthAnimation: widget.enableWidthAnimation,
      enableHeightAnimation: widget.enableHeightAnimation,
      useTranslation: widget.useTranslation,
      animateValue: _controller.value,
      child: widget.child,
    );
  }
}

class _SizeAnimation extends SingleChildRenderObjectWidget {
  final bool enableOpacityAnimation;
  final bool enableWidthAnimation;
  final bool enableHeightAnimation;
  final bool useTranslation;
  final double animateValue;

  const _SizeAnimation({
    super.key,
    super.child,
    this.enableOpacityAnimation = false,
    this.enableWidthAnimation = false,
    this.enableHeightAnimation = false,
    this.useTranslation = false,
    this.animateValue = 1,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeAnimation(
      enableOpacityAnimation: enableOpacityAnimation,
      enableWidthAnimation: enableWidthAnimation,
      enableHeightAnimation: enableHeightAnimation,
      useTranslation: useTranslation,
      animateValue: animateValue,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeAnimation renderObject,
  ) {
    //l.d('animateValue:${animateValue} ${enableOpacityAnimation}');
    renderObject
      ..enableOpacityAnimation = enableOpacityAnimation
      ..enableWidthAnimation = enableWidthAnimation
      ..enableHeightAnimation = enableHeightAnimation
      ..useTranslation = useTranslation
      ..animateValue = animateValue
      ..markNeedsLayout();
    /*if (enableOpacityAnimation) {
      renderObject.markNeedsCompositedLayerUpdate();
      renderObject.markNeedsCompositingBitsUpdate();
    }*/
  }
}

/// [RenderAnimatedOpacity]
/// [RenderAnimatedOpacityMixin]
/// [RenderObjectWithChildMixin]
/// [SingleChildRenderObjectWidget]
class _RenderSizeAnimation extends RenderProxyBox {
  /// 是否激活不透明动画
  bool enableOpacityAnimation;

  /// 是否激活对应的动画
  bool enableWidthAnimation;
  bool enableHeightAnimation;

  /// 是否使用平移
  bool useTranslation;

  /// 动画当前的值[0~1]
  double animateValue;

  /// 缓存原始大小
  Size _rawSize = Size.zero;

  _RenderSizeAnimation({
    this.enableOpacityAnimation = false,
    this.enableWidthAnimation = false,
    this.enableHeightAnimation = false,
    this.useTranslation = false,
    this.animateValue = 1,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      _rawSize = constraints.biggest;
      size = _rawSize;
    } else {
      child.layout(constraints, parentUsesSize: true);
      final size = child.size;
      if (enableWidthAnimation || enableHeightAnimation) {
        //debugger();
        _rawSize = size;
        this.size = Size(
          enableWidthAnimation ? size.width * animateValue : size.width,
          enableHeightAnimation ? size.height * animateValue : size.height,
        );
        if (useTranslation) {
          final offsetDx =
              enableWidthAnimation ? -size.width * (1 - animateValue) : 0.0;
          final offsetDy =
              enableHeightAnimation ? size.height * (1 - animateValue) : 0.0;
          child.setBoxOffset(dx: offsetDx, dy: offsetDy);
        }
        /*assert(() {
          l.d('size:${this.size} $animateValue');
          return true;
        }());*/
      } else {
        _rawSize = size;
        this.size = size;
      }
    }
  }

  @override
  bool get isRepaintBoundary => child != null && enableOpacityAnimation;

  /*@override
  bool get needsCompositing => true;*/

  /// 透明动画通过[OpacityLayer]图层实现, 并且需要[isRepaintBoundary]为true, 才会触发[updateCompositedLayer]方法回调
  /// [markNeedsCompositedLayerUpdate]
  /// [markNeedsCompositedLayerUpdate]
  @override
  OffsetLayer updateCompositedLayer(
      {required covariant OffsetLayer? oldLayer}) {
    //debugger();
    if (enableOpacityAnimation) {
      final OpacityLayer updatedLayer =
          (oldLayer == null || oldLayer is! OpacityLayer)
              ? OpacityLayer()
              : oldLayer;
      //不透明度表示为 0 到 255 之间的整数，其中 0 表示完全透明，255 表示完全不透明。
      //debugger();
      updatedLayer.alpha = (animateValue.clamp(0.0, 1.0) * 255).toInt();
      //l.d('${updatedLayer.alpha}');
      return updatedLayer;
    } else {
      return super.updateCompositedLayer(oldLayer: oldLayer);
    }
  }

  @override
  bool paintsChild(covariant RenderObject child) {
    return !enableOpacityAnimation || animateValue > 0;
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (child != null &&
        !child!.size.isEmpty &&
        paintsChild(child!) &&
        !size.isEmpty) {
      if ((enableWidthAnimation || enableHeightAnimation) && useTranslation) {
        //l.d('clip:${offset & size}');
        context.pushClipRect(needsCompositing, offset, Offset.zero & size,
            (context, offset) {
          super.paint(context, child!.getBoxOffset() + offset);
        });
      } else {
        super.paint(context, child!.getBoxOffset() + offset);
      }
    }
    //debugDrawBoxBounds(context, offset);
  }
}
