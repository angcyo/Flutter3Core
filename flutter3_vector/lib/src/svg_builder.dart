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
  /// svg xml头部
  String svgHeader = '<?xml version="1.0" encoding="UTF-8"?>'
      '\n<!-- Created with LaserPecker Design Space (https://www.laserpecker.net/pages/software) -->\n';

  /// 数据输出
  @output
  StringBuffer buffer = StringBuffer();

  /// 浮点小数点位数
  int digits = 15;

  /// 写入[viewBox]属性
  ///
  /// viewBox 属性允许指定一个给定的一组图形伸展以适应特定的容器元素。
  ///
  /// viewBox 属性的值是一个包含 4 个参数的列表 min-x, min-y, width and height，以空格或者逗号分隔开，在用户空间中指定一个矩形区域映射到给定的元素，查看属性preserveAspectRatio。
  ///
  /// 不允许宽度和高度为负值，0 则禁用元素的呈现。
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/viewBox
  ///
  /// mac/windows上 1mm->3.7777px
  /// 1mm = 1/25.4 * 96 px ≈ 3.779527559 px
  ///
  void writeViewBox(@dp Rect bounds) {
    buffer.write(svgHeader);
    buffer.write('<svg xmlns="http://www.w3.org/2000/svg" ');
    buffer.write('xmlns:xlink="http://www.w3.org/1999/xlink" ');
    buffer.write('xmlns:acy="https://www.github.com/angcyo" ');
    buffer.write(
        'viewBox="${bounds.left} ${bounds.top} ${bounds.width} ${bounds.height}" ');
    buffer.write(
        'width="${bounds.width.toMmFromDp()}mm" height="${bounds.height.toMmFromDp()}mm" ');
    buffer.write('acy:author="angcyo" acy:version="1">');
  }

  /// 结束
  void writeEnd() {
    buffer.write(r'</svg>');
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
  }) {
    buffer.write('<line ');
    if (x1 != null) {
      buffer.write('x1="$x1" ');
    }
    if (y1 != null) {
      buffer.write('y1="$y1" ');
    }
    if (x2 != null) {
      buffer.write('x2="$x2" ');
    }
    if (y2 != null) {
      buffer.write('y2="$y2" ');
    }
    writeId(id: id, name: name);
    writeStyle(
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
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
  }) {
    buffer.write('<ellipse ');
    if (cx != null) {
      buffer.write('cx="$cx" ');
    }
    if (cy != null) {
      buffer.write('cy="$cy" ');
    }
    if (rx != null) {
      buffer.write('rx="$rx" ');
    }
    if (ry != null) {
      buffer.write('ry="$ry" ');
    }
    writeId(id: id, name: name);
    writeStyle(
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
  }

  /// 写入[rect]元素
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/rect
  ///
  void writeRect({
    double? x,
    double? y,
    required double width,
    required double height,
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
  }) {
    buffer.write('<rect ');
    if (x != null) {
      buffer.write('x="$x" ');
    }
    if (y != null) {
      buffer.write('y="$y" ');
    }
    buffer.write('width="$width" ');
    buffer.write('height="$height" ');
    if (rx != null) {
      buffer.write('rx="$rx" ');
    }
    if (ry != null) {
      buffer.write('ry="$ry" ');
    }
    writeId(id: id, name: name);
    writeStyle(
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
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
  }) {
    if (path != null) {
      writeSvgPath(
        path.toSvgPathString(),
        fillRule: path.fillType == PathFillType.evenOdd ? 'evenodd' : 'nonzero',
        fill: fill,
        fillColor: fillColor,
        stroke: stroke,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        transform: transform,
        id: id,
        name: name,
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
  }) {
    if (isNil(svgPath)) {
      return;
    }
    buffer.write('<path d="$svgPath" ');
    writeId(id: id, name: name);
    writeStyle(
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    writeTransform(transform: transform);
    buffer.write('/>');
  }

  /// 写入[image]图片元素
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/image
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
  ///
  Future writeImage(
    UiImage? image, {
    String? x,
    String? y,
    String? width,
    String? height,
    Matrix4? transform,
    String? id,
    String? name,
  }) async {
    if (image != null) {
      writeBase64Image(
        await image.toBase64(),
        width ?? formatNum(image.width) ?? "0",
        height ?? formatNum(image.height) ?? "0",
        x: x,
        y: y,
        transform: transform,
        id: id,
        name: name,
      );
    }
  }

  /// [writeImage]
  /// [x].[y].[width].[height] 支持mm单位, 所以需要字符串
  void writeBase64Image(
    String? base64Image,
    String width,
    String height, {
    String? x,
    String? y,
    Matrix4? transform,
    String? id,
    String? name,
  }) async {
    if (!isNil(base64Image)) {
      buffer.write(
          '<image width="$width" height="$height" xlink:href="$base64Image" ');
      if (x != null) {
        buffer.write('x="$x"');
      }
      if (y != null) {
        buffer.write('y="$y" ');
      }
      writeId(id: id, name: name);
      writeTransform(transform: transform);
      buffer.write('/>');
    }
  }

  /// 写入[text]元素, 0,0 位置是相对于文本左下角基线开始
  ///
  /// text元素定义了一个由文字组成的图形。注意：我们可以将渐变、图案、剪切路径、遮罩或者滤镜应用到 text 上。
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/text
  ///
  void writeText(
    String? text, {
    dynamic x,
    dynamic y,
    dynamic fontSize,
    Color? color,
    String? fontFamily,
    Matrix4? transform,
    String? id,
    String? name,
  }) {
    if (!isNil(text)) {
      buffer.write('<text ');
      if (x != null) {
        buffer.write('x="$x" ');
      }
      if (y != null) {
        buffer.write('y="$y" ');
      }
      if (fontSize != null) {
        buffer.write('font-size="$fontSize" ');
      }
      if (color != null) {
        buffer.write('fill="${color.toHex(a: false)}" ');
      }
      if (fontFamily != null) {
        buffer.write('font-family="$fontFamily" ');
      }
      writeId(id: id, name: name);
      writeTransform(transform: transform);
      buffer.write('>');
      buffer.write(text);
      buffer.write('</text>');
    }
  }

  /// 写入[group]元素
  ///
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Element/g
  ///
  void writeGroupSync(
    void Function(SvgBuilder subBuilder) action, {
    String? fillRule,
    bool fill = false,
    Color? fillColor,
    bool stroke = true,
    Color? strokeColor,
    @dp double? strokeWidth,
    String? id,
    String? name,
  }) {
    buffer.write('<g ');
    writeId(id: id, name: name);
    writeStyle(
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    final subBuilder = SvgBuilder();
    subBuilder.digits = digits;
    action(subBuilder);
    subBuilder.writeEnd();
    buffer.write(subBuilder.build());
    buffer.write('>');
  }

  Future writeGroup(
    FutureOr Function(SvgBuilder subBuilder) action, {
    String? fillRule,
    bool fill = false,
    Color? fillColor,
    bool stroke = true,
    Color? strokeColor,
    @dp double? strokeWidth,
    String? id,
    String? name,
  }) async {
    buffer.write('<g ');
    writeId(id: id, name: name);
    writeStyle(
      fill: fill,
      fillColor: fillColor,
      stroke: stroke,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    final subBuilder = SvgBuilder();
    subBuilder.digits = digits;
    await action(subBuilder);
    subBuilder.writeEnd();
    buffer.write(subBuilder.build());
    buffer.write('>');
  }

  //endregion --元素--

  //region --属性--

  /// 写入[id].[name]属性
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/id
  void writeId({
    String? id,
    String? name,
  }) {
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
    if (fill == true) {
      buffer.write('fill="${(fillColor ?? Colors.black).toHex(a: false)}" ');
    } else if (fill == false) {
      buffer.write('fill="none" ');
    }
    if (fillRule != null) {
      buffer.write('fill-rule="$fillRule" ');
    }
    if (stroke == true) {
      buffer
          .write('stroke="${(strokeColor ?? Colors.black).toHex(a: false)}" ');
      if (strokeWidth != null) {
        buffer.write('stroke-width="$strokeWidth" ');
      }
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
    Matrix4? transform,
    double? tx, //距离
    double? ty,
    double? sx, //倍数
    double? sy,
    double? kx, // 弧度
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
    tx ??= transform?.translateX;
    ty ??= transform?.translateY;
    sx ??= transform?.scaleX;
    sy ??= transform?.scaleY;
    kx ??= transform?.skewX;
    ky ??= transform?.skewY;
    buffer.write(
        "matrix(${formatNum(sx)} ${formatNum(ky)} ${formatNum(kx)} ${formatNum(sy)} ${formatNum(tx)} ${formatNum(ty)})");
    buffer.write('" ');
  }

  //endregion --属性--

  /// 格式化数字
  String? formatNum(num? num) => num?.toDigits(digits: digits);

  String build() => buffer.toString();
}

@dsl
String svgBuilderSync(void Function(SvgBuilder builder) action) {
  final builder = SvgBuilder();
  action(builder);
  builder.writeEnd();
  return builder.build();
}

@dsl
Future<String> svgBuilder(FutureOr Function(SvgBuilder builder) action) async {
  final builder = SvgBuilder();
  await action(builder);
  builder.writeEnd();
  return builder.build();
}
