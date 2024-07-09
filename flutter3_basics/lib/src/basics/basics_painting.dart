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
ui.Picture drawPicture(@dp Size size, CanvasAction action) {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
  action(canvas);
  return recorder.endRecording();
}

/// 使用[Canvas]绘制图片
/// [size] 绘制的大小, 像素单位
/// [pixelRatio] 像素密度[dpr]
Future<ui.Image> drawImage(@dp Size size, CanvasAction callback,
    [double? pixelRatio]) {
  final radio = pixelRatio ?? 1;
  final width = size.width * radio;
  final height = size.height * radio;
  final ui.Picture picture = drawPicture(size, callback);
  if (radio == 1) {
    return picture.toImage(width.imageInt, height.imageInt);
  }
  final ui.Picture result = drawPicture(ui.Size(width, height), (canvas) {
    canvas.scale(radio, radio);
    canvas.drawPicture(picture);
  });
  return result.toImage(width.imageInt, height.imageInt);
}

/// 使用[Canvas]绘制图片
/// [double.round] 四舍五入
/// [double.ceil] 向上取整
ui.Image drawImageSync(@dp Size size, CanvasAction callback) {
  final ui.Picture picture = drawPicture(size, callback);
  return picture.toImageSync(size.width.imageInt, size.height.imageInt);
}

