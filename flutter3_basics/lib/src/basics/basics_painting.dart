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
/// [cullRect] 剔除区域
///
/// [DecorationImage]
/// [paintImage]
/// [applyBoxFit]
ui.Picture drawPicture(
  CanvasAction action, {
  @dp Size? cullSize,
  @dp Rect? cullRect,
}) {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final canvas = Canvas(
      recorder,
      cullRect ??
          (cullSize == null
              ? null
              : Rect.fromLTWH(0, 0, cullSize.width, cullSize.height)));
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
  final ui.Picture picture = drawPicture(callback, cullSize: size);
  if (radio == 1) {
    return picture.toImage(width.imageInt, height.imageInt);
  }
  final ui.Picture result = drawPicture((canvas) {
    canvas.scale(radio, radio);
    canvas.drawPicture(picture);
  }, cullSize: ui.Size(width, height));
  return result.toImage(width.imageInt, height.imageInt);
}

/// 使用[Canvas]绘制图片
/// [double.round] 四舍五入
/// [double.ceil] 向上取整
ui.Image drawImageSync(@dp Size size, CanvasAction callback) {
  final ui.Picture picture = drawPicture(callback, cullSize: size);
  //debugger();
  return picture.toImageSync(size.width.imageInt, size.height.imageInt);
}

extension StringPaintEx on String {
  /// 将Svg中的transform属性转换成[Matrix4]
  /// ```
  /// transform="rotate(-10 50 100)
  ///                translate(-36 45.5)
  ///                skewX(40)
  ///                scale(1 0.5)"
  ///
  /// transform="matrix(3 1 -1 3 30 40)"
  /// ```
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/transform
  Matrix4? get transformMatrix {
    Matrix4? matrix;

    //
    List<double>? readTransform(String attr, String type) {
      int i = attr.indexOf("$type(");
      if (i > -1) {
        i += type.length + 1;
        int j = attr.indexOf(")", i);
        if (j > -1) {
          List<double> np = attr.substring(i, j).parseNumbers();
          if (np.size() > 0) {
            return np;
          }
        }
      }
      return null;
    }

    //matrix
    if (startsWith("matrix(")) {
      List<double> np = substring("matrix(".length).parseNumbers();
      if (np.size() == 6) {
        //noinspection ConstantConditions
        /*final matrix3 = Matrix3.fromList([
          // Row 1
          np.get(0)!, np.get(2)!, np.get(4)!,
          // Row 2
          np.get(1)!, np.get(3)!, np.get(5)!,
          // Row 3
          0, 0, 1,
        ]);*/
        final matrix3 = Matrix3.fromList([
          //sx ky .
          np.get(0)!, np.get(1)!, 0,
          //kx sy .
          np.get(2)!, np.get(3)!, 0,
          //tx ty .
          np.get(4)!, np.get(5)!, 1,
        ]);
        //debugger();
        matrix = matrix3.toMatrix4();
      }
    }

    //scale
    List<double>? np = readTransform(this, "scale");
    if (np != null) {
      double sx = np.get(0)!;
      double sy = sx;
      if (np.size() > 1) {
        sy = np.get(1)!;
      }
      matrix ??= Matrix4.identity();
      //postScale
      matrix = matrix * Matrix4.diagonal3Values(sx, sy, 1);
    }

    //skewX
    np = readTransform(this, "skewX");
    if (np != null) {
      //角度, 弧度
      double angle = np.get(0)!;
      matrix ??= Matrix4.identity();
      //preSkew
      matrix = Matrix4.skew(tan(angle), 0) * matrix;
    }

    //skewY
    np = readTransform(this, "skewY");
    if (np != null) {
      //角度, 弧度
      double angle = np.get(0)!;
      matrix ??= Matrix4.identity();
      //preSkew
      matrix = Matrix4.skew(0, tan(angle)) * matrix;
    }

    //rotate
    np = readTransform(this, "rotate");
    if (np != null) {
      double angle = np.get(0)!;
      double cx, cy;
      matrix ??= Matrix4.identity();
      if (np.size() > 2) {
        cx = np.get(1)!;
        cy = np.get(2)!;
        //preRotate
        matrix =
            Matrix4.identity().postRotate(angle.hd, pivotX: cx, pivotY: cy) *
                matrix;
      } else {
        //preRotate
        matrix = Matrix4.identity().postRotate(angle.hd) * matrix;
      }
    }

    //translate
    np = readTransform(this, "translate");
    if (np != null) {
      double tx = np.get(0)!;
      double ty = 0;
      if (np.size() > 1) {
        ty = np.get(1)!;
      }
      matrix ??= Matrix4.identity();
      //postTranslate
      matrix = matrix * Matrix4.identity().postTranslateBy(x: tx, y: ty);
    }

    return matrix;
  }

