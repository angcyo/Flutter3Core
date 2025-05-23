///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/06
///
/// https://github.com/stevenroose/dart-hex
///
library hex;

import "dart:convert";
import "dart:typed_data";

import "package:flutter3_basics/flutter3_basics.dart";

const String _ALPHABET = "0123456789abcdef";

/// An instance of the default implementation of the [HexCodec].
const _HEX = HexCodec();

/// A codec for encoding and decoding byte arrays to and from
/// hexadecimal strings.
class HexCodec extends Codec<List<int>, String> {
  const HexCodec();

  @override
  Converter<List<int>, String> get encoder => const HexEncoder();

  @override
  Converter<String, List<int>> get decoder => const HexDecoder();
}

/// A converter to encode byte arrays into hexadecimal strings.
class HexEncoder extends Converter<List<int>, String> {
  /// If true, the encoder will encode into uppercase hexadecimal strings.
  final bool upperCase;

  const HexEncoder({this.upperCase = true});

  @override
  String convert(List<int> input) {
    StringBuffer buffer = StringBuffer();
    for (int part in input) {
      if (part & 0xff != part) {
        throw const FormatException("Non-byte integer detected");
      }
      buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    if (upperCase) {
      return buffer.toString().toUpperCase();
    } else {
      return buffer.toString();
    }
  }
}

/// A converter to decode hexadecimal strings into byte arrays.
class HexDecoder extends Converter<String, List<int>> {
  const HexDecoder();

  @override
  List<int> convert(String input) {
    String str = input.replaceAll(" ", "");
    str = str.toLowerCase();
    if (str.length % 2 != 0) {
      str = "0$str";
    }
    Uint8List result = Uint8List(str.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      int firstDigit = _ALPHABET.indexOf(str[i * 2]);
      int secondDigit = _ALPHABET.indexOf(str[i * 2 + 1]);
      if (firstDigit == -1 || secondDigit == -1) {
        throw FormatException("Non-hex character detected in $input");
      }
      result[i] = (firstDigit << 4) + secondDigit;
    }
    return result;
  }
}

//---

extension HexStringEx on String {
  /// 将16禁止字符串转换为整数
  int toHexInt({int radix = 16}) => toIntOrNull(radix: radix) ?? 0;

  /// Convert a hexadecimal string to a byte array.
  /// 将十六进制字符串转换为字节数组数据。
  List<int> toHexBytes() => _HEX.decoder.convert(this);

  /// Convert a hexadecimal string to a byte buffer.
  /// 将十六进制字符串转换为字节缓冲区。
  Uint8List toHexBuffer() => Uint8List.fromList(toHexBytes());

  /// 每个2个字符添加一个空格
  String fillHexSpace() {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(this[i]);
      if (i % 2 == 1 && i != length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }
}

extension HexIntEx on int {
  /// Convert a integer to a byte array.
  /// 将整数转换为字节数组。
  /// [length] 要输出多少个字节的数据 AA:1个字节 AABB:2个字节
  Uint8List toBytes([int? length]) {
    if (this == 0) {
      return Uint8List(1);
    }
    length ??= (bitLength / 8).ceil();
    final buffer = Uint8List(length);
    for (int i = 0; i < length; i++) {
      buffer[i] = (this >> ((length - i - 1) * 8)) & 0xFF;
    }
    return buffer;
  }

  /// Convert a integer to a hexadecimal string.
  /// 将整数转换为十六进制字符串。
  /// 1->01
  /// 200->C8
  String toHex([int? length]) => _HEX.encoder.convert(toBytes(length));
}

extension HexBytesEx on List<int> {
  /// Convert a byte array to a hexadecimal string.
  /// 将字节数组转换为十六进制字符串。
  String toHex() => _HEX.encoder.convert(this);

  /// Convert a byte array to a byte buffer.
  /// 将字节数组转换为字节缓冲区。
  Uint8List toBuffer() => Uint8List.fromList(this);

  /// 计算字节数据的校验和
  /// [length] 需要输出几个字节长度的校验和
  int checkSum([int length = 4, Endian endian = Endian.big]) {
    final count = this.length;
    int sum = 0;
    for (int i = 0; i < count; i++) {
      sum += this[i];
    }
    return sum.toUint8List(length).toInt(length, endian);
  }