extension StringPaintEx on String {
  /// [TextSpanPaintEx.textSize]
  Size textSize({@dp double? fontSize, TextStyle? style}) => TextSpan(
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
      try {
        restoreToCount(saveCount);
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
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
    ui.Offset? anchor,
  }) {
    withRotateRadians(
      radians ??= degrees.toRadians,
      callback,
      anchor: anchor,
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

  /// 此方法只能clip当前[Layer]的canvas
  /// 此时需要使用[PaintingContext.pushClipRect]
  /// [ClipRectLayer]
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

  /// 将原本在[src]位置绘制的东西, 绘制到[dst]位置
  /// 会自动平移到[dst]矩形位置, 并且缩放至[dst]矩形大小
  /// [dst] 绘制到的目标位置和大小. 包含了[dstPadding]
  /// [dstPadding] 目标位置的内边距
  /// [src] 目标的大小和位置
  /// [colorFilter] 着色器. [tintColor]着色
  void drawInRect(
    Rect? dst /*最终位置*/,
    Rect? src /*原始位置*/,
    VoidCallback drawCallback, {
    EdgeInsets? dstPadding,
    Color? tintColor,
    ui.ColorFilter? colorFilter,
    BoxFit? fit,
    Alignment? alignment = Alignment.center,
  }) {
    //debugger();
    if (dst == null || src == null) {
      drawCallback();
      return;
    }
    colorFilter ??= tintColor?.toColorFilter();

    final targetSize = src.size;
    final Size fitTargetSize;

    //debugger();

    if (fit != null) {
      //获取fit作用后的大小
      final fitSize = applyBoxFit(fit, targetSize, dst.size);
      fitTargetSize = fitSize.destination;
      //debugger();
    } else {
      fitTargetSize = targetSize;
    }

    if (alignment != null) {
      //获取对齐后的矩形位置
      final destinationRect = alignment.inscribe(fitTargetSize, dst);
      dst = destinationRect;
    } else {
      dst = ui.Rect.fromLTWH(
          dst.left, dst.top, fitTargetSize.width, fitTargetSize.height);
    }

    final drawLeft = dst.left + (dstPadding?.left ?? 0);
    final drawTop = dst.top + (dstPadding?.top ?? 0);
    final drawWidth = dst.width - (dstPadding?.horizontal ?? 0);
    final drawHeight = dst.height - (dstPadding?.vertical ?? 0);

    //平移到目标
    final translateMatrix = Matrix4.identity()
      ..translate(drawLeft - src.left, drawTop - src.top);

    final sx = drawWidth / targetSize.width;
    final sy = drawHeight / targetSize.height;
    //缩放到目标大小
    final scaleMatrix = Matrix4.identity()
      ..scaleBy(sx: sx, sy: sy, anchor: src.topLeft);

    withMatrix(translateMatrix * scaleMatrix, () {
      //着色
      if (colorFilter != null) {
        saveLayer(null, Paint()..colorFilter = colorFilter);
      }

      //绘制
      drawCallback();
    });
  }

  /// 缩放[Path]绘制到指定的目标内
  /// [dst] 元素需要绘制的区域,也是元素最终要绘制到的位置, 会根据[fit].[alignment]自动调整
  /// [drawInRect]
  void drawPathIn(
    Path? path,
    Rect? pathBounds,
    Rect? dst, {
    Paint? paint,
    EdgeInsets? dstPadding,
    Color? tintColor,
    ui.ColorFilter? colorFilter,
    BoxFit? fit = BoxFit.contain,
    Alignment? alignment = Alignment.center,
  }) {
    if (path == null) {
      return;
    }
    paint ??= Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = ui.PaintingStyle.stroke;
    if (dst == null) {
      drawPath(path, paint);
      return;
    }
    pathBounds ??= path.getExactBounds();

    final targetSize = pathBounds.size;
    final Size fitTargetSize;

    //debugger();

    if (fit != null) {
      //获取fit作用后的大小
      final fitSize = applyBoxFit(fit, targetSize, dst.size);
      fitTargetSize = fitSize.destination;
      //debugger();
    } else {
      fitTargetSize = targetSize;
    }

    if (alignment != null) {
      //获取对齐后的矩形位置
      final Rect destinationRect = alignment.inscribe(fitTargetSize, dst);
      dst = destinationRect;
    } else {
      dst = ui.Rect.fromLTWH(
          dst.left, dst.top, fitTargetSize.width, fitTargetSize.height);
    }

    final drawLeft = dst.left + (dstPadding?.left ?? 0);
    final drawTop = dst.top + (dstPadding?.top ?? 0);
    final drawWidth = dst.width - (dstPadding?.horizontal ?? 0);
    final drawHeight = dst.height - (dstPadding?.vertical ?? 0);

    //平移到目标
    final translateMatrix = Matrix4.identity()
      ..translate(drawLeft - pathBounds.left, drawTop - pathBounds.top);

    final sx = drawWidth / targetSize.width;
    final sy = drawHeight / targetSize.height;
    //缩放到目标大小
    final scaleMatrix = Matrix4.identity()
      ..scaleBy(sx: sx, sy: sy, anchor: pathBounds.topLeft);

    final targetPath = path.transformPath(translateMatrix * scaleMatrix);
    withSave(() {
      //着色
      if (colorFilter != null) {
        saveLayer(null, Paint()..colorFilter = colorFilter);
      }
      drawPath(targetPath, paint!);
    });
  }

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
  /// [dst] 绘制的目标位置以及大小
  ///
  void drawPictureInRect(
    ui.Picture? picture, {
    Size? pictureSize,
    Rect? dst,
    Color? tintColor,
    ui.ColorFilter? colorFilter,
    EdgeInsets? dstPadding,
  }) {
    if (picture == null) {
      return;
    }
    drawInRect(dst, pictureSize?.toRect(), () {
      this.drawPicture(picture);
    }, tintColor: tintColor, colorFilter: colorFilter, dstPadding: dstPadding);
  }

  /// 绘制[ui.Image]
  void drawImageInRect(
    ui.Image? image, {
    Rect? dst,
    Color? tintColor,
    ui.ColorFilter? colorFilter,
  }) {
    if (image == null) {
      return;
    }
    final imageSize = Size(image.width + 0.0, image.height + 0.0);
    drawInRect(dst, imageSize.toRect(), () {
      this.drawImage(image, ui.Offset.zero, Paint());
    }, tintColor: tintColor, colorFilter: colorFilter);
  }

//endregion ---draw---
}

extension PaintEx on Paint {
  /// 保存所有画笔属性, 并操作完后恢复
  void withSavePaint(VoidCallback callback) {
    final oldColor = color;
    final oldStyle = style;
    final oldStrokeWidth = strokeWidth;
    final oldStrokeCap = strokeCap;
    final oldStrokeJoin = strokeJoin;
    try {
      callback();
    } finally {
      color = oldColor;
      style = oldStyle;
      strokeWidth = oldStrokeWidth;
      strokeCap = oldStrokeCap;
      strokeJoin = oldStrokeJoin;
    }
  }

  /// 从另一个画笔中复制属性
  void setFrom(Paint other) {
    isAntiAlias = other.isAntiAlias;

    color = other.color;
    style = other.style;
    strokeWidth = other.strokeWidth;
    strokeCap = other.strokeCap;
    strokeJoin = other.strokeJoin;

    shader = other.shader;
    colorFilter = other.colorFilter;
    filterQuality = other.filterQuality;
    maskFilter = other.maskFilter;
    filterQuality = other.filterQuality;
    blendMode = other.blendMode;
    imageFilter = other.imageFilter;
    invertColors = other.invertColors;
    strokeMiterLimit = other.strokeMiterLimit;
  }
}
