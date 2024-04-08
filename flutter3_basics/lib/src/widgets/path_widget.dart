part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/08
///
/// [Path]路径绘制小部件
class PathWidget extends LeafRenderObjectWidget {
  /// The path to render.
  final Path? path;

  final ui.PaintingStyle style;

  /// The fill color to use when rendering the path.
  final Color color;

  final BoxFit fit;

  final Alignment alignment;

  const PathWidget({
    super.key,
    this.path,
    this.style = ui.PaintingStyle.stroke,
    this.color = Colors.black,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => PathRenderBox(
        path: path,
        style: style,
        color: color,
        fit: fit,
        alignment: alignment,
      );

  @override
  void updateRenderObject(BuildContext context, PathRenderBox renderObject) {
    renderObject
      ..updatePath(path)
      ..style = style
      ..color = color
      ..fit = fit
      ..alignment = alignment
      ..markNeedsPaint();
  }
}

class PathRenderBox extends RenderBox {
  /// The path to render.
  Path? path;

  ui.PaintingStyle style;

  /// The fill color to use when rendering the path.
  Color color;

  BoxFit fit;

  Alignment alignment;

  Rect? _pathBounds;

  PathRenderBox({
    this.path,
    this.style = ui.PaintingStyle.stroke,
    this.color = Colors.black,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  void updatePath(Path? newPath) {
    if (path != newPath) {
      _pathBounds = null;
    }
    path = newPath;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    if (path != null) {
      _pathBounds ??= path!.getExactBounds();
      final pathSize = _pathBounds!.size;
      if (constraints.isTight) {
        //有一种满意的约束尺寸
        size = constraints.smallest;
      } else {
        size = constraints.constrain(pathSize);
      }
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    if (path != null) {
      final canvas = context.canvas;
      canvas.drawPathIn(path, _pathBounds, offset & size,
          fit: fit,
          alignment: alignment,
          paint: Paint()
            ..color = color
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = style);
    }
  }
}
