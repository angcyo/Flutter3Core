part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/19
///
/// 文本绘制元素对象
class TextElementPainter extends ElementPainter {
  /// 当前绘制的文本对象
  TextPainter? paintTextPainter;

  /// 获取绘制文本的字符串
  String? get text {
    final span = paintTextPainter?.text;
    if (span is TextSpan) {
      return span.text;
    }
    return null;
  }

  TextElementPainter() {
    debug = false;
  }

  void initFromText(String? text) {
    final textPainter = createTextPainter(text);
    final size = textPainter.size;
    paintProperty = PaintProperty()
      ..width = size.width
      ..height = size.height;
    paintTextPainter = textPainter;
  }

  /// [TextPainter]
  TextPainter createTextPainter(String? text) => TextPainter(
        textAlign: TextAlign.right,
        text: TextSpan(
          text: text,
          style: TextStyle(
            /*color: paint.color,*/
            fontSize: 12,
            fontStyle: FontStyle.italic,
            // 斜体
            fontWeight: FontWeight.normal,
            // 粗体, 字宽
            decoration: TextDecoration.lineThrough,
            // 下划线
            decorationColor: Colors.redAccent /*paint.color*/,
            foreground: Paint()
              /*..strokeWidth = 1*/
              ..color = paint.color
              ..style = PaintingStyle.stroke,
            /*background: Paint()
              ..color = Colors.redAccent
              ..style = PaintingStyle.stroke,*/
          ),
        ),
        textDirection: TextDirection.ltr,
        textHeightBehavior: TextHeightBehavior(
            /*applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,*/
            ),
      )..layout();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paintTextPainter?.let((painter) {
      canvas.withMatrix(
        paintProperty?.operateMatrix,
        () {
          painter.paint(canvas, Offset.zero);
        },
      );
    });
    super.onPaintingSelf(canvas, paintMeta);
  }

  void _testPaintingText(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    paint.color = Colors.black;
    text?.let((it) {
      final textPainter = createTextPainter(text);
      final size = textPainter.size;
      final metrics = textPainter.computeLineMetrics();
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: it.length),
      );
      final textHeightBehavior = textPainter.textHeightBehavior;

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

      final pp = paintProperty!;

      final ppRect = Rect.fromLTWH(0, 0, pp.width, pp.height);
      //final anchor = Offset.zero;
      final anchor = ppRect.center;

      final translation = Vector3(anchor.dx, anchor.dy, 0);

      final flipMatrix = Matrix4.identity()
        ..postFlip(
          flipX: true,
          flipY: false,
          anchor: anchor,
        );

      final skewMatrix = Matrix4.identity()
        /*..translate(translation)*/
        ..postConcat(Matrix4.skew(45.hd, 0)) /*..translate(-translation)*/;
      /*..skewBy(
          kx: 45.hd,
          ky: 0,
          anchor: anchor,
        );*/
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(
          sx: 2,
          sy: 2,
          anchor: anchor,
        );

      final rotateMatrix = Matrix4.identity()
        ..rotateBy(
          30.hd,
          anchor: anchor,
        );

      final x = rotateMatrix.rotationX;
      final y = rotateMatrix.rotationY;
      final z = rotateMatrix.rotationZ;
      final r = rotateMatrix.rotation;

      //Quaternion.fromRotation(rotateMatrix.getRotation()).z;

      //debugger();

      final translateMatrix = Matrix4.identity()..translate(100.0, 100.0);

      /*canvas.withMatrix(
        translateMatrix   * rotateMatrix  *  scaleMatrix   *  skewMatrix
        */ /*pp.paintFlipMatrix*/ /*
        */ /*translateMatrix **/ /*
        */ /*rotateMatrix * scaleMatrix */ /*
        */ /** rotateMatrix*/ /* */ /* * flipMatrix * skewMatrix*/ /*,
        () {
          textPainter.paint(canvas, Offset.zero);
        },
      );*/

      // 真实的缩放矩阵
      final skewMatrix1 = Matrix4.skew(45.hd, 0);
      final skewMatrix12 = Matrix4.identity()
        ..translate(translation)
        ..postConcat(skewMatrix)
        ..translate(-translation);

      //debugger();

      canvas.withMatrix(
        pp.operateMatrix,
        () {
          textPainter.paint(canvas, Offset.zero);
        },
      );
    });
  }
}
