part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
/// 竖线
Line verticalLine(
  BuildContext? context, {
  Color? color,
  double? indent,
  double? endIndent,
  double thickness = 1,
}) =>
    Line(
      thickness: thickness,
      color: color ?? GlobalTheme.of(context).lineColor,
      axis: Axis.vertical,
      indent: indent,
      endIndent: endIndent ?? indent,
    );

/// [verticalLine]
@Alias("verticalLine")
Line vLine(
  BuildContext? context, {
  Color? color,
  double? indent,
  double? endIndent,
  double thickness = 1,
}) =>
    verticalLine(
      context,
      color: color,
      indent: indent,
      endIndent: endIndent,
      thickness: thickness,
    );

/// 横线
Line horizontalLine(
  BuildContext? context, {
  Color? color,
  double? indent,
  double? endIndent,
  double thickness = 1,
}) =>
    Line(
      thickness: thickness,
      color: color ?? GlobalTheme.of(context).lineColor,
      axis: Axis.horizontal,
      indent: indent,
      endIndent: endIndent ?? indent,
    );

/// [horizontalLine]
@Alias("horizontalLine")
Line hLine(
  BuildContext? context, {
  Color? color,
  double? indent,
  double? endIndent,
  double thickness = 1,
}) =>
    horizontalLine(
      context,
      color: color,
      indent: indent,
      endIndent: endIndent,
      thickness: thickness,
    );

/// 线
Widget line(
  BuildContext? context, {
  Axis axis = Axis.vertical,
  double thickness = 1,
  double lineSize = 24,
  Color? color,
}) {
  final globalTheme = GlobalTheme.of(context);
  //color ??= context.isThemeDark ? const Color(0xff595450) : const Color(0xffececec);
  color ??= context?.isThemeDark == true
      ? globalTheme.lineDarkColor
      : globalTheme.lineColor;
  final w = axis == Axis.vertical ? thickness : lineSize;
  final h = axis == Axis.vertical ? lineSize : thickness;
  return DecoratedBox(decoration: fillDecoration(color: color))
      .size(width: w, height: h);
}

class Line extends LeafRenderObjectWidget {
  /// 是否强制指定线条的大小
  final double? lineSize;

  /// 线条的厚度
  final double thickness;

  /// 线条的方向
  final Axis axis;

  /// 宽或高, 需要收尾缩进多少量
  final double? indent;
  final double? endIndent;

  /// 线条的颜色
  final Color color;

  /// 线条的外边距, 可以用来控制小部件的大小
  final EdgeInsets? margin;

  /// 线条的端点样式
  final StrokeCap lineStrokeCap;

  /// 线条的连接样式
  final StrokeJoin lineStrokeJoin;

  /// 线额外的装饰绘制
  final Decoration? decoration;

