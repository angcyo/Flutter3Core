part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/16
///
/// [Paint]
/// [Canvas]
/// [Image]
/// [ui.Path]
/// [ui.Image]
/// [ui.Picture]
/// [ui.Paragraph]

/// 自定义的绘制方法
/// [childRect] 当前元素的绘制区域
/// [parentRect] 父元素的绘制区域
typedef PainterFn = void Function(
    Canvas canvas, Rect childRect, Rect parentRect);

/// [CustomPaint]
/// [CustomPainter]
typedef PaintFn = void Function(Canvas canvas, Size size);

extension StringPaintEx on String {
  /// [TextSpanPaintEx.textSize]
  Size textSize({double? fontSize, TextStyle? style}) => TextSpan(
        text: this,
        style: style ?? TextStyle(fontSize: fontSize),
      ).textSize();

  /// [TextSpanPaintEx.textWidth]
  double textWidth({double? fontSize, TextStyle? style}) =>
      textSize(fontSize: fontSize, style: style).width;

  /// [TextSpanPaintEx.textSize]
  double textHeight({double? fontSize, TextStyle? style}) => textSize(
        fontSize: fontSize,
        style: style,
      ).height;
}

extension TextSpanPaintEx on InlineSpan {
  /// 获取文本的大小
  Size textSize() {
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      text: this,
    );
    textPainter.layout();
    return textPainter.size;
  }

  /// 获取文本的宽度
  double textWidth() => textSize().width;

  /// 获取文本的高度
  double textHeight() => textSize().height;
}

/// 画布[Canvas]的一些扩展
extension CanvasEx on Canvas {
  /// 入栈出栈, 保证绘制的状态不会影响到其他的绘制
  /// 一些简单的变换操作可以使用此方法
  void withSave(VoidCallback callback) {
    final saveCount = getSaveCount();
    save();
    try {
      callback();
    } finally {
      restoreToCount(saveCount);
    }
  }

  /// 图层的一些操作可以使用此方法, 比如图层透明, 图层颜色过滤等
  void withSaveLayer(VoidCallback callback) {
    final saveCount = getSaveCount();
    saveLayer(null, Paint());
    try {
      callback();
    } finally {
      restoreToCount(saveCount);
    }
  }

  /// 平移到指定点绘制并恢复画布属性
  void withTranslate(double tx, double ty, VoidCallback callback) {
    if (tx == 0 && ty == 0) {
      callback();
    } else {
      withSave(() {
        translate(tx, ty);
        callback();
      });
    }
  }

  /// 在指定位置旋转角度
  /// [degrees] 角度
  /// [radians] 弧度, 如果指定了弧度优先使用此值
  /// [pivotX].[pivotY]旋转的锚点
  void withRotate(
    double degrees,
    VoidCallback callback, {
    double? radians,
    double pivotX = 0,
    double pivotY = 0,
  }) {
    radians ??= degrees.toRadians;
    if (radians == 0) {
      callback();
    } else {
      withSave(() {
        translate(pivotX, pivotY);
        rotate(radians!);
        translate(-pivotX, -pivotY);
        callback();
      });
    }
  }

  /// 在指定位置缩放
  void withScale(
    double sx,
    double sy,
    VoidCallback callback, {
    double pivotX = 0,
    double pivotY = 0,
  }) {
    if (sx == 1 && sy == 1) {
      callback();
    } else {
      withSave(() {
        translate(pivotX, pivotY);
        scale(sx, sy);
        translate(-pivotX, -pivotY);
        callback();
      });
    }
  }

  /// 在指定位置倾斜/扭曲
  void withSkew(
    double sx,
    double sy,
    VoidCallback callback, {
    double pivotX = 0,
    double pivotY = 0,
  }) {
    if (sx == 0 && sy == 0) {
      callback();
    } else {
      withSave(() {
        translate(pivotX, pivotY);
        skew(sx, sy);
        translate(-pivotX, -pivotY);
        callback();
      });
    }
  }

  /// 使用矩阵变换
  void withMatrix(Matrix4? matrix4, VoidCallback callback) {
    if (matrix4 == null) {
      callback();
    } else {
      withSave(() {
        transform(matrix4.storage);
        callback();
      });
    }
  }

  void withClipRRect(RRect? rect, VoidCallback callback) {
    if (rect == null || rect.isEmpty) {
      callback();
    } else {
      withSaveLayer(() {
        clipRRect(rect);
        callback();
      });
    }
  }

  void withClipPath(Path? path, VoidCallback callback) {
    if (path == null || path.isEmpty) {
      callback();
    } else {
      withSaveLayer(() {
        clipPath(path);
        callback();
      });
    }
  }
}
