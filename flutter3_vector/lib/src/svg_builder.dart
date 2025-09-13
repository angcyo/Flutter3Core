part of '../flutter3_vector.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/04
///
/// 用来输出svg xml文档数据
/// - SVG：可缩放矢量图形 https://developer.mozilla.org/zh-CN/docs/Web/SVG
/// - SVG 元素参考 https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element
/// - SVG 属性参考 https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute
class SvgBuilder {
  /// [SvgBuilder.svgHeaderAnnotation]
  static String? customSvgHeaderAnnotation;

  /// 格式化数字
  static String? formatValue(dynamic value, {int digits = 6}) =>
      value is num ? value.toDigits(digits: digits) : value.toString();

  /// svg xml头部
  @configProperty
  String svgHeader = '<?xml version="1.0" encoding="UTF-8"?>';

  /// [svgHeader]头部下的注释描述字符串
  @configProperty
  String? svgHeaderAnnotation =
      '\n<!-- Created with angcyo (https://www.github.com/angcyo) -->\n';

  /// 额外放在svg中根节点的属性
  @configProperty
  Map<String, dynamic>? attributes;

  /// 浮点小数点位数
  @configProperty
  int digits = 6;

  @configProperty
  int version = 1;

  @configProperty
  String author = "angcyo";

  //--

  /// 数据输出
  @output
  StringBuffer buffer = StringBuffer();

  bool _isEnd = true;

  /// 写入[viewBox]属性
  /// [writeUnitTransform] 是否将[boundsUnit]缩放比例写入`transform`
  /// 通常在生成雕刻数据时, 才需要使用此属性
  ///
  /// viewBox 属性允许指定一个给定的一组图形伸展以适应特定的容器元素。
  ///
  /// viewBox 属性的值是一个包含 4 个参数的列表 `min-x`, `min-y`, `width` and `height`，以空格或者逗号分隔开，在用户空间中指定一个矩形区域映射到给定的元素，查看属性preserveAspectRatio。
  ///
  /// 不允许宽度和高度为负值，0 则禁用元素的呈现。
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/viewBox
  ///
  /// mac/windows上 1mm->3.7777px
  /// 1mm = 1/25.4 * 96 px ≈ 3.779527559 px
  ///
  void writeViewBox(
    @dp Rect? bounds, {
    IUnit? boundsUnit = IUnit.mm,
    @mm Rect? boundsMm,
    bool writeSvgProperty = false /*写入一些svg基础属性?*/,
    bool writeAcyProperty = false /*写入一些acy属性?*/,
    bool writeUnitTransform = false /*写入unit对应的transform?*/,
  }) {
    digits = boundsUnit?.digits ?? digits;
    //-
    buffer.write(svgHeader);
    (customSvgHeaderAnnotation ?? svgHeaderAnnotation)?.let((it) {
      if (it.contains("<!")) {
        buffer.write(it);
      } else {
        buffer.write('<!--$it-->');
      }
    });
    buffer.write('<svg xmlns="http://www.w3.org/2000/svg" ');
    buffer.write('xmlns:xlink="http://www.w3.org/1999/xlink" ');
    buffer.write('xmlns:acy="https://www.github.com/angcyo" ');

    //--
    /*buffer.write(
        'viewBox="${formatValue(bounds.left.toUnitFromDp(unit))} ${formatValue(bounds.top.toUnitFromDp(unit))} '
        '${formatValue(bounds.width.toUnitFromDp(unit))} ${formatValue(bounds.height.toUnitFromDp(unit))}" ');*/

    if (bounds != null) {
      //l t w h
      buffer.write(
        'viewBox="${formatSvgValue(bounds.left)} ${formatSvgValue(bounds.top)} '
        '${formatSvgValue(bounds.width)} ${formatSvgValue(bounds.height)}" ',
      );
      boundsMm ??= bounds.toRectUnit(boundsUnit);
    }

    //--
    if (boundsMm != null) {
      if (writeSvgProperty) {
        buffer.write(
          'width="${formatSvgValue(boundsMm.width)}${IUnit.mm.suffix}" '
          'height="${formatSvgValue(boundsMm.height)}${IUnit.mm.suffix}" ',
        );
      }
      if (writeAcyProperty) {
        buffer.write(
          'acy:width="${formatSvgValue(boundsMm.width)}${IUnit.mm.suffix}" '
          'acy:height="${formatSvgValue(boundsMm.height)}${IUnit.mm.suffix}" ',
        );

        buffer.write(
          'acy:x="${formatSvgValue(boundsMm.left)}${IUnit.mm.suffix}" '
          'acy:y="${formatSvgValue(boundsMm.top)}${IUnit.mm.suffix}" ',
        );
      }
    }
    if (boundsUnit != null) {
      if (writeUnitTransform) {
        final scale = 1.toUnitFromDp(boundsUnit);
        writeTransform(sx: scale, sy: scale);
      }
    }

    //--
    if (writeAcyProperty || writeSvgProperty) {
      buffer.write(
        'acy:author="$author" acy:version="$version" acy:build="${nowTimeString()}" ',
      );
    }
    //
    attributes?.forEach((key, value) {
      if (key.contains(":")) {
        buffer.write('$key="$value" ');
      } else if (value != null) {
        buffer.write('acy:$key="$value" ');
      }
    });
    //
    buffer.write('>');
    _isEnd = false;
  }