  const Line({
    super.key,
    this.lineSize,
    this.thickness = 1,
    this.color = Colors.grey,
    this.axis = Axis.horizontal,
    this.indent,
    this.endIndent,
    this.margin,
    this.lineStrokeCap = StrokeCap.square,
    this.lineStrokeJoin = StrokeJoin.round,
    this.decoration,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => LineRender(this);

  @override
  void updateRenderObject(BuildContext context, LineRender renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..reset()
      ..line = this
      ..markNeedsPaint();
  }
}

/// 线条渲染
class LineRender extends RenderBox {
  Line line;

  LineRender(this.line);

  ImageConfiguration configuration = ImageConfiguration.empty;

  BoxPainter? _painter;

  void reset() {}

  @override
  void performLayout() {
    //super.performLayout();
    var constraints = this.constraints;

    double width = line.thickness;
    double height = line.thickness;
    if (line.axis == Axis.horizontal) {
      //横线
      if (line.lineSize == null) {
        //自适应线宽
        if (constraints.maxWidth == double.infinity) {
          final siblingSize = _findSiblingSize();
          width = siblingSize?.width ?? 0;
        } else {
          width = constraints.maxWidth;
        }
      } else {
        width = line.lineSize!;
      }
      width = width - (line.indent ?? 0) - (line.endIndent ?? 0);
    } else {
      //竖线
      if (line.lineSize == null) {
        //自适应线高
        if (constraints.maxHeight == double.infinity) {
          var siblingSize = _findSiblingSize();
          height = siblingSize?.height ?? 0;
        } else {
          height = constraints.maxHeight;
        }
      } else {
        height = line.lineSize!;
      }
      height = height - (line.indent ?? 0) - (line.endIndent ?? 0);
    }
    size = Size(width + (line.margin?.horizontal ?? 0),
        height + (line.margin?.vertical ?? 0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final size = this.size;
    final canvas = context.canvas;

    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.thickness
      ..strokeCap = line.lineStrokeCap
      ..strokeJoin = line.lineStrokeJoin
      ..style = PaintingStyle.stroke;
    final leftMargin = line.margin?.left ?? 0;
    final topMargin = line.margin?.top ?? 0;
    final rightMargin = line.margin?.right ?? 0;
    final bottomMargin = line.margin?.bottom ?? 0;

    final indent = line.indent ?? 0;
    final endIndent = line.endIndent ?? 0;

    if (line.axis == Axis.horizontal) {
      final ImageConfiguration filledConfiguration = configuration.copyWith(
          size: ui.Size(
        size.width - indent - endIndent - leftMargin - rightMargin,
        size.height - topMargin - bottomMargin,
      ));
      //背景绘制
      _painter ??= line.decoration?.createBoxPainter(markNeedsPaint);
      _painter?.paint(context.canvas, offset + Offset(leftMargin, topMargin),
          filledConfiguration);
      setCanvasIsComplexHint(context, line.decoration);

      //var lineHeight = size.height - topMargin - bottomMargin;
      canvas.drawLine(
          offset.translate(indent + leftMargin + line.thickness / 2,
              topMargin + line.thickness / 2),
          offset.translate(
              size.width - endIndent - rightMargin - line.thickness / 2,
              topMargin + line.thickness / 2),
          paint);
    } else {
      final ImageConfiguration filledConfiguration = configuration.copyWith(
          size: ui.Size(
        size.width - leftMargin - rightMargin,
        size.height - indent - endIndent,
      ));
      //背景绘制
      _painter ??= line.decoration?.createBoxPainter(markNeedsPaint);
      _painter?.paint(context.canvas, offset + Offset(leftMargin, topMargin),
          filledConfiguration);
      setCanvasIsComplexHint(context, line.decoration);

      //var lineWidth = size.width - leftMargin - rightMargin;
      canvas.drawLine(
          offset.translate(leftMargin + line.thickness / 2,
              indent + topMargin + line.thickness / 2),
          offset.translate(leftMargin + line.thickness / 2,
              size.height - endIndent - bottomMargin - line.thickness / 2),
          paint);
    }
  }

  /// 查找同级的小部件最大的大小
  Size? _findSiblingSize() {
    Size? result;
    if (parent != null) {
      for (final child in parent!.childrenList) {
        if (child == this) {
          continue;
        }
        var renderSize = child.renderSize ?? child.measureRenderSize();
        if (renderSize != null) {
          if (result == null) {
            result = renderSize;
          } else {
            if (renderSize.width * renderSize.height >
                result.width * result.height) {
              result = renderSize;
            }
          }
        }
      }
    }
    return result;
  }
}

/// 拖动线, 用来拖动调整布局大小
class DragLineWidget extends StatefulWidget {
  ///
  final Widget? child;

  /// 拖动线方向,
  /// - 横向 [Axis.horizontal]
  /// - 纵向 [Axis.vertical]
  final Axis axis;

  ///
  final HitTestBehavior? hitTestBehavior;

  /// 拖动线尺寸, 默认为 2.0
  final double? size;

  /// 拖拽量改变回调
  /// - from   拖拽开始的手势位置
  /// - to     拖拽当前的手势位置
  /// - delta  当前拖拽的增量量
  final void Function(double from, double to, double delta)? onDragChanged;

  const DragLineWidget({
    super.key,
    this.child,
    this.axis = Axis.horizontal,
    this.hitTestBehavior = HitTestBehavior.translucent,
    this.size = 2,
    this.onDragChanged,
  });

  @override
  State<DragLineWidget> createState() => _DragLineWidgetState();
}

class _DragLineWidgetState extends State<DragLineWidget> {
  /// 拖动开始时的位置
  Offset _dragStartPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.hitTestBehavior,
      onHorizontalDragDown: (DragDownDetails details) {
        //l.d("onHorizontalDragDown->$details ${details.localPosition}");
      },
      onHorizontalDragStart: (DragStartDetails details) {
        //l.d("onHorizontalDragStart->$details ${details.localPosition}");
        if (widget.axis == Axis.horizontal) {
          _dragStartPosition = details.localPosition;
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        /*l.d("onHorizontalDragUpdate->$details ${details.delta} ${details
            .primaryDelta} ${details.localPosition}");*/
        if (widget.axis == Axis.horizontal) {
          widget.onDragChanged?.call(
            _dragStartPosition.dx,
            details.localPosition.dx,
            details.primaryDelta ?? 0,
          );
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        //l.d("onHorizontalDragEnd->$details ${details.localPosition}");
      },
      onVerticalDragStart: (DragStartDetails details) {
        if (widget.axis == Axis.vertical) {
          _dragStartPosition = details.localPosition;
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        //l.d("onVerticalDragUpdate->$details ${details.delta} ${details.primaryDelta}");
        if (widget.axis == Axis.vertical) {
          widget.onDragChanged?.call(
            _dragStartPosition.dy,
            details.localPosition.dy,
            details.primaryDelta ?? 0,
          );
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        //l.d("onVerticalDragEnd->$details ${details.localPosition}");
      },
      child: MouseRegion(
        cursor: widget.axis == Axis.horizontal
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        hitTestBehavior: widget.hitTestBehavior,
        child: widget.child,
      ),
    ).size(
      width: widget.axis == Axis.horizontal ? widget.size : null,
      height: widget.axis == Axis.vertical ? widget.size : null,
    );
  }
}
