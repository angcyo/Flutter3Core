part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/23
///

class CustomPaintWrap extends CustomPainter {
  final PaintFn? paintIt;

  CustomPaintWrap(this.paintIt);

  @override
  void paint(Canvas canvas, Size size) {
    paintIt?.call(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPaintWrap oldDelegate) =>
      oldDelegate.paintIt != paintIt;
}
