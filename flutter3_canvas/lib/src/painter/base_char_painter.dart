part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/11/18
///
/// 单字符逐个绘制
/// - 包含每个字符的信息
/// - 包含字符所在行的信息
abstract class BaseCharPainter {
  /// 调试模式下, 是否绘制文本的边界
  @configProperty
  bool debugPaintBounds = false;

  //MARK: char

  /// 字符最原始的边界信息 left, ascent, descent
  /// - 绘制的时候, 需要偏移到与左上角0,0对齐的锚点上
  ///
  /// # 正常
  /// - h : Rect.fromLTRB(4.1, -34.6, 22.6, 0.0)
  /// - g : Rect.fromLTRB(2.3, -24.1, 23.7, 10.9)
  /// - ' ' : Rect.fromLTRB(0.0, -15.7, 15.7, 0.0)
  /// - j : Rect.fromLTRB(-1.8, -33.4, 8.3, 10.7)
  /// - F : Rect.fromLTRB(4.4, -31.8, 22.5, 0.0)
  ///
  /// # 顺时针旋转90°
  /// - h : Rect.fromLTRB(0.0, 4.1, 34.6, 22.6)
  /// - g : Rect.fromLTRB(-10.9, 2.3, 24.1, 23.7)
  ///
  /// [UiLineMetrics]
  @configProperty
  Rect charBounds;

  /// 字符边界[charBounds]与0,0的距离
  @autoInjectMark
  Offset charOriginOffset = Offset.zero;

  /// 字符对齐[lineBaseline]还需要的偏移量
  @autoInjectMark
  Offset charBaselineOffset = Offset.zero;

  /// 在[charBounds]的基础上, 抹平了[lineBaseline]带来的偏移量对应的0,0位置的矩形
  @autoInjectMark
  Rect charOriginBounds = Rect.zero;

  /// 字符本身绕着自己中心[charOriginBounds]需要的旋转矩阵
  /// - 横排旋转
  /// - 竖排旋转
  @autoInjectMark
  Matrix4? charRotateMatrix;

  /// - [charOriginBounds]
  /// - [charRotateMatrix]
  Rect get charOriginBoundsRotate =>
      charRotateMatrix?.mapRect(charOriginBounds) ?? charOriginBounds;

  //MARK: line

  /// 描述了当前行的起始绘制位置信息
  /// - 包含行的整体偏移, 多行文本时有效
  /// - [lineWidth]
  /// - [lineHeight]
  @autoInjectMark
  Offset lineStartOffset = Offset.zero;

  /// 在当前行中需要的对齐偏移
  /// - 包含跟最大行宽高对齐方式的偏移
  /// - 包含baseline的对齐偏移,
  @autoInjectMark
  Offset alignOffset = Offset.zero;

  //MARK: line temp

  /// 这一行的所有文本都在在这个基准线上绘制, 距离行top的正值.
  /// 如果所有字符都没有[descender], 那么[lineBaseline]会等于行高
  /// 用来计算基线的[alignOffset]
  ///
  /// - 如果是竖排旋转绘制, 这个值就是距离right的正值.
  ///
  @autoInjectMark
  @tempFlag
  double lineBaseline = 0;

  /// 当前所在行的宽度, 用来实现对齐
  @autoInjectMark
  @tempFlag
  double lineWidth = 0;

  /// 当前所在行的高度, 用来实现对齐
  @autoInjectMark
  @tempFlag
  double lineHeight = 0;

  /// 当前行, 最大的上升高度, 负值
  /// 矢量文本时有用, 测量行的最大高度
  @autoInjectMark
  @tempFlag
  double lineAscender = 0;

  /// 当前行, 最大的下降高度, 正值
  /// 矢量文本时有用, 测量行的最大高度
  @autoInjectMark
  @tempFlag
  double lineDescender = 0;

  //MARK: curve

  /// 在曲线上间隙占用的弧度, 可能是负数
  @autoInjectMark
  @tempFlag
  double? charCurveGapAngle;

  /// 在曲线上弦长对应的弧度
  @autoInjectMark
  @tempFlag
  double? charCurveAngle;

  /// 这一行, 对应曲线的半径
  @autoInjectMark
  @tempFlag
  double? lineCurveRadius;

  /// 字符对应的曲线绘制矩阵
  @autoInjectMark
  Matrix4? charCurveMatrix;