  /// 从字符串中解析出所有的浮点数字
  List<double> parseNumbers() {
    final int n = length;
    int p = 0;
    List<double> numbers = [];
    bool skipChar = false;
    for (int i = 1; i < n; i++) {
      if (skipChar) {
        skipChar = false;
        continue;
      }
      characters;
      String c = this[i];
      switch (c) {
        // This ends the parsing, as we are on the next element
        case 'M':
        case 'm':
        case 'Z':
        case 'z':
        case 'L':
        case 'l':
        case 'H':
        case 'h':
        case 'V':
        case 'v':
        case 'C':
        case 'c':
        case 'S':
        case 's':
        case 'Q':
        case 'q':
        case 'T':
        case 't':
        case 'a':
        case 'A':
        case ')':
          {
            String str = substring(p, i);
            if (str.trim().isNotEmpty) {
              //Log.d(TAG, "  Last: " + str);
              double f = double.parse(str);
              numbers.add(f);
            }
            return numbers;
          }
        case 'e':
        case 'E':
          {
            // exponent in float number - skip eventual minus sign following the exponent
            skipChar = true;
            break;
          }
        case '\n':
        case '\t':
        case ' ':
        case ',':
        case '-':
          {
            String str = substring(p, i);
            // Just keep moving if multiple whitespace
            if (str.trim().isNotEmpty) {
              //Log.d(TAG, "  Next: " + str);
              double f = double.parse(str);
              numbers.add(f);
              if (c == '-') {
                p = i;
              } else {
                p = i + 1;
                skipChar = true;
              }
            } else {
              p++;
            }
            break;
          }
      }
    }
    String last = substring(p);
    if (last.trim().isNotEmpty) {
      //Log.d(TAG, "  Last: " + last);
      try {
        numbers.add(double.parse(last));
      } catch (error) {
        // Just white-space, forget it
      }
    }
    return numbers;
  }

  //--

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

