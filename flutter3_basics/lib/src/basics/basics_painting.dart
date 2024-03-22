part of '../../flutter3_basics.dart';

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

/// 提示当前图层中的绘画很复杂，并且会从缓存中受益
void setCanvasIsComplexHint(PaintingContext context, Decoration? decoration) {
  if (decoration != null) {
    if (decoration.isComplex) {
      context.setIsComplexHint();
    }
  }
}

/// 自定义的绘制方法
/// [childRect] 当前元素的绘制区域
/// [parentRect] 父元素的绘制区域
typedef PainterFn = void Function(
    Canvas canvas, Rect childRect, Rect parentRect);

/// [CustomPaint]
/// [CustomPainter]
typedef PaintFn = void Function(Canvas canvas, Size size);

typedef CanvasAction = void Function(Canvas canvas);

/// 使用[Canvas]绘制图片
/// [DecorationImage]
/// [paintImage]
/// [applyBoxFit]
ui.Picture drawPicture(
  Size size,
  CanvasAction action,
) {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
  action(canvas);
  return recorder.endRecording();
}

/// 使用[Canvas]绘制图片
Future<ui.Image> drawImage(
  Size size,
  CanvasAction callback,
) {
  final ui.Picture picture = drawPicture(size, callback);
  return picture.toImage(
    size.width.ceil(),
    size.height.ceil(),
  );
}

/// 使用[Canvas]绘制图片
ui.Image drawImageSync(
  Size size,
  CanvasAction callback,
) {
  final ui.Picture picture = drawPicture(size, callback);
  return picture.toImageSync(
    size.width.ceil(),
    size.height.ceil(),
  );
}

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
  /// [TextPainter.paint]
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
  //region ---with---

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
  void withSaveLayer(VoidCallback callback, [Paint? paint]) {
    final saveCount = getSaveCount();
    saveLayer(null, paint ?? ui.Paint());
    try {
      callback();
    } finally {
      restoreToCount(saveCount);
    }
  }

  /// 在指定锚点处操作矩阵
  void withPivot(
    VoidCallback action,
    VoidCallback callback, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
  }) {
    if (anchor != null) {
      pivotX = anchor.dx;
      pivotY = anchor.dy;
    }

    withSave(() {
      if (pivotX == 0 && pivotY == 0) {
        action();
        callback();
      } else {
        translate(pivotX, pivotY);
        action();
        translate(-pivotX, -pivotY);
        callback();
      }
    });
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

  /// [withTranslate]
  void withOffset(Offset offset, VoidCallback callback) {
    withTranslate(offset.dx, offset.dy, callback);
  }

  /// 在指定位置旋转角度
  /// [degrees] 角度
  /// [radians] 弧度, 如果指定了弧度优先使用此值
  /// [pivotX].[pivotY]旋转的锚点
  void withRotate(
    num degrees,
    VoidCallback callback, {
    double? radians,
    double pivotX = 0,
    double pivotY = 0,
  }) {
    withRotateRadians(
      radians ??= degrees.toRadians,
      callback,
      pivotX: pivotX,
      pivotY: pivotY,
    );
  }

  /// 旋转, 使用弧度单位
  void withRotateRadians(
    double radians,
    VoidCallback callback, {
    double pivotX = 0,
    double pivotY = 0,
    ui.Offset? anchor,
  }) {
    if (radians == 0) {
      callback();
    } else {
      withPivot(() {
        rotate(radians);
      }, callback, anchor: anchor, pivotX: pivotX, pivotY: pivotY);
    }
  }

  /// 在指定位置缩放
  void withScale(
    double sx,
    double sy,
    VoidCallback callback, {
    double pivotX = 0,
    double pivotY = 0,
    ui.Offset? anchor,
  }) {
    if (sx == 1 && sy == 1) {
      callback();
    } else {
      withPivot(() {
        scale(sx, sy);
      }, callback, anchor: anchor, pivotX: pivotX, pivotY: pivotY);
    }
  }

  /// 在指定位置倾斜/扭曲
  void withSkew(
    double sx,
    double sy,
    VoidCallback callback, {
    double pivotX = 0,
    double pivotY = 0,
    ui.Offset? anchor,
  }) {
    if (sx == 0 && sy == 0) {
      callback();
    } else {
      withPivot(() {
        skew(sx, sy);
      }, callback, anchor: anchor, pivotX: pivotX, pivotY: pivotY);
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

  void withClipRect(Rect? rect, VoidCallback callback) {
    if (rect == null || rect.isEmpty) {
      callback();
    } else {
      withSaveLayer(() {
        clipRect(rect);
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

  //endregion ---with---

  //region ---draw---

  /// 绘制文本, 绘制出来的文本左上角对齐0,0位置
  /// [getOffset] 获取文本的绘制位置的回调
  void drawText(
    String? text, {
    Color? textColor = Colors.black,
    double? fontSize = kDefaultFontSize,
    ui.Offset offset = ui.Offset.zero,
    Offset? Function(TextPainter painter)? getOffset,
  }) {
    final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(this, (getOffset?.call(painter) ?? ui.Offset.zero) + offset);
  }

  /// 绘制[picture]
  /// [pictureSize] 图片原始的大小
  /// [dst] 绘制的位置以及大小
  ///
  void drawPictureInRect(
    ui.Picture? picture, {
    Size? pictureSize,
    Rect? dst,
    Color? tintColor,
    ui.ColorFilter? colorFilter,
  }) {
    if (picture == null) {
      return;
    }
    withSave(() {
      colorFilter ??= tintColor?.toColorFilter();
      if (dst != null) {
        translate(dst.left, dst.top);
        if (pictureSize != null) {
          final sx = dst.width / pictureSize.width;
          final sy = dst.height / pictureSize.height;
          scale(sx, sy);
        }
      }
      if (colorFilter != null) {
        saveLayer(null, Paint()..colorFilter = colorFilter);
      }
      this.drawPicture(picture);
    });
  }

//endregion ---draw---
}
