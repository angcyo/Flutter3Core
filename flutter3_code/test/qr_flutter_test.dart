import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/11
///
void main() {
  testWidgets('QrPainter generates correct image', (tester) async {
    final painter = QrPainter(
      data: 'The painter is this thing',
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      /*eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: Colors.redAccent,
      ),*/
    );
    ByteData? imageData;
    await tester.runAsync(() async {
      imageData = await painter.toImageData(600.0);

      final imageData100 = await painter.toImageData(100.0);
      final imageData200 = await painter.toImageData(200.0);
      final imageData300 = await painter.toImageData(300.0);
      final imageData1000 = await painter.toImageData(1000.0);
      outputFile('qr_100.png').writeAsBytes(imageData100!.buffer.asUint8List());
      outputFile('qr_200.png').writeAsBytes(imageData200!.buffer.asUint8List());
      outputFile('qr_300.png').writeAsBytes(imageData300!.buffer.asUint8List());
      outputFile('qr_1000.png')
          .writeAsBytes(imageData1000!.buffer.asUint8List());
    });
    /*final imageBytes = imageData!.buffer.asUint8List();
    final Widget widget = Center(
      child: RepaintBoundary(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Image.memory(imageBytes),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('./.golden/qr_painter_golden.png'),
    );*/
  });
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  ensureParentDirectory(path);
  return File(path);
}

Directory ensureParentDirectory(String path) {
  String parentPath = FileSystemEntity.parentOf(path);
  final dir = Directory(parentPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}