  /// 使用一个颜色着色
  void withColor(
    VoidCallback callback, {
    Color? tintColor,
    ui.ColorFilter? colorFilter,
  }) {
    colorFilter ??= tintColor?.toColorFilter();
    if (colorFilter == null) {
      callback();
    } else {
      withSaveLayer(callback, Paint()..colorFilter = colorFilter);
    }
  }

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
          l.v("withSaveLayer异常->$saveCount");
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
    if (matrix4 == null || matrix4.isIdentity()) {
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
  /// [dst] 绘制到的目标位置和大小.
  /// [dstPadding] 目标位置的内边距, 在[dst]内往内偏移
  /// [src] 目标的原始大小和位置
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
    String? debugLabel,
  }) {
    if (dst == null || src == null) {
      drawCallback();
      return;
    }
    final offsetLeft = dstPadding?.left ?? 0;
    final offsetTop = dstPadding?.top ?? 0;
    final offsetWidth = dstPadding?.horizontal ?? 0;
    final offsetHeight = dstPadding?.vertical ?? 0;

    colorFilter ??= tintColor?.toColorFilter();

    //平移到目标
    final translateMatrix = Matrix4.identity()
      ..translate(
        dst.left - src.left + offsetLeft,
        dst.top - src.top + offsetTop,
      );
    debugger(when: debugLabel != null);
    final scaleMatrix = applyAlignMatrix(
      Size(dst.width - offsetWidth, dst.height - offsetHeight),
      src.size,
      fit: fit,
      alignment: alignment,
      anchorOffset: src.topLeft,
      debugLabel: debugLabel,
    );

    withMatrix(translateMatrix * scaleMatrix, () {
      //着色
      if (colorFilter != null) {
        saveLayer(null, Paint()..colorFilter = colorFilter);
      }

      //绘制
      drawCallback();
    });

    /*//原始大小
    final originSize = src.size;
    //fit后的大小
    final Size fitTargetSize;

    //debugger();

    if (fit != null) {
      //获取fit作用后的大小
      final fitSize = applyBoxFit(
        fit,
        originSize,
        dst.size + Offset(-offsetWidth, -offsetHeight),
      );
      fitTargetSize = fitSize.destination;
      //debugger();
    } else {
      fitTargetSize = originSize;
    }

    if (alignment != null) {
      //获取对齐后的矩形位置
      final destinationRect = alignment.inscribe(fitTargetSize, dst);
      dst = destinationRect;
    } else {
      dst = ui.Rect.fromLTWH(
        dst.left,
        dst.top,
        fitTargetSize.width,
        fitTargetSize.height,
      );
    }

    final drawLeft = dst.left */ /* + offsetLeft*/ /*;
    final drawTop = dst.top */ /* + offsetTop*/ /*;
    double drawWidth = dst.width */ /*- offsetWidth*/ /*;
    if (drawWidth < 0) {
      drawWidth = dst.width;
    }
    double drawHeight = dst.height */ /*- offsetHeight*/ /*;
    if (drawHeight < 0) {
      drawHeight = dst.height;
    }
    debugger(when: debugLabel != null);

    //平移到目标
    final translateMatrix = Matrix4.identity()
      ..translate(drawLeft - src.left, drawTop - src.top);

    final sx = drawWidth / originSize.width;
    final sy = drawHeight / originSize.height;
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
    });*/
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
    bool? paintStrokeWidthSuppressScale = true,
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
      if (paint != null) {
        if (colorFilter != null) {
          saveLayer(null, Paint()..colorFilter = colorFilter);
        }
        if (paintStrokeWidthSuppressScale == true) {
          final scale = math.min(sx, sy);
          paint.strokeWidth = paint.strokeWidth / scale;
        }
        drawPath(targetPath, paint);
      }
    });
  }

  /// 绘制文本, 绘制出来的文本左上角对齐0,0位置
  /// [bounds].[alignment] 文本绘制在矩形框内的位置和对齐方式
  /// [offset].[getOffset] 获取文本的绘制位置的回调
  /// @return 返回文本的大小
  Size drawText(
    String? text, {
    //--
    TextStyle? textStyle,
    Color? textColor = Colors.black,
    double? fontSize = kDefaultFontSize,
    FontWeight? fontWeight,
    bool bold = false,
    List<Shadow>? shadows,
    bool shadow = false,
    //--
    TextAlign textAlign = TextAlign.start,
    //--
    Rect? bounds,
    Alignment alignment = Alignment.topLeft,
    ui.Offset offset = ui.Offset.zero,
    Offset? Function(TextPainter painter)? getOffset,
    //--绘制前的回调
    void Function(TextPainter painter, Offset offset)? onBeforeAction,
  }) {
    final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle ??
              TextStyle(
                color: textColor,
                fontSize: fontSize,
                shadows: shadows ??
                    (shadow
                        ? const <Shadow>[
                            Shadow(
                              offset: Offset(1, 1),
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ]
                        : null),
                fontWeight: fontWeight ?? (bold ? FontWeight.bold : null),
              ),
        ),
        textAlign: textAlign,
        textDirection: TextDirection.ltr)
      ..layout();
    final textOffset = (getOffset?.call(painter) ??
            (bounds == null
                ? ui.Offset.zero
                : alignment
                    .inscribe(Size(painter.width, painter.height), bounds)
                    .topLeft)) +
        offset;
    onBeforeAction?.call(painter, textOffset);
    painter.paint(this, textOffset);
    return painter.size;
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
    BoxFit? fit = BoxFit.contain,
    Alignment? alignment = Alignment.center,
    String? debugLabel,
  }) {
    if (picture == null) {
      return;
    }
    drawInRect(
      dst,
      pictureSize?.toRect(),
      () {
        this.drawPicture(picture);
      },
      tintColor: tintColor,
      colorFilter: colorFilter,
      dstPadding: dstPadding,
      fit: fit,
      alignment: alignment,
      debugLabel: debugLabel,
    );
  }

  /// 绘制指定大小的[ui.Image]
  /// [size] 强制指定绘制后, 目标图片的大小
  /// [width]/[height] 仅指定宽/高, 则等比缩放
  /// @return 返回绘制的图片大小
  Size? drawImageSize(
    ui.Image? image, {
    Offset? offset,
    Paint? paint,
    //--
    Size? size,
    double? width,
    double? height,
    //--
  }) {
    if (image == null) {
      return null;
    }
    offset ??= ui.Offset.zero;
    paint ??= Paint();
    final imageSize = Size(image.width + 0.0, image.height + 0.0);
    if (size == null && width == null && height == null) {
      this.drawImage(image, offset, paint);
      return imageSize;
    }
    double sx = 1;
    double sy = 1;
    if (size != null || (width != null && height != null)) {
      //强制指定输出尺寸
      size ??= Size(width ?? imageSize.width, height ?? imageSize.height);
      sx = size.width / imageSize.width;
      sy = size.height / imageSize.height;
    } else if (width != null) {
      sx = width / imageSize.width;
      sy = sx;
    } else if (height != null) {
      sy = height / imageSize.height;
      sx = sy;
    }
    final matrix = createScaleMatrix(sx: sx, sy: sy, anchor: offset);
    withMatrix(matrix, () {
      this.drawImage(image, offset!, paint!);
    });
    return Size(imageSize.width * sx, imageSize.height * sy);
  }

  /// 绘制[ui.Image]
  void drawImageInRect(
    ui.Image? image, {
    Rect? dst,
    Color? tintColor,
    ui.ColorFilter? colorFilter,
    BoxFit? fit,
    Alignment? alignment = Alignment.center,
    Paint? paint,
  }) {
    if (image == null) {
      return;
    }
    final imageSize = Size(image.width + 0.0, image.height + 0.0);
    drawInRect(dst, imageSize.toRect(), () {
      this.drawImage(image, ui.Offset.zero, paint ?? Paint());
    },
        tintColor: tintColor,
        colorFilter: colorFilter,
        fit: fit,
        alignment: alignment);
  }

  /// 在一个位置[position]绘制十字线
  void drawCross(
    Offset position, {
    double minX = 0,
    double? maxX,
    double minY = 0,
    double? maxY,
    Paint? paint,
  }) {
    paint ??= Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    drawLine(
      Offset(minX, position.dy),
      Offset(maxX ?? screenWidth, position.dy),
      paint,
    );
    drawLine(
      Offset(position.dx, minY),
      Offset(position.dx, maxY ?? screenHeight),
      paint,
    );
  }

  /// 绘制一个阴影
  /// [_BoxDecorationPainter]
  /// [Canvas.drawShadow]
  void drawShadows(
    Rect rect,
    List<BoxShadow>? boxShadows, {
    BorderRadiusGeometry? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    TextDirection? textDirection,
  }) {
    if (boxShadows == null || boxShadows.isEmpty) {
      return;
    }
    final canvas = this;
    for (final BoxShadow boxShadow in boxShadows) {
      final Paint paint = boxShadow.toPaint();
      final Rect bounds =
          rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      assert(() {
        if (debugDisableShadows && boxShadow.blurStyle == BlurStyle.outer) {
          canvas.save();
          canvas.clipRect(bounds);
        }
        return true;
      }());
      switch (shape) {
        case BoxShape.circle:
          assert(borderRadius == null);
          final Offset center = rect.center;
          final double radius = rect.shortestSide / 2.0;
          canvas.drawCircle(center, radius, paint);
        case BoxShape.rectangle:
          if (borderRadius == null || borderRadius == BorderRadius.zero) {
            canvas.drawRect(rect, paint);
          } else {
            canvas.drawRRect(
                borderRadius.resolve(textDirection).toRRect(rect), paint);
          }
      }
      assert(() {
        if (debugDisableShadows && boxShadow.blurStyle == BlurStyle.outer) {
          canvas.restore();
        }
        return true;
      }());
    }
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

extension AlignmentEx on Alignment {
  bool get isLeft =>
      this == AlignmentDirectional.topStart ||
      this == AlignmentDirectional.centerStart ||
      this == AlignmentDirectional.bottomStart ||
      this == Alignment.topLeft ||
      this == Alignment.centerLeft ||
      this == Alignment.bottomLeft;

  bool get isRight =>
      this == AlignmentDirectional.topEnd ||
      this == AlignmentDirectional.centerEnd ||
      this == AlignmentDirectional.bottomEnd ||
      this == Alignment.topRight ||
      this == Alignment.centerRight ||
      this == Alignment.bottomRight;

  bool get isTop =>
      this == AlignmentDirectional.topStart ||
      this == AlignmentDirectional.topCenter ||
      this == AlignmentDirectional.topEnd ||
      this == Alignment.topLeft ||
      this == Alignment.topCenter ||
      this == Alignment.topRight;

  bool get isBottom =>
      this == AlignmentDirectional.bottomStart ||
      this == AlignmentDirectional.bottomCenter ||
      this == AlignmentDirectional.bottomEnd ||
      this == Alignment.bottomLeft ||
      this == Alignment.bottomCenter ||
      this == Alignment.bottomRight;

  /// 根据对齐方式, 获取偏移量
  /// [Alignment.inscribe]
  /// [applyAlignMatrix]
  /// [applyAlignRect]
  /// [alignChildOffset]
  Offset offset([EdgeInsets? insets]) {
    var dx = 0.0;
    var dy = 0.0;
    //x
    switch (this) {
      case AlignmentDirectional.topStart:
      case AlignmentDirectional.centerStart:
      case AlignmentDirectional.bottomStart:
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        dx = insets?.left ?? 0;
        break;
      case AlignmentDirectional.topCenter:
      case AlignmentDirectional.center:
      case AlignmentDirectional.bottomCenter:
      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        dx = 0;
        break;
      case AlignmentDirectional.topEnd:
      case AlignmentDirectional.centerEnd:
      case AlignmentDirectional.bottomEnd:
      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        dx = -(insets?.right ?? 0);
        break;
    }
    //y
    switch (this) {
      case AlignmentDirectional.topStart:
      case AlignmentDirectional.topCenter:
      case AlignmentDirectional.topEnd:
      case Alignment.topLeft:
      case Alignment.topCenter:
      case Alignment.topRight:
        dy = insets?.top ?? 0;
        break;
      case AlignmentDirectional.centerStart:
      case AlignmentDirectional.center:
      case AlignmentDirectional.centerEnd:
      case Alignment.centerLeft:
      case Alignment.center:
      case Alignment.centerRight:
        dy = 0;
        break;
      case AlignmentDirectional.bottomStart:
      case AlignmentDirectional.bottomCenter:
      case AlignmentDirectional.bottomEnd:
      case Alignment.bottomLeft:
      case Alignment.bottomCenter:
      case Alignment.bottomRight:
        dy = -(insets?.bottom ?? 0);
        break;
    }
    return Offset(dx, dy);
  }
}
