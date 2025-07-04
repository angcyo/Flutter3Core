import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/17
///
void main() {
  //[85, 221]
  print("55DD".toHexBytes());

  print(bytesWriter((writer) {
    writer.writeFillHex(length: 100);
  }).utf8Str);

  print("Y".ascii);
  print("D".ascii);

  print("YDMG".bytes.toHex());
  print("YDMG".asciiBytes.toHex());

  print(15.toHex());
  print(255.toHex());

  print("[255]大端序:${bytesWriter((writer) {
    writer.writeInt(255, 4, Endian.big);
  }).toHex()}");

  print("[255]小端序:${bytesWriter((writer) {
    writer.writeInt(255, 4, Endian.little);
  }).toHex()}");

  print("[10000]大端序:${bytesWriter((writer) {
    writer.writeInt(10000, 4, Endian.big);
  }).toHex()}");

  print("[10000]小端序:${bytesWriter((writer) {
    writer.writeInt(10000, 4, Endian.little);
  }).toHex()}");

  print("MD5:${bytesWriter((writer) {
    writer.writeInt(1, 1);
  }).md5().toUpperCase()}");

  print("MD5:${"angcyo".md5().toUpperCase()}");

  //--

  final double = 1.0; // 0.99
  final b1 = Float32List.fromList([double]).buffer.asUint8List();
  final b2 = Float64List.fromList([double]).buffer.asUint8List();

  final bd1 = ByteData(4);
  final bd2 = ByteData(8);
  bd1.setFloat32(0, double);
  bd2.setFloat64(0, double);
  final b3 = bd1.bytes;
  final b4 = bd2.bytes;

  final bd3 = ByteData(4);
  final bd4 = ByteData(8);
  bd3.setFloat32(0, double, Endian.little);
  bd4.setFloat64(0, double, Endian.little);
  final b5 = bd3.bytes; // == b1
  final b6 = bd4.bytes; // == b2

  //ByteData.sublistView(uint8List);
  //ByteData.getFloat32(0, Endian.little); // 使用小端序

  debugger();
}
