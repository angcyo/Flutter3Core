part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/20
///
/// 表盘布局 / 圆环布局
/// 将多个矩形按照不同半径的圆形（同心圆）进行排列，在计算机图形学、UI 设计（如表盘布局）和数据可视化（如 Circos 图）中是一个非常经典的计算几何问题。
///
/// 要实现这个布局，核心在于极坐标系与笛卡尔坐标系的转换，以及通过弦长公式计算矩形在圆周上占据的角度。
class DialLayout extends MultiChildRenderObjectWidget {
  /// 最内侧圆的初始半径
  final double initialRadius;

  /// 两个同心圆轨道之间的间距 (高度方向)
  final double radialGap;

  /// 同一圆轨道上，两个矩形之间的弦长间距 (宽度方向)
  final double arcGap;

  /// 起始布局的角度(弧度)
  final double startAngle;

  const DialLayout({
    super.key,
    super.children,
    this.initialRadius = 60,
    this.radialGap = 30,
    this.arcGap = 30,
    this.startAngle = 0,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _DialLayoutRender(
    initialRadius: initialRadius,
    radialGap: radialGap,
    arcGap: arcGap,
    startAngle: startAngle,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _DialLayoutRender renderObject,
  ) {
    renderObject
      ..initialRadius = initialRadius
      ..radialGap = radialGap
      ..arcGap = arcGap
      ..startAngle = startAngle
      ..markNeedsLayout();
  }
}

class _DialLayoutRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DialLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DialLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  /// 最内侧圆的初始半径
  double initialRadius;

  /// 两个同心圆轨道之间的间距 (高度方向)
  double radialGap;

  /// 同一圆轨道上，两个矩形之间的弦长间距 (宽度方向)
  double arcGap;

  /// 起始布局的角度(弧度)
  double startAngle;

  _DialLayoutRender({
    this.initialRadius = 60,
    this.radialGap = 30,
    this.arcGap = 30,
    this.startAngle = 0,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    //debugger();
    if (child.parentData is! DialLayoutParentData) {
      child.parentData = DialLayoutParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required ui.Offset position}) {
    return hitLayoutChildren(
      getChildren(),
      result,
      position: position,
      transform: effectiveTransform,
    );
  }

  /// 计算出来的矩阵
  /// - [RenderTransform]
  Matrix4? _effectiveTransform;

  Matrix4? get effectiveTransform => _effectiveTransform;

  @override
  void performLayout() {
    final constraints = this.constraints;
    final children = getChildren();
    if (children.isEmpty) {
      size = constraints.biggest;
      return;
    }
    //debugger();
    measureWrapChildren(children, parentConstraints: constraints);

    final rectangles = children
        .mapIndex(
          (child, index) => LayoutRectangle(
            id: index,
            width: child.size.width,
            height: child.size.height,
          ),
        )
        .toList();
    final placed = DialLayoutHelper.arrangeNonIntersectingCircles(
      rectangles: rectangles,
      initialRadius: initialRadius,
      radialGap: radialGap,
      arcGap: arcGap,
      autoRotate: false,
      startAngle: startAngle,
    );

    double minLeft = double.infinity;
    double minTop = double.infinity;
    double maxRight = -double.infinity;
    double maxBottom = -double.infinity;
    for (final rectangle in placed) {
      final child = children[rectangle.id];
      final childParentData = child.parentData as DialLayoutParentData;
      final left = rectangle.centerX - child.size.width / 2;
      final top = rectangle.centerY - child.size.height / 2;
      final right = left + child.size.width;
      final bottom = top + child.size.height;
      minLeft = min(minLeft, left);
      minTop = min(minTop, top);
      maxRight = max(maxRight, right);
      maxBottom = max(maxBottom, bottom);
      childParentData.offset = Offset(left, top);
    }

    //debugger();
    //layoutLinearChildren(children, mainAxis);

    final width = constraints.maxWidth.ensureValid(maxRight - minLeft);
    final height = constraints.maxHeight.ensureValid(maxBottom - minTop);

    _effectiveTransform = createTranslateMatrix(tx: width / 2, ty: height / 2);
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    paintLayoutChildren(
      getChildren(),
      context,
      offset,
      transform: effectiveTransform,
    );
    debugPaintBoxBounds(context, offset);
  }

  /// - [RenderTransform]
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Matrix4? effectiveTransform = _effectiveTransform;
    if (effectiveTransform != null) {
      transform.multiply(effectiveTransform);
    }
  }
}

/// 布局数据
class DialLayoutParentData extends ContainerBoxParentData<RenderBox> {
  DialLayoutParentData();
}

/// 优雅的周围漂浮悬浮包装 Widget
class FloatingAnimatedWidget extends StatefulWidget {
  /// 需要漂浮的目标子组件
  final Widget child;