  BaseCharPainter({this.charBounds = Rect.zero}) {
    charOriginOffset = charBounds.lt;
  }

  //MARK: get

  /// 整体作用的绘制矩阵
  @output
  Matrix4 get outputPaintMatrix =>
      _charOffsetMatrix..postConcat(charCurveMatrix);

  /// [charBounds]平移到目标位置后的矩形信息
  @output
  Rect get chartOffsetBounds => _charOffsetMatrix.mapRect(charBounds);

  /// 绘制到0,0位置的矩阵
  Matrix4 get _charOriginMatrix => createTranslateMatrix(
    offset: -charOriginOffset /*对齐0,0*/ + charBaselineOffset /*对齐baseline*/,
  );

  /// 绘制到正确的位置时, 需要作用的矩阵
  Matrix4 get _charOffsetMatrix => Matrix4.identity()
    ..postConcat(_charOriginMatrix)
    ..postConcat(charRotateMatrix)
    ..postConcat(
      createTranslateMatrix(
        offset: lineStartOffset /*对齐行头*/ + alignOffset, //对齐行align
      ),
    );

  /// 上升距离, 负值
  /// [UiLineMetrics.ascender]
  double get ascender => charBounds.top;

  /// 下降距离, 正值
  /// [UiLineMetrics.descender]
  double get descender => charBounds.bottom;

  double get lineLeft => lineStartOffset.dx;

  double get lineTop => lineStartOffset.dy;

  double get lineCenterX => lineStartOffset.dx + lineWidth / 2;

  double get lineCenterY => lineStartOffset.dy + lineHeight / 2;

  double get lineBottom => lineStartOffset.dy + lineHeight;

  double get lineRight => lineStartOffset.dx + lineWidth;

  //MARK: core

  /// 绘制入口
  @api
  @entryPoint
  void paint(Canvas canvas, Offset offset) {
    canvas.withMatrix(outputPaintMatrix, () {
      assert(() {
        if (debugPaintBounds) {
          final rect = charBounds;
          canvas.drawRect(
            rect + offset,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.purpleAccent,
          );
        }
        return true;
      }());
      //debugger();
      onPaintSelf(canvas, offset);
    });
  }

  /// 自绘
  @overridePoint
  void onPaintSelf(Canvas canvas, Offset offset) {}
}

/// 单文本字符逐个绘制
/// 使用[TextPainter]绘制单个文本
class CharTextPainter extends BaseCharPainter {
  /// 绘制的字符
  final String char;

  /// 绘制对象
  final TextPainter? charPainter;

  CharTextPainter(this.char, this.charPainter, {super.charBounds});

  /// 绘制
  @override
  void onPaintSelf(Canvas canvas, Offset offset) {
    //debugger();
    //super.onPaintSelf(canvas, offset);
    charPainter?.paint(canvas, offset + charBounds.lt);
    /*if (isInCurve) {
      charPainter?.paint(canvas, offset);
    } else {
      charPainter?.paint(canvas, offset + alignOffset + charBounds.lt);
      */ /*canvas.drawPath(
          Path()..addRect(bounds + offset + alignOffset),
          Paint()
            ..color = Colors.red
            ..strokeWidth = 0
            ..style = PaintingStyle.stroke);*/ /*
    }*/
  }
}

/// 单个矢量字符绘制
class CharPathPainter extends BaseCharPainter {
  /// 字符
  final String char;

  /// 字符对应的矢量数据, 直接绘制, 请在赋值之前做好变换操作
  final Path charPath;

  /// 绘制画笔
  final Paint? charPaint;

  /// 结合[paintMatrix]后, 输出的[Path],
  /// 可以用来输出存档和输出雕刻数据
  @output
  Path? get outputPath {
    if (charPath == kEmptyPath || charPath.isEmpty) {
      return null;
    }
    final result = charPath.transformPath(outputPaintMatrix);
    return result;
  }

  CharPathPainter(this.char, this.charPath, this.charPaint, {super.charBounds});

  /// 绘制
  @override
  void onPaintSelf(Canvas canvas, Offset offset) {
    //debugger();
    //2super.onPaintSelf(canvas, offset);
    final paint = charPaint;
    //paint?.strokeWidth = 0;
    if (paint != null && charPath != kEmptyPath) {
      canvas.drawPath(charPath.shift(offset), paint);
    }
  }
}