  /// 结束
  void writeEnd() {
    if (!_isEnd) {
      buffer.write(r'</svg>');
    }
  }

  //region --元素--

  /// 写入[line]元素
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/line
  ///
  void writeLine({
    double? x1,
    double? y1,
    double? x2,
    double? y2,
    Matrix4? transform,
    String fillRule = 'evenodd',
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) {
    buffer.write('<line ');
    writeId(id: id, name: name);
    if (x1 != null) {
      buffer.write('x1="${formatSvgValue(x1)}" ');
    }
    if (y1 != null) {
      buffer.write('y1="${formatSvgValue(y1)}" ');
    }
    if (x2 != null) {
      buffer.write('x2="${formatSvgValue(x2)}" ');
    }
    if (y2 != null) {
      buffer.write('y2="${formatSvgValue(y2)}" ');
    }
    writeStyle(
      fillRule: fillRule,
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write(' />');
  }

  /// 写入[oval]元素
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/ellipse
  ///
  void writeOval({
    double? cx,
    double? cy,
    double? rx,
    double? ry,
    Matrix4? transform,
    String fillRule = 'evenodd',
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) {
    buffer.write('<ellipse ');
    writeId(id: id, name: name);
    if (cx != null) {
      buffer.write('cx="${formatSvgValue(cx)}" ');
    }
    if (cy != null) {
      buffer.write('cy="${formatSvgValue(cy)}" ');
    }
    if (rx != null) {
      buffer.write('rx="${formatSvgValue(rx)}" ');
    }
    if (ry != null) {
      buffer.write('ry="${formatSvgValue(ry)}" ');
    }
    writeStyle(
      fillRule: fillRule,
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write(' />');
  }

  /// 写入[rect]元素
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/rect
  ///
  void writeRect({
    dynamic x,
    dynamic y,
    required dynamic width,
    required dynamic height,
    dynamic rx,
    dynamic ry,
    Matrix4? transform,
    String fillRule = 'evenodd',
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) {
    buffer.write('<rect ');
    writeId(id: id, name: name);
    if (x != null) {
      buffer.write('x="${formatSvgValue(x)}" ');
    }
    if (y != null) {
      buffer.write('y="${formatSvgValue(y)}" ');
    }
    buffer.write('width="${formatSvgValue(width)}" ');
    buffer.write('height="${formatSvgValue(height)}" ');
    if (rx != null) {
      buffer.write('rx="${formatSvgValue(rx)}" ');
    }
    if (ry != null) {
      buffer.write('ry="${formatSvgValue(ry)}" ');
    }
    writeStyle(
      fillRule: fillRule,
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write(' />');
  }

  /// [writeSvgPath]
  void writeUiPath(
    UiPath? path, {
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    Matrix4? transform,
    String? id,
    String? name,
    //--
    @dp double? pathStep,
    @mm double? tolerance,
    //--
    Map<String, dynamic>? attributes,
  }) {
    if (path != null) {
      writeSvgPath(
        path.toSvgPathString(
          pathStep: pathStep,
          tolerance: tolerance,
          digits: digits,
        ),
        fillRule: path.fillType == PathFillType.evenOdd ? 'evenodd' : 'nonzero',
        fill: fill,
        fillColor: fillColor,
        stroke: stroke,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        transform: transform,
        id: id,
        name: name,
        attributes: attributes,
      );
    }
  }

  /// [writeSvgPath]
  /// [writeUiPath]
  /// [writeUiPathAsync]
  Future writeUiPathAsync(
    UiPath? path, {
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    Matrix4? transform,
    String? id,
    String? name,
    //--
    @dp double? pathStep,
    @mm double? tolerance,
    //--
    int? contourInterval /*轮廓枚举延迟*/,
    int? stepInterval /*步长枚举延迟*/,
    //--
    dynamic debugLabel,
    //--
    Map<String, dynamic>? attributes,
  }) async {
    if (path != null) {
      final svgPath = await path.toSvgPathStringAsync(
        pathStep: pathStep,
        tolerance: tolerance,
        contourInterval: contourInterval,
        stepInterval: stepInterval,
        digits: digits,
      );
      writeSvgPath(
        svgPath,
        fillRule: path.fillType == PathFillType.evenOdd ? 'evenodd' : 'nonzero',
        fill: fill,
        fillColor: fillColor,
        stroke: stroke,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        transform: transform,
        id: id,
        name: name,
        attributes: attributes,
      );
    }
  }

  /// 写入[path]元素
  ///
  /// path 元素是用来定义形状的通用元素。所有的基本形状都可以用 path 元素来创建。
  ///
  /// - fill-rule https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/fill-rule
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/path
  void writeSvgPath(
    String? svgPath, {
    String fillRule = 'evenodd',
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    Matrix4? transform,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) {
    if (isNil(svgPath)) {
      return;
    }
    buffer.write('<path d="$svgPath" ');
    writeId(id: id, name: name);
    writeStyle(
      fillRule: fillRule,
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write('/>');
  }

  /// 写入[image]图片元素
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/image
  ///
  /// 所有坐标系, 默认都是以[viewBox]为参考
  ///
  /// ## 属性
  /// - x：图像水平方向上到原点的距离。
  /// - y：图像竖直方向上到原点的距离。
  /// - width：图像宽度。和 HTML <img> 不同，该属性是必需的。
  /// - height：图像高度。和 HTML <img> 不同，该属性是必需的。
  /// - href 和 xlink:href已弃用：指向图像文件的 URL。
  /// - preserveAspectRatio：控制图像的缩放比例。
  /// - crossorigin：定义 CORS 请求的凭据标志。
  /// - decoding：向浏览器提供关于是否应该同步或异步执行图像解码的提示。
  ///
  /// ```
  /// """
  /// <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  /// <image width="$w" height="$h" xlink:href="data:image/png;base64,$encoded_img"/>
  /// </svg>
  /// """
  /// ```
  /// [scaleImageFactor] 图片放大倍数, 1.0: 不放大; 10: 放大10倍;
  /// 在使用[scaleImageFactor]属性时, [image]必须要是[transform]后的图片, 否则具有缩放属性,宽高会对不上
  ///
  /// [invertScaleImageMatrix] 是否反转缩放图片的矩阵, 通常在正常情况下都是需要的, 但是雕刻图片数据时, 并不需要反向缩放
  /// 默认[scaleImageFactor]有值时, 就会反转
  /// 在生成雕刻数据时, 建议不反转, 因为雕刻数据在转成GCode时, 算法会处理
  ///
  Future writeImage(
    UiImage? image, {
    Matrix4? transform,
    String? id,
    String? name,
    double? scaleImageFactor,
    bool? invertScaleImageMatrix,
    //--
    dynamic x,
    dynamic y,
    dynamic width,
    dynamic height,
    //--
    Map<String, dynamic>? attributes,
  }) async {
    if (image != null) {
      if (scaleImageFactor != null && scaleImageFactor != 1) {
        //debugger();
        //需要缩放图片
        final scaleMatrix = createScaleMatrix(
          sx: scaleImageFactor,
          sy: scaleImageFactor,
        );
        image = await image.scale(scaleMatrix: scaleMatrix);

        //矩阵反向缩放
        invertScaleImageMatrix ??= true;
        if (invertScaleImageMatrix == true) {
          final scaleInvertMatrix = createScaleMatrix(
            sx: 1 / scaleImageFactor,
            sy: 1 / scaleImageFactor,
          );
          transform ??= Matrix4.identity();
          transform = transform * scaleInvertMatrix;
        }
      }
      final base64 = await image.toBase64();
      writeBase64Image(
        base64,
        transform: transform,
        id: id,
        name: name,
        //--
        x: x,
        y: y,
        width: width,
        height: height,
        //--
        attributes: attributes,
      );
    }
  }

  /// [writeImage]
  /// [x].[y].[width].[height] 支持mm单位, 所以需要字符串. 可以不指定.
  /// [x].[y] 不指定时, 则使用[transform]中的`tx/ty`值
  /// [transform] 会影响[x].[y].[width].[height]的数值
  ///
  /// > SVG 2 之前的规范定义了xlink:href属性，现在该属性已被href属性废弃。如果您需要支持早期的浏览器版本，
  /// > 除了href属性之外，还可以使用已弃用的xlink:href属性作为后备，例如 <use href="some-id" xlink:href="some-id" x="5" y="5" /> 。
  /// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/href
  void writeBase64Image(
    String? base64Image, {
    dynamic x,
    dynamic y,
    dynamic width,
    dynamic height,
    //--
    Matrix4? transform,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) async {
    if (!isNil(base64Image)) {
      //SVG 2 之前的规范定义了xlink:href属性，现在该属性已被href属性废弃。如果您需要支持早期的浏览器版本，除了href属性之外，
      // 还可以使用已弃用的xlink:href属性作为后备，例如 <use href="some-id" xlink:href="some-id" x="5" y="5" /> 。
      /*buffer.write(
          '<image width="$width" height="$height" xlink:href="$base64Image" ');*/
      buffer.write('<image ');
      writeId(id: id, name: name);
      //--
      if (x != null) {
        buffer.write('x="${formatSvgValue(x)}" ');
      }
      if (y != null) {
        buffer.write('y="${formatSvgValue(y)}" ');
      }
      //--
      if (width != null) {
        buffer.write('width="${formatSvgValue(width)}" ');
      }
      if (height != null) {
        buffer.write('height="${formatSvgValue(height)}" ');
      }
      writeTransform(transform: transform);
      writeAttributes(attributes);
      buffer.write('href="$base64Image" />');
    }
  }

  /// 写入[text]元素, 0,0 位置是相对于文本左下角基线开始
  ///
  /// text元素定义了一个由文字组成的图形。注意：我们可以将渐变、图案、剪切路径、遮罩或者滤镜应用到 text 上。
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/text
  ///
  void writeText({
    String? text,
    void Function(SvgBuilder subBuilder)? textSpanAction,
    dynamic x,
    dynamic y,
    dynamic fontSize,
    Color? color,
    String? fontFamily,
    Matrix4? transform,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) {
    if (isNil(text) && textSpanAction == null) {
      return;
    }
    buffer.write('<text ');
    writeId(id: id, name: name);
    if (x != null) {
      buffer.write('x="${formatSvgValue(x)}" ');
    }
    if (y != null) {
      buffer.write('y="${formatSvgValue(y)}" ');
    }
    if (fontSize != null) {
      buffer.write('font-size="${formatSvgValue(fontSize)}" ');
    }
    if (color != null) {
      buffer.write('fill="${color.toHex(includeAlpha: false)}" ');
    }
    if (fontFamily != null) {
      buffer.write('font-family="$fontFamily" ');
    }
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write('>');
    if (text != null) {
      buffer.write(text);
    }
    if (textSpanAction != null) {
      final subBuilder = SvgBuilder();
      subBuilder.digits = digits;
      textSpanAction(subBuilder);
      buffer.write(subBuilder.build());
    }
    buffer.write('</text>');
  }

  /// 写入[tspan]元素
  ///
  /// 在 <text>元素中，利用内含的tspan元素，可以调整文本和字体的属性以及当前文本的位置、绝对或相对坐标值。
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/tspan
  void writeTSpan(
    String? text, {
    dynamic x,
    dynamic y,
    dynamic dx,
    dynamic dy,
    dynamic fontSize,
    Color? color,
    String? fontFamily,
    Matrix4? transform,
    String? id,
    String? name,
    //--
    Map<String, dynamic>? attributes,
  }) {
    if (!isNil(text)) {
      buffer.write('<tspan ');
      writeId(id: id, name: name);
      if (x != null) {
        buffer.write('x="${formatSvgValue(x)}" ');
      }
      if (y != null) {
        buffer.write('y="${formatSvgValue(y)}" ');
      }
      if (dx != null) {
        buffer.write('dx="${formatSvgValue(dx)}" ');
      }
      if (dy != null) {
        buffer.write('dy="${formatSvgValue(dy)}" ');
      }
      if (fontSize != null) {
        buffer.write('font-size="${formatSvgValue(fontSize)}" ');
      }
      if (color != null) {
        buffer.write('fill="${color.toHex(includeAlpha: false)}" ');
      }
      if (fontFamily != null) {
        buffer.write('font-family="$fontFamily" ');
      }
      writeTransform(transform: transform);
      writeAttributes(attributes);
      buffer.write('>');
      buffer.write(text);
      buffer.write('</tspan>');
    }
  }

  /// 写入[group]元素
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/g
  ///
  void writeGroupSync(
    void Function(SvgBuilder subBuilder) action, {
    //--
    String? fillRule,
    bool fill = false,
    Color? fillColor,
    bool stroke = true,
    Color? strokeColor,
    @dp double? strokeWidth,
    //--
    String? id,
    String? name,
    //--
    Matrix4? transform,
    //--
    Map<String, dynamic>? attributes,
  }) {
    buffer.write('<g ');
    writeId(id: id, name: name);
    writeStyle(
      fillRule: fillRule,
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write('>');
    final subBuilder = SvgBuilder();
    subBuilder.digits = digits;
    action(subBuilder);
    buffer.write(subBuilder.build());
    buffer.write(r'</g>');
  }

  Future writeGroup(
    FutureOr Function(SvgBuilder subBuilder) action, {
    //--
    String? fillRule,
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
    //--
    String? id,
    String? name,
    //--
    Matrix4? transform,
    //--
    Map<String, dynamic>? attributes,
  }) async {
    buffer.write('<g ');
    writeId(id: id, name: name);
    writeStyle(
      fillRule: fillRule,
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    writeAttributes(attributes);
    buffer.write('>');
    final subBuilder = SvgBuilder();
    subBuilder.digits = digits;
    await action(subBuilder);
    buffer.write(subBuilder.build());
    buffer.write(r'</g>');
  }

  //endregion --元素--

  //region --属性--

  /// 写入[id].[name]属性
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/id
  void writeId({String? id, String? name}) {
    if (!isNil(id)) {
      buffer.write('id="$id" ');
    }
    if (!isNil(name)) {
      buffer.write('name="$name" ');
    }
  }

  /// 写入样式属性
  void writeStyle({
    String? fillRule = 'evenodd',
    bool? fill,
    Color? fillColor,
    bool? stroke,
    Color? strokeColor,
    @dp double? strokeWidth,
  }) {
    //--
    if (fill == true) {
      buffer.write(
        'fill="${(fillColor ?? Colors.black).toHex(includeAlpha: false)}" ',
      );

      if (fillRule != null) {
        buffer.write('fill-rule="$fillRule" ');
      }
    } else if (fill == false) {
      buffer.write('fill="none" ');
    }
    //--
    if (stroke == true) {
      buffer.write(
        'stroke="${(strokeColor ?? Colors.black).toHex(includeAlpha: false)}" ',
      );
      if (strokeWidth != null) {
        buffer.write('stroke-width="$strokeWidth" ');
      }
    } else {
      buffer.write('stroke-width="0" ');
    }
  }

  /// 写入[transform]属性
  ///
  /// ```
  /// <svg
  ///   viewBox="-40 0 150 100"
  ///   xmlns="http://www.w3.org/2000/svg"
  ///   xmlns:xlink="http://www.w3.org/1999/xlink">
  ///   <g
  ///     fill="grey"
  ///     transform="rotate(-10 50 100)
  ///                translate(-36 45.5)
  ///                skewX(40)
  ///                scale(1 0.5)">
  ///     <path
  ///       id="heart"
  ///       d="M 10,30 A 20,20 0,0,1 50,30 A 20,20 0,0,1 90,30 Q 90,60 50,90 Q 10,60 10,30 z" />
  ///   </g>
  ///
  ///   <use href="#heart" fill="none" stroke="red" />
  /// </svg>
  /// ```
  ///
  /// ```
  /// <svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  ///   <rect x="10" y="10" width="30" height="20" fill="green" />
  ///
  ///   <!--
  ///   在下面的示例中，我们应用矩阵：
  ///   [a c e]    [3 -1 30]
  ///   [b d f] => [1  3 40]
  ///   [0 0 1]    [0  0  1]
  ///
  ///   矩形变换如下：
  ///
  ///   左上角：oldX=10 oldY=10
  ///   newX = a * oldX + c * oldY + e = 3 * 10 - 1 * 10 + 30 = 50
  ///   newY = b * oldX + d * oldY + f = 1 * 10 + 3 * 10 + 40 = 80
  ///
  ///   右上角：oldX=40 oldY=10
  ///   newX = a * oldX + c * oldY + e = 3 * 40 - 1 * 10 + 30 = 140
  ///   newY = b * oldX + d * oldY + f = 1 * 40 + 3 * 10 + 40 = 110
  ///
  ///   左下角：oldX=10 oldY=30
  ///   newX = a * oldX + c * oldY + e = 3 * 10 - 1 * 30 + 30 = 30
  ///   newY = b * oldX + d * oldY + f = 1 * 10 + 3 * 30 + 40 = 140
  ///
  ///   右下角：oldX=40 oldY=30
  ///   newX = a * oldX + c * oldY + e = 3 * 40 - 1 * 30 + 30 = 120
  ///   newY = b * oldX + d * oldY + f = 1 * 40 + 3 * 30 + 40 = 170
  ///   -->
  ///   <rect
  ///     x="10"
  ///     y="10"
  ///     width="30"
  ///     height="20"
  ///     fill="red"
  ///     transform="matrix(3 1 -1 3 30 40)" />
  /// </svg>
  /// ```
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/transform
  ///
  /// # css matrix()
  ///
  /// CSS 函数 matrix() 指定了一个由指定的 6 个值组成的 2D 变换矩阵。这种矩阵的常量值是隐含的，而不是由参数传递的；其他的参数是以列优先的顺序描述的。
  ///
  /// matrix(a, b, c, d, tx, ty) 是 matrix3d(a, b, 0, 0, c, d, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1) 的简写。
  ///
  /// matrix( scaleX(), skewY(), skewX(), scaleY(), translateX(), translateY() )
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/CSS/transform-function/matrix
  ///
  void writeTransform({
    //--
    Matrix4? transform,
    //--
    double? tx, //距离
    double? ty,
    double? sx, //倍数
    double? sy,
    double? kx, //弧度
    double? ky,
  }) {
    if (transform == null &&
        tx == null &&
        ty == null &&
        sx == null &&
        sy == null &&
        kx == null &&
        ky == null) {
      return;
    }

    buffer.write('transform="');
    //buffer.write(transform.toMatrixString());
    tx ??= transform?.translateX ?? 0;
    ty ??= transform?.translateY ?? 0;
    sx ??= transform?.scaleX ?? 1;
    sy ??= transform?.scaleY ?? 1;
    kx ??= transform?.skewX ?? 0;
    ky ??= transform?.skewY ?? 0;
    buffer.write(
      "matrix(${formatSvgValue(sx)} ${formatSvgValue(ky)} ${formatSvgValue(kx)} ${formatSvgValue(sy)} ${formatSvgValue(tx)} ${formatSvgValue(ty)})",
    );
    buffer.write('" ');
  }

  /// 写入自定义的属性
  void writeAttributes(Map<String, dynamic>? attributes) {
    attributes?.forEach((key, value) {
      if (key.contains("=")) {
        buffer.write('$key ');
      } else if (value != null) {
        buffer.write('$key="$value" ');
      }
    });
  }

  //endregion --属性--

  /// 格式化数字
  String? formatSvgValue(dynamic value) => formatValue(value, digits: digits);

  @output
  String build() {
    writeEnd();
    return buffer.toString();
  }
}

@dsl
String svgBuilderSync(void Function(SvgBuilder builder) action) {
  final builder = SvgBuilder();
  action(builder);
  return builder.build();
}

@dsl
Future<String> svgBuilder(FutureOr Function(SvgBuilder builder) action) async {
  final builder = SvgBuilder();
  await action(builder);
  return builder.build();
}