  /// 水平（X轴）最大漂浮半径 (px)
  final double distanceX;

  /// 垂直（Y轴）最大漂浮半径 (px)
  final double distanceY;

  /// X轴与Y轴的频率比例（推荐 1:2 或 2:3，能产生自然的 8 字形或曲线漂浮轨迹）
  /// - `1:1` \斜对角移动
  /// - `1:2` ∞交叉移动
  /// - `2:3` 更自然的∞交叉移动
  final double frequencyRatioXToY;

  /// 漂浮单次循环周期
  final Duration duration;

  /// 相位偏移量，取值范围 0.0 ~ 1.0（对应 0 ~ 360°）
  /// 例如：0.25 代表错开 1/4 个周期 (90°)
  final double phaseOffset;

  const FloatingAnimatedWidget({
    super.key,
    required this.child,
    this.distanceX = 12.0,
    this.distanceY = 18.0,
    this.frequencyRatioXToY = 0.5, // 相当于 1:2
    this.duration = const Duration(seconds: 10),
    this.phaseOffset = 0.0, // 默认不偏移
  });

  @override
  State<FloatingAnimatedWidget> createState() => _FloatingAnimatedWidgetState();
}

class _FloatingAnimatedWidgetState extends State<FloatingAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /*late final Animation<double> _animation;*/

  @override
  void initState() {
    super.initState();
    // 绑定屏幕 VSync 刷新信号，并设置无限重复动画
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // 叠加 easeInOut 缓动曲线，让到达两端（头和尾）时的转向更柔和
    /*final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );*/

    // 映射位移区间
    /*_animation = Tween<double>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(curvedAnimation);*/

    // 开启往复循环：从头到尾，再从尾到头
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // 核心性能点：将 child 独立传入，避免 AnimatedBuilder 每次刷新都重绘 child 内部子树
      child: widget.child,
      builder: (context, cachedChild) {
        // 关键改动：将控制器当前值叠加相位偏移量 phaseOffset
        final double rawValue = (_controller.value + widget.phaseOffset) % 1.0;
        // 将 0.0 ~ 1.0 的动画进度映射到 0 ~ 2π 弧度
        final double t = rawValue * 2 * pi;

        // 根据三角函数计算 2D 逻辑像素偏移
        final double dx = widget.distanceX * sin(t * widget.frequencyRatioXToY);
        final double dy = widget.distanceY * sin(t);

        return Transform.translate(offset: Offset(dx, dy), child: cachedChild);
      },
    );
  }
}

extension DialLayoutWidgetEx on Widget {
  /// 小部件优雅的漂浮悬浮动画
  /// [FloatingAnimatedWidget]
  Widget floatingAnimated({
    double distanceX = 12.0,
    double distanceY = 18.0,
    double frequencyRatioXToY = 2 / 3,
    Duration duration = const Duration(seconds: 10),
    double phaseOffset = 0,
  }) {
    return FloatingAnimatedWidget(
      distanceX: distanceX,
      distanceY: distanceY,
      frequencyRatioXToY: frequencyRatioXToY,
      duration: duration,
      phaseOffset: phaseOffset,
      child: this,
    );
  }
}
