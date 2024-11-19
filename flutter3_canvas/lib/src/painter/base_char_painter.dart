part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/11/18
///
/// 单字符逐个绘制
abstract class BaseCharPainter {
  /// 调试模式下, 是否绘制文本的边界
  bool debugPaintBounds = false;

  /// 在整体中绘制的区域, 不包含[alignOffset]
  /// 在曲线文本中, 会有特殊处理, 需要使用[paintBounds]
  @autoInjectMark
  Rect bounds = Rect.zero;

  /// 对齐偏移
  @autoInjectMark
  Offset alignOffset = Offset.zero;

  /// 当前所在行的宽度, 用来实现对齐
  @autoInjectMark
  double lineWidth = 0;

  /// 当前所在行的高度, 用来实现对齐
  @autoInjectMark
  double lineHeight = 0;

  /// 当前行, 最大的上升高度, 负值
  /// 矢量文本时有用
  @autoInjectMark
  double lineAscender = 0;

  /// 当前行, 最大的下降高度, 正值
  /// 矢量文本时有用
  @autoInjectMark
  double lineDescender = 0;

  //--paint--

  /// 绘制矩阵, 通常用来实现文本的曲线绘制
  @autoInjectMark
  Matrix4? paintMatrix;

  /// [bounds]与[paintMatrix]的集合, 通常在曲线文本中使用
  @autoInjectMark
  Rect paintBounds = Rect.zero;

  //--曲线--

  /// 是否是绘制在曲线上
  /// 标识当前对象是在曲线文本上绘制
  @autoInjectMark
  @flagProperty
  bool isInCurve = false;

  /// 在曲线上左边线的角度
  @autoInjectMark
  @flagProperty
  double? charCurveStartAngle;

  /// 在曲线上右边线的角度
  @autoInjectMark
  @flagProperty
  double? charCurveEndAngle;

  //--get--

  /// 包含了基线, 行高, 宽度
  @output
  UiLineMetrics? get lineMetrics => null;

  double get charWidth => bounds.width;

  double get charHeight => bounds.height;

  /// 上升距离, 负值
  double get ascender => 0;

  /// 下降距离, 正值
  double get descender => 0;

  //--core--

  /// 绘制入口
  @api
  @entryPoint
  void paint(Canvas canvas, Offset offset) {
    canvas.withMatrix(paintMatrix, () {
      assert(() {
        if (debugPaintBounds) {
          final rect = isInCurve ? bounds : bounds + alignOffset;
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

  /// 包含了基线, 行高, 宽度
  @output
  @override
  UiLineMetrics? get lineMetrics =>
      charPainter?.computeLineMetrics().firstOrNull;

  /// 下降的高度
  @implementation
  @override
  double get ascender {
    return charPainter?.computeLineMetrics().firstOrNull?.descent ?? 0;
  }

  @implementation
  @override
  double get descender {
    return charPainter?.computeLineMetrics().firstOrNull?.unscaledAscent ?? 0;
  }

  CharTextPainter(
    this.char,
    this.charPainter,
    Rect bounds,
  ) {
    this.bounds = bounds;
  }

  /// 绘制
  @override
  void onPaintSelf(Canvas canvas, Offset offset) {
    //debugger();
    if (isInCurve) {
      charPainter?.paint(canvas, offset);
    } else {
      charPainter?.paint(canvas, offset + alignOffset + bounds.lt);
      /*canvas.drawPath(
          Path()..addRect(bounds + offset + alignOffset),
          Paint()
            ..color = Colors.red
            ..strokeWidth = 0
            ..style = PaintingStyle.stroke);*/
    }
  }
}

/// 单个矢量字符绘制
class CharPathPainter extends BaseCharPainter {
  /// 字符
  final String char;

  /// 字符对应的矢量数据, 直接绘制, 请在赋值之前做好变换操作
  final Path charPath;

  /// [charPath]对应的边界
  final Rect charPathBounds;

  /// 绘制画笔
  final Paint? charPaint;

  /// 用于绘制的[charPath], 在某种程度上会等于[charPath].moveToZero后的结果
  final Path drawPath;

  /// 上升距离, 负值
  @override
  double get ascender => charPathBounds.top;

  /// 下降距离, 正值
  @override
  double get descender => charPathBounds.bottom;

  /// 结合[paintMatrix]后, 输出的[Path],
  /// 可以用来输出存档和输出雕刻数据
  @output
  Path? get outputPath {
    if (drawPath == kEmptyPath || drawPath.isEmpty) {
      return null;
    }
    Path result = drawPath.transformPath(paintMatrix);
    if (isInCurve) {
      return result;
    }
    return result.shift(alignOffset + bounds.lt);
  }

  CharPathPainter(
    this.char,
    this.charPath,
    this.charPathBounds,
    this.charPaint,
    this.drawPath,
    Rect bounds,
  ) {
    this.bounds = bounds;
  }

  /// 绘制
  @override
  void onPaintSelf(Canvas canvas, Offset offset) {
    //debugger();
    final paint = charPaint;
    if (paint != null && drawPath != kEmptyPath) {
      if (isInCurve) {
        canvas.drawPath(drawPath, paint);
      } else {
        canvas.drawPath(
            drawPath.shift(offset + alignOffset + bounds.lt), paint);
      }
    }
  }
}
