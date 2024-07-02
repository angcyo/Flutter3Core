import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/02
///
/// 将一张图片进行放大镜处理
/// https://github.com/alnitak/magnifying_glass
void main() {
  test('test', () async {
    WidgetsFlutterBinding.ensureInitialized();

    final face = outputFile("face2.jpg");
    final faceImage = await face.toImage();
    final faceByteData = await faceImage.toByteData();

    PinchBarrel().storeImg(
      faceImage.width.toInt(),
      faceImage.height.toInt(),
      faceByteData!.buffer.asUint8List(),
    );

    const diameter = 150;
    PinchBarrel().setBmpHeaderSize(diameter, diameter);

    //final position = Offset(faceImage.width / 2, faceImage.height / 2);
    const position = Offset(diameter / 2, diameter / 2);
    final resultImageBytes = PinchBarrel()
        .getSubImage((position.dx.toInt() - (diameter / 2)).toInt(),
            (position.dy.toInt() - (diameter / 2)).toInt(), diameter)!
        .bmp
        .buffer
        .asUint8List();

    final faceOutput = outputFile("output_face.bmp");
    await faceOutput.writeAsBytes(resultImageBytes);

    consoleLog('...');
  });
}

/// Class to construct an uncompressed 32bit BMP image from raw data
class Bmp32Header {
  late int width;
  late int height;
  late Uint8List bmp;
  late int contentSize;
  int rgba32HeaderSize = 122;
  int bytesPerPixel = 4;

  /// set a BMP from bytes
  Bmp32Header.setBmp(Uint8List imgBytes) {
    final bd = imgBytes.buffer.asByteData();
    width = bd.getInt32(0x12, Endian.little);
    height = -bd.getInt32(0x16, Endian.little);
    contentSize = bd.getInt32(0x02, Endian.little) - rgba32HeaderSize;
    bmp = imgBytes;
  }

  /// set BMP header and memory to use
  Bmp32Header.setHeader(this.width, this.height) {
    contentSize = width * height;
    bmp = Uint8List(rgba32HeaderSize + contentSize * bytesPerPixel);

    bmp.buffer.asByteData()
      ..setUint8(0x00, 0x42) // 'B'
      ..setUint8(0x01, 0x4d) // 'M'

      ..setInt32(0x02, rgba32HeaderSize + contentSize, Endian.little)
      ..setInt32(0x0A, rgba32HeaderSize, Endian.little)
      ..setUint32(0x0E, 108, Endian.little)
      ..setUint32(0x12, width, Endian.little)
      ..setUint32(0x16, -height, Endian.little)
      ..setUint16(0x1A, 1, Endian.little)
      ..setUint8(0x1C, 32)
      ..setUint32(0x1E, 3, Endian.little)
      ..setUint32(0x22, contentSize, Endian.little)
      ..setUint32(0x36, 0x000000ff, Endian.little)
      ..setUint32(0x3A, 0x0000ff00, Endian.little)
      ..setUint32(0x3E, 0x00ff0000, Endian.little)
      ..setUint32(0x42, 0xff000000, Endian.little);
  }

  /// Insert the [bitmap] after the header and return the BMP
  Uint8List storeBitmap(Uint8List bitmap) {
    bmp.setRange(rgba32HeaderSize, bmp.length, bitmap);
    return bmp;
  }

  /// clear BMP pixels leaving the header untouched
  Uint8List clearBitmap() {
    bmp.fillRange(rgba32HeaderSize, bmp.length, 0);
    return bmp;
  }

  Color getPixel(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return Colors.transparent;
    int px = rgba32HeaderSize + ((y * width + x) << 2);
    Color ret = Color.fromARGB(
      bmp[px + 3],
      bmp[px],
      bmp[px + 1],
      bmp[px + 2],
    );
    return ret;
  }

  void setPixel(int x, int y, Color color) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    int px = rgba32HeaderSize + ((y * width + x) << 2);
    bmp[px] = color.red;
    bmp[px + 1] = color.green;
    bmp[px + 2] = color.blue;
    bmp[px + 3] = color.alpha;
  }

  /// set BMP pixels color
  Uint8List setBitmapBackgroundColor(int r, int g, int b, int a) {
    final value = ((r & 0xff) |
            ((g & 0xff) << 8) |
            ((b & 0xff) << 16) |
            ((a & 0xff) << 24)) &
        0xFFFFFFFF;
    final tmp = bmp.sublist(rgba32HeaderSize).buffer.asUint32List();
    tmp.fillRange(0, tmp.length, value);

    final bytes = BytesBuilder()
      ..add(bmp.sublist(0, rgba32HeaderSize))
      ..add(tmp.buffer.asUint8List());
    // ignore: join_return_with_assignment
    bmp = bytes.toBytes();

    return bmp;
  }
}

