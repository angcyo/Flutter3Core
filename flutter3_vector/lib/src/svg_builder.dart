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

  /// 写入[viewBox]属性
  ///
  /// viewBox 属性允许指定一个给定的一组图形伸展以适应特定的容器元素。
  ///
  /// viewBox 属性的值是一个包含 4 个参数的列表 min-x, min-y, width and height，以空格或者逗号分隔开，在用户空间中指定一个矩形区域映射到给定的元素，查看属性preserveAspectRatio。
  ///
  /// 不允许宽度和高度为负值，0 则禁用元素的呈现。
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/viewBox
  ///
  /// mac上 1mm->3.7777px
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
    writeTransform(transform: transform);
    buffer.write(' />');
  }

  /// [writeSvgPath]
  void writeUiPath(
    UiPath? path, {
    bool fill = false,
    Color fillColor = Colors.black,
    bool stroke = true,
    Color strokeColor = Colors.black,
    @dp double strokeWidth = 1,
    Matrix4? transform,
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
    bool fill = false,
    Color fillColor = Colors.black,
    bool stroke = true,
    Color strokeColor = Colors.black,
    @dp double strokeWidth = 1,
    Matrix4? transform,
  }) {
    if (isNil(svgPath)) {
      return;
    }
    buffer.write('<path d="$svgPath" ');
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
  Future writeImage(
    UiImage? image, {
    num? x,
    num? y,
    Matrix4? transform,
  }) async {
    if (image != null) {
      writeBase64Image(
        await image.toBase64(),
        image.width,
        image.height,
        x: x,
        y: y,
        transform: transform,
      );
    }
  }

  /// [writeImage]
  void writeBase64Image(
    String? base64Image,
    num width,
    num height, {
    num? x,
    num? y,
    Matrix4? transform,
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
    num? x,
    num? y,
    num? fontSize,
    Color? color,
    String? fontFamily,
    Matrix4? transform,
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
      writeTransform(transform: transform);
      buffer.write('>');
      buffer.write(text);
      buffer.write('</text>');
    }
  }

  //--

  /// 写入样式属性
  void writeStyle({
    String fillRule = 'evenodd',
    bool fill = false,
    Color fillColor = Colors.black,
    bool stroke = true,
    Color strokeColor = Colors.black,
    @dp double strokeWidth = 1,
  }) {
    if (fill) {
      buffer.write('fill="${fillColor.toHex(a: false)}" ');
    } else {
      buffer.write('fill="none" ');
    }
    buffer.write('fill-rule="$fillRule" ');
    if (stroke) {
      buffer.write('stroke="${strokeColor.toHex(a: false)}" ');
      buffer.write('stroke-width="$strokeWidth" ');
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
    buffer.write("matrix($sx $kx $tx $ky $sy $ty 0 0 1)");
    buffer.write('" ');
  }

  //--

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
