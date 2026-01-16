part of '../../flutter3_code.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/16
///

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
/// [BarcodeType]
/// https://pub.dev/packages/barcode
/// https://pub.dev/packages/barcode#supported-barcodes
extension CodeStringEx on String {
  /// 将字符串转换成[Barcode]
  Barcode? toBarcode({
    BarcodeQRCorrectionLevel errorCorrectLevel = BarcodeQRCorrectionLevel.high,
    Pdf417SecurityLevel securityLevel = Pdf417SecurityLevel.level2,
    int minECCPercent = 35,
  }) {
    final lowerCase = toLowerCase();
    if (lowerCase == BarcodeType.QrCode.name.toLowerCase() ||
        lowerCase == "QR_CODE".toLowerCase()) {
      return Barcode.qrCode(errorCorrectLevel: errorCorrectLevel);
    }
    if (lowerCase == BarcodeType.PDF417.name.toLowerCase() ||
        lowerCase == "PDF_417".toLowerCase()) {
      return Barcode.pdf417(securityLevel: securityLevel);
    }
    if (lowerCase == BarcodeType.DataMatrix.name.toLowerCase() ||
        lowerCase == "DATA_MATRIX".toLowerCase()) {
      return Barcode.dataMatrix();
    }
    if (lowerCase == BarcodeType.Aztec.name.toLowerCase() ||
        lowerCase == "AZTEC".toLowerCase()) {
      return Barcode.aztec(minECCPercent: minECCPercent);
    }
    //--
    if (lowerCase == BarcodeType.Code39.name.toLowerCase() ||
        lowerCase == "CODE_39".toLowerCase()) {
      return Barcode.code39();
    }
    if (lowerCase == BarcodeType.Code93.name.toLowerCase() ||
        lowerCase == "CODE_93".toLowerCase()) {
      return Barcode.code93();
    }
    if (lowerCase == BarcodeType.Code128.name.toLowerCase() ||
        lowerCase == "CODE_128".toLowerCase()) {
      return Barcode.code128();
    }
    //--
    if (lowerCase == BarcodeType.GS128.name.toLowerCase() ||
        lowerCase == "GS1_128".toLowerCase()) {
      return Barcode.gs128();
    }
    if (lowerCase == BarcodeType.CodeISBN.name.toLowerCase() ||
        lowerCase == "ISBN".toLowerCase()) {
      return Barcode.isbn();
    }
    if (lowerCase == BarcodeType.Telepen.name.toLowerCase() ||
        lowerCase == "Telepen".toLowerCase()) {
      return Barcode.telepen();
    }
    if (lowerCase == BarcodeType.Codabar.name.toLowerCase() ||
        lowerCase == "Codabar".toLowerCase()) {
      return Barcode.codabar();
    }
    if (lowerCase == BarcodeType.Rm4scc.name.toLowerCase() ||
        lowerCase == "Rm4scc".toLowerCase()) {
      return Barcode.rm4scc();
    }
    //--
    if (lowerCase == BarcodeType.CodeEAN2.name.toLowerCase() ||
        lowerCase == "EAN_2".toLowerCase()) {
      return Barcode.ean2();
    }
    if (lowerCase == BarcodeType.CodeEAN5.name.toLowerCase() ||
        lowerCase == "EAN_5".toLowerCase()) {
      return Barcode.ean5();
    }
    if (lowerCase == BarcodeType.CodeEAN8.name.toLowerCase() ||
        lowerCase == "EAN_8".toLowerCase()) {
      return Barcode.ean8();
    }
    if (lowerCase == BarcodeType.CodeEAN13.name.toLowerCase() ||
        lowerCase == "EAN_13".toLowerCase()) {
      return Barcode.ean13();
    }
    //--
    if (lowerCase == BarcodeType.Itf.name.toLowerCase() ||
        lowerCase == "Itf".toLowerCase()) {
      return Barcode.itf();
    }
    if (lowerCase == BarcodeType.CodeITF14.name.toLowerCase() ||
        lowerCase == "CodeITF14".toLowerCase()) {
      return Barcode.itf14();
    }
    if (lowerCase == BarcodeType.CodeITF16.name.toLowerCase() ||
        lowerCase == "CodeITF16".toLowerCase()) {
      return Barcode.itf16();
    }
    //--
    if (lowerCase == BarcodeType.CodeUPCA.name.toLowerCase() ||
        lowerCase == "UPC_A".toLowerCase()) {
      return Barcode.upcA();
    }
    if (lowerCase == BarcodeType.CodeUPCE.name.toLowerCase() ||
        lowerCase == "UPC_E".toLowerCase()) {
      return Barcode.upcE();
    }
    return null;
  }

  /// 当前的字符串是否支持指定的条形码类型
  bool isSupportBarcodeType(String? barcodeType) {
    final barcode = barcodeType?.toBarcode();
    try {
      barcode!.verify(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 字符串转换成二维码
  Future<UiImage?> toQrCodeImage({
    int size = 200,
    Barcode? barcode,
    UiColor? bgColor,
    UiColor? fgColor,
  }) => toCodeImage(
    size,
    size,
    Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
    bgColor: bgColor,
    fgColor: fgColor,
  );

  //bool is2DCode

  /// 将条码内容转换成图片对象
  /// [bgColor] 背景颜色, 默认透明
  /// [fgColor] 前景颜色, 默认黑色
  /// [Barcode.qrCode]
  Future<UiImage?> toCodeImage(
    int width,
    int height,
    Barcode? barcode, {
    UiColor? bgColor,
    UiColor? fgColor,
  }) async {
    if (barcode == null) {
      return null;
    }
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

/// 过滤条码能够输入的内容
/// [def] 验证失败时的默认文本
TextInputFormatter codeTextInputFormatter(Barcode code, [String? def]) {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    try {
      //debugger();
      code.verify(newValue.text);
      return newValue;
    } catch (e) {
      assert(() {
        printError(e, StackTrace.current);
        return true;
      }());
      return def != null ? TextEditingValue(text: def) : oldValue;
    }
  });
}

extension BarcodeEx on Barcode {
  /// 1D Barcodes
  bool get is1DBarcodes => !is2DBarcodes;

  /// 2D Barcodes
  bool get is2DBarcodes =>
      name == 'Data Matrix' ||
      name == 'PDF417' ||
      name == 'QR-Code' ||
      name == 'Aztec';
}

extension BarcodeIntEx on int {
  /// [BarcodeQRCorrectionLevel]
  BarcodeQRCorrectionLevel get errorCorrectLevel =>
      BarcodeQRCorrectionLevel.values.getOrNull(this) ??
      BarcodeQRCorrectionLevel.high;

  /// [Pdf417SecurityLevel]
  Pdf417SecurityLevel get securityLevel =>
      Pdf417SecurityLevel.values.getOrNull(this) ?? Pdf417SecurityLevel.level2;
}