/// Class to manage lens effect with PinchBarrel
class PinchBarrel {
  static PinchBarrel? _instance;
  int imgWidth = 0;
  int imgHeight = 0;
  Int32List shiftingMatX = Int32List(0);
  Int32List shiftingMatY = Int32List(0);
  int subImgWidth = 0;
  int subImgHeight = 0;
  double distortionPower = 1.0;
  double magnification = 1.0;
  Bmp32Header? img;
  Bmp32Header? subImg;

  PinchBarrel._internal();

  factory PinchBarrel() {
    _instance ??= PinchBarrel._internal();
    return _instance!;
  }

  /// just set distortion and magnification parameters
  setParameters(double distortion, double mag) {
    distortionPower = distortion;
    magnification = mag;
  }

  /// set distortion and magnification parameters, and
  /// compute shifting matrices
  setShiftMat(double distortion, double mag) {
    if (subImgWidth == 0 || subImgHeight == 0) return;
    int center = subImgWidth >> 1; // and lens radius
    double distance;
    double newDistance;

    distortionPower = distortion;
    magnification = mag;
    distortion /= 10000.0;

    // initialize shifting x and y matrices
    shiftingMatX = Int32List(subImgWidth * subImgHeight);
    shiftingMatY = Int32List(subImgWidth * subImgHeight);

    int dx, dy;
    double angle;
    int pos;
    for (int y = 0; y < subImgHeight; y++) {
      for (int x = 0; x < subImgWidth; x++) {
        pos = y * subImgWidth + x;
        dx = center - x;
        dy = center - y;
        distance = sqrt(dx * dx + dy * dy);
        // calculate distortion only in the lens surface
        if (distance > center) {
          shiftingMatX[pos] = 0;
          shiftingMatY[pos] = 0;
          continue;
        }

        newDistance =
            distance * (1 - distortion * distance * distance) * magnification;
        angle = atan2(y - center, x - center);

        shiftingMatX[pos] = (dx + (cos(angle) * newDistance)).toInt();
        shiftingMatY[pos] = (dy + (sin(angle) * newDistance)).toInt();
      }
    }
  }

  /// this will store the header for a lens bmp image
  setBmpHeaderSize(int width, int height) {
    subImgWidth = width;
    subImgHeight = height;
    subImg = Bmp32Header.setHeader(width, height);
    setShiftMat(distortionPower, magnification);
  }

  // store background image
  void storeImg(int width, int height, Uint8List imgBuffer) {
    imgWidth = width;
    imgHeight = height;
    img = Bmp32Header.setHeader(width, height);
    img!.storeBitmap(imgBuffer);
  }

  Bmp32Header? getSubImage(int topLeftX, int topLeftY, int width) {
    if (img == null) return null;

    subImg!.clearBitmap();
    int toX =
        topLeftX + subImgWidth < imgWidth ? topLeftX + subImgWidth : imgWidth;
    int toY =
        topLeftY + subImgWidth < imgHeight ? topLeftY + subImgWidth : imgHeight;
    int subImgX;
    int subImgY;
    int imgX;
    int imgY;
    int pxSrc;
    int pxDest;
    for (int y = topLeftY; y < toY; y++) {
      for (int x = topLeftX; x < toX; x++) {
        subImgX = x - topLeftX;
        subImgY = y - topLeftY;
        imgX = x - shiftingMatX[subImgY * subImgWidth + subImgX];
        imgY = y - shiftingMatY[subImgY * subImgWidth + subImgX];
        pxSrc = 122 + ((imgY * imgWidth + imgX) << 2);
        pxDest = 122 + ((subImgY * subImgWidth + subImgX) << 2);
        if (pxSrc < 0 || pxSrc > img!.bmp.length - 4) continue;

        subImg!.bmp[pxDest] = img!.bmp[pxSrc];
        subImg!.bmp[pxDest + 1] = img!.bmp[pxSrc + 1];
        subImg!.bmp[pxDest + 2] = img!.bmp[pxSrc + 2];
        subImg!.bmp[pxDest + 3] = img!.bmp[pxSrc + 3];
      }
    }

    return subImg;
  }
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  path.ensureParentDirectory();
  consoleLog('path:$path');
  return File(path);
}
