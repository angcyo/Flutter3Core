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

  /// [writeSvgPath]
  void writeUiPath(
    UiPath? path, {
    bool fill = false,
    Color fillColor = Colors.black,
    bool stroke = true,
    Color strokeColor = Colors.black,
    @dp double strokeWidth = 1,
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
  }) {
    if (isNil(svgPath)) {
      return;
    }
    buffer.write('<path d="$svgPath" ');
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
  }) async {
    if (image != null) {
      writeBase64Image(
        await image.toBase64(),
        image.width,
        image.height,
        x: x,
        y: y,
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
      buffer.write('>');
      buffer.write(text);
      buffer.write('</text>');
    }
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
