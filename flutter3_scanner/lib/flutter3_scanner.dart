library flutter3_scanner;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
export 'package:image_picker/image_picker.dart';

part 'src/image_picker_ex.dart';
part 'src/single_code_scanner_page.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/11
///

typedef OnCodeScannerCallback = void Function(List<String> result);

/// 扫描文件路径
extension ScannerStringEx on String {
  /// 从图片路径中,分析二维码
  Future<List<String>?> codeAnalyzeImageByPath(
      {MobileScannerController? controller}) async {
    controller ??= MobileScannerController();
    final BarcodeCapture? barcodes = await controller.analyzeImage(this);
    return barcodes?.barcodes
        .map((e) => e.displayValue)
        .filterNull<String>()
        .toList();
  }
}
