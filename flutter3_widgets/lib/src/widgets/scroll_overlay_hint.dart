part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/24
///
/// 如果滚动布局边界能够滚动, 则进行提示
class ScrollOverlayHintWidget extends StatefulWidget {
  /// 滚动布局, 能够发送[ScrollNotification]通知的布局
  final Widget child;

  const ScrollOverlayHintWidget({
    super.key,
    required this.child,
  });

  @override
  State<ScrollOverlayHintWidget> createState() =>
      _ScrollOverlayHintWidgetState();
}

class _ScrollOverlayHintWidgetState extends State<ScrollOverlayHintWidget> {
  bool drawTop = false;
  bool drawBottom = false;
  bool drawLeft = false;
  bool drawRight = false;

  final UpdateSignalNotifier _signalNotifier = createUpdateSignal();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        /*l.d("方向->${metrics.axis} "
            "最大滚动距离->${metrics.maxScrollExtent} "
            "当前滚动距离->${metrics.pixels} "
            "剩余距离->${metrics.maxScrollExtent - metrics.pixels}");*/

        drawTop = false;
        drawBottom = false;
        drawLeft = false;
        drawRight = false;

        if (metrics.axis == Axis.vertical) {
          drawTop = metrics.pixels > 0;
          drawBottom = metrics.maxScrollExtent > metrics.pixels;
        } else {
          drawLeft = metrics.pixels > 0;
          drawRight = metrics.maxScrollExtent > metrics.pixels;
        }
        _signalNotifier.update();
        return false;
      },
      child: rebuild(_signalNotifier, (_, __) {
        return ScrollOverlayHintRender(
          drawLeft: drawLeft,
          drawRight: drawRight,
          drawTop: drawTop,
          drawBottom: drawBottom,
          child: widget.child,
        );
      }),
    );
  }
}

class ScrollOverlayHintRender extends SingleChildRenderObjectWidget {
  /// 是否绘制对应方向的提示
  final bool drawTop;
  final bool drawBottom;
  final bool drawLeft;
  final bool drawRight;

  /// 提示的大小
  final double hintSize;

  /// 渐变的颜色
  final List<Color>? colors;

  const ScrollOverlayHintRender({
    super.key,
    super.child,
    this.drawTop = false,
    this.drawBottom = false,
    this.drawLeft = false,
    this.drawRight = false,
    this.hintSize = 30,
    this.colors = const [Colors.black26, Colors.transparent],
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderScrollOverlayHint(this);

  @override
  void updateRenderObject(
      BuildContext context, RenderScrollOverlayHint renderObject) {
    renderObject
      ..config = this
      ..markNeedsPaint();
  }
}

class RenderScrollOverlayHint extends RenderProxyBox {
  /// 配置
  ScrollOverlayHintRender config;

  RenderScrollOverlayHint(this.config);

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final canvas = context.canvas;

    final colors = config.colors;
    if (colors == null) {
      return;
    }

    //top
    if (config.drawTop) {
      final rect = Rect.fromLTWH(
        paintBounds.left + offset.dx,
        paintBounds.top + offset.dy,
        paintBounds.width,
        config.hintSize,
      );
      canvas.drawRect(
          rect,
          Paint()
            ..shader = linearGradientShader(colors,
                from: rect.topLeft, to: rect.bottomLeft));
    }
    if (config.drawBottom) {
      final rect = Rect.fromLTWH(
        paintBounds.left + offset.dx,
        paintBounds.bottom - config.hintSize,
        paintBounds.width,
        config.hintSize,
      );
      canvas.drawRect(
          rect,
          Paint()
            ..shader = linearGradientShader(colors,
                from: rect.bottomLeft, to: rect.topLeft));
    }
    //left
    if (config.drawLeft) {
      final rect = Rect.fromLTWH(
        paintBounds.left + offset.dx,
        paintBounds.top + offset.dy,
        config.hintSize,
        paintBounds.height,
      );
      canvas.drawRect(
          rect,
          Paint()
            ..shader = linearGradientShader(colors,
                from: rect.topLeft, to: rect.topRight));
    }
    if (config.drawRight) {
      final rect = Rect.fromLTWH(
        paintBounds.right - config.hintSize,
        paintBounds.top + offset.dy,
        config.hintSize,
        paintBounds.height,
      );
      canvas.drawRect(
          rect,
          Paint()
            ..shader = linearGradientShader(colors,
                from: rect.topRight, to: rect.topLeft));
    }
  }
}
