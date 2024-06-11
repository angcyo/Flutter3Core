import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/11
///
void main() {
  test('barcode test', () {
    _saveBarcode(
      "qrCode",
      "二维码angcyo中国人http://angcyo.github.io/",
      100,
      100,
      Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
    );
    _saveBarcode(
      "qrCode",
      "二维码angcyo中国人http://angcyo.github.io/",
      200,
      200,
      Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
    );
    _saveBarcode(
      "qrCode",
      "二维码angcyo中国人http://angcyo.github.io/",
      300,
      300,
      Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
    );
    _saveBarcode(
      "qrCode",
      "二维码angcyo中国人http://angcyo.github.io/",
      1000,
      1000,
      Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
    );

    //--

    _saveBarcode(
      "dataMatrix",
      "http://angcyo.github.io",
      100,
      100,
      Barcode.dataMatrix(),
    );

    _saveBarcode(
      "dataMatrix",
      "http://angcyo.github.io/",
      300,
      300,
      Barcode.dataMatrix(),
    );

    //---

    _saveBarcode(
      "code93",
      "HELLO WORLD",
      100,
      50,
      Barcode.code93(),
    );

    _saveBarcode(
      "code93",
      "HELLO WORLD",
      300,
      100,
      Barcode.code93(),
    );

    //---

    _saveBarcode(
      "code128",
      "http://angcyo.github.io",
      100,
      50,
      Barcode.code128(),
    );

    _saveBarcode(
      "code128",
      "http://angcyo.github.io/",
      300,
      100,
      Barcode.code128(),
    );

    //--

    // Create an image
    final image = Image(width: 300, height: 120);

    // Fill it with a solid color (white)
    fill(image, color: ColorRgb8(255, 255, 255));

    // Draw the barcode
    drawBarcode(image, Barcode.code128(), 'Test', font: arial24);

    // Save the image
    File('test/output/barcode.png').writeAsBytesSync(encodePng(image));
  });
}

void _saveBarcode(
  String namePrefix,
  String data,
  int width,
  int height,
  Barcode barcode,
) {
  // Create an image
  final image = Image(width: width, height: height, numChannels: 4);

  // Fill it with a solid color (white)
  //fill(image, color: ColorRgb8(255, 255, 255));
  fill(
    image,
    color: ColorRgba8(0, 0, 0, 0),
    maskChannel: Channel.luminance,
  );

  // Draw the barcode
  drawBarcode(
    image,
    barcode,
    data, /*font: arial24*/
  );

  // Save the image
  File('test/output/${namePrefix}_${width}_$height.png')
      .writeAsBytesSync(encodePng(image));
}