  /// 计算字节数据的CRC16查表校验和
  int crc16() {
    int crc = 0;
    for (int i = 0; i < length; i++) {
      crc = (crc >> 8) ^ _CRC16._table[(crc ^ this[i]) & 0xFF];
    }
    return crc;
  }
}

/// CRC16校验
/// https://www.jianshu.com/p/bcc20a7fd478
///
abstract final class _CRC16 {
  /// 表
  static const List<int> _table = [
    0x0000,
    0xC0C1,
    0xC181,
    0x0140,
    0xC301,
    0x03C0,
    0x0280,
    0xC241,
    0xC601,
    0x06C0,
    0x0780,
    0xC741,
    0x0500,
    0xC5C1,
    0xC481,
    0x0440,
    0xCC01,
    0x0CC0,
    0x0D80,
    0xCD41,
    0x0F00,
    0xCFC1,
    0xCE81,
    0x0E40,
    0x0A00,
    0xCAC1,
    0xCB81,
    0x0B40,
    0xC901,
    0x09C0,
    0x0880,
    0xC841,
    0xD801,
    0x18C0,
    0x1980,
    0xD941,
    0x1B00,
    0xDBC1,
    0xDA81,
    0x1A40,
    0x1E00,
    0xDEC1,
    0xDF81,
    0x1F40,
    0xDD01,
    0x1DC0,
    0x1C80,
    0xDC41,
    0x1400,
    0xD4C1,
    0xD581,
    0x1540,
    0xD701,
    0x17C0,
    0x1680,
    0xD641,
    0xD201,
    0x12C0,
    0x1380,
    0xD341,
    0x1100,
    0xD1C1,
    0xD081,
    0x1040,
    0xF001,
    0x30C0,
    0x3180,
    0xF141,
    0x3300,
    0xF3C1,
    0xF281,
    0x3240,
    0x3600,
    0xF6C1,
    0xF781,
    0x3740,
    0xF501,
    0x35C0,
    0x3480,
    0xF441,
    0x3C00,
    0xFCC1,
    0xFD81,
    0x3D40,
    0xFF01,
    0x3FC0,
    0x3E80,
    0xFE41,
    0xFA01,
    0x3AC0,
    0x3B80,
    0xFB41,
    0x3900,
    0xF9C1,
    0xF881,
    0x3840,
    0x2800,
    0xE8C1,
    0xE981,
    0x2940,
    0xEB01,
    0x2BC0,
    0x2A80,
    0xEA41,
    0xEE01,
    0x2EC0,
    0x2F80,
    0xEF41,
    0x2D00,
    0xEDC1,
    0xEC81,
    0x2C40,
    0xE401,
    0x24C0,
    0x2580,
    0xE541,
    0x2700,
    0xE7C1,
    0xE681,
    0x2640,
    0x2200,
    0xE2C1,
    0xE381,
    0x2340,
    0xE101,
    0x21C0,
    0x2080,
    0xE041,
    0xA001,
    0x60C0,
    0x6180,
    0xA141,
    0x6300,
    0xA3C1,
    0xA281,
    0x6240,
    0x6600,
    0xA6C1,
    0xA781,
    0x6740,
    0xA501,
    0x65C0,
    0x6480,
    0xA441,
    0x6C00,
    0xACC1,
    0xAD81,
    0x6D40,
    0xAF01,
    0x6FC0,
    0x6E80,
    0xAE41,
    0xAA01,
    0x6AC0,
    0x6B80,
    0xAB41,
    0x6900,
    0xA9C1,
    0xA881,
    0x6840,
    0x7800,
    0xB8C1,
    0xB981,
    0x7940,
    0xBB01,
    0x7BC0,
    0x7A80,
    0xBA41,
    0xBE01,
    0x7EC0,
    0x7F80,
    0xBF41,
    0x7D00,
    0xBDC1,
    0xBC81,
    0x7C40,
    0xB401,
    0x74C0,
    0x7580,
    0xB541,
    0x7700,
    0xB7C1,
    0xB681,
    0x7640,
    0x7200,
    0xB2C1,
    0xB381,
    0x7340,
    0xB101,
    0x71C0,
    0x7080,
    0xB041,
    0x5000,
    0x90C1,
    0x9181,
    0x5140,
    0x9301,
    0x53C0,
    0x5280,
    0x9241,
    0x9601,
    0x56C0,
    0x5780,
    0x9741,
    0x5500,
    0x95C1,
    0x9481,
    0x5440,
    0x9C01,
    0x5CC0,
    0x5D80,
    0x9D41,
    0x5F00,
    0x9FC1,
    0x9E81,
    0x5E40,
    0x5A00,
    0x9AC1,
    0x9B81,
    0x5B40,
    0x9901,
    0x59C0,
    0x5880,
    0x9841,
    0x8801,
    0x48C0,
    0x4980,
    0x8941,
    0x4B00,
    0x8BC1,
    0x8A81,
    0x4A40,
    0x4E00,
    0x8EC1,
    0x8F81,
    0x4F40,
    0x8D01,
    0x4DC0,
    0x4C80,
    0x8C41,
    0x4400,
    0x84C1,
    0x8581,
    0x4540,
    0x8701,
    0x47C0,
    0x4680,
    0x8641,
    0x8201,
    0x42C0,
    0x4380,
    0x8341,
    0x4100,
    0x81C1,
    0x8081,
    0x4040
  ];
}
