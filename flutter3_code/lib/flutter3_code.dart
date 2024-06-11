library flutter3_code;

import 'package:barcode_image/barcode_image.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:image/image.dart' as img;

export 'package:barcode/barcode.dart';
export 'package:image/image.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/11
///
/// ## Supported barcodes
///
/// The following barcode images are SVG. The proper rendering, especially text, depends on the browser implementation and availability of the fonts.
///
/// ### 1D Barcodes
///
/// #### Code 39
///
/// <img width="250" alt="CODE 39" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-39.svg?sanitize=true">
///
/// #### Code 93
///
/// <img width="200" alt="CODE 93" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-93.svg?sanitize=true">
///
/// #### Code 128 A
///
/// <img width="300" alt="CODE 128 A" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-128a.svg?sanitize=true">
///
/// #### Code 128 B
///
/// <img width="300" alt="CODE 128 B" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-128b.svg?sanitize=true">
///
/// #### Code 128 C
///
/// <img width="300" alt="CODE 128 C" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-128c.svg?sanitize=true">
///
/// #### GS1-128
///
/// <img width="300" alt="GS1 128" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/gs1-128.svg?sanitize=true">
///
/// #### Interleaved 2 of 5 (ITF)
///
/// <img width="300" alt="ITF" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/itf.svg?sanitize=true">
///
/// #### ITF-14
///
/// <img width="300" alt="ITF 14" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/itf-14.svg?sanitize=true">
///
/// #### ITF-16
///
/// <img width="300" alt="ITF 14" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/itf-16.svg?sanitize=true">
///
/// #### EAN 13
///
/// <img width="200" alt="EAN 13" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-13.svg?sanitize=true">
///
/// #### EAN 8
///
/// <img height="100" alt="EAN 8" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-8.svg?sanitize=true">
///
/// #### EAN 2
///
/// <img height="100" alt="EAN 2" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-2.svg?sanitize=true">
///
/// #### EAN 5
///
/// <img height="100" alt="EAN 5" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-5.svg?sanitize=true">
///
/// #### ISBN
///
/// <img width="200" alt="ISBN" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/isbn.svg?sanitize=true">
///
/// #### UPC-A
///
/// <img width="200" alt="UPC A" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/upc-a.svg?sanitize=true">
///
/// #### UPC-E
///
/// <img height="100" alt="UPC E" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/upc-e.svg?sanitize=true">
///
/// #### Telepen
///
/// <img width="200" alt="Telepen" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/telepen.svg?sanitize=true">
///
/// #### Codabar
///
/// <img width="200" alt="Codabar" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/codabar.svg?sanitize=true">
///
/// ### Height Modulated Barcodes
///
/// #### RM4SCC
///
/// <img width="200" alt="RM4SCC" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/rm4scc.svg?sanitize=true">
///
/// ### 2D Barcodes
///
/// #### QR-Code
///
/// <img width="200" alt="QR-Code" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/qr-code.svg?sanitize=true">
///
/// #### PDF417
///
/// <img width="300" alt="PDF417" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/pdf417.svg?sanitize=true">
///
/// #### Data Matrix
///
/// <img width="200" alt="Data Matrix" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/data-matrix.svg?sanitize=true">
///
/// #### Aztec
///
/// <img width="200" alt="Aztec" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/aztec.svg?sanitize=true">
///
///
/// 二维码/条形码 图片生成
/// https://pub.dev/packages/barcode
/// https://pub.dev/packages/barcode#supported-barcodes
extension CodeStringEx on String {
  /// 将条码内容转换成图片对象
  /// [bgColor] 背景颜色, 默认透明
  /// [fgColor] 前景颜色, 默认黑色
  Future<UiImage> toCodeImage(
    int width,
    int height,
    Barcode barcode, {
    UiColor? bgColor,
    UiColor? fgColor,
  }) async {
    final image = img.Image(width: width, height: height, numChannels: 4);
    img.fill(
      image,
      color: img.ColorRgba8(
        bgColor?.red ?? 0,
        bgColor?.green ?? 0,
        bgColor?.blue ?? 0,
        bgColor?.alpha ?? 0,
      ),
    );
    drawBarcode(image, barcode, this, color: fgColor?.value ?? 0xff000000);
    final bytes = img.encodePng(image);
    return bytes.toImage();
  }
}
