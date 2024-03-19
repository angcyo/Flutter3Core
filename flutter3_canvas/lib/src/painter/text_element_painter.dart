part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/19
///
class TextElementPainter extends ElementPainter {
  String? text;

  TextElementPainter();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paint.color = Colors.black;
    text?.let((it) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: it,
          style: TextStyle(
            color: paint.color,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      //debugger();

      final rect = Rect.fromLTWH(0, 0, 100, 100);

      final matrix = Matrix4.identity()
        ..postFlip(
          flipX: true,
          flipY: false,
        );

      final matrix2 = Matrix4.identity()
        ..postFlip(
          flipX: true,
          flipY: false,
          pivotX: 10,
          pivotY: 10,
        );

      /*final matrix2 = Matrix4.identity()
        ..translate(10.0, 10.0)  // 指定锚点为 (50, 50)
        ..scale(-1.0, 1.0, 1.0)
        ..translate(-10.0, -10.0);  // 将矩阵平移回原点*/

      final r2 = matrix.mapRect(rect);
      final r3 = matrix2.mapRect(rect);

      //debugger();

      canvas.withMatrix(paintProperty?.paintMatrix2, () {
        textPainter.paint(canvas, Offset.zero);
      });
    });
    super.onPaintingSelf(canvas, paintMeta);
  }
}
