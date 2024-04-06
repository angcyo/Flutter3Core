part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/06
///
/// 字节写入器
/// [ByteData]
class BytesWriter {
  final List<int> _bytes = [];

  /// 写入一个字节
  void writeByte(int value) {
    _bytes.add(value & 0xff);
  }

  /// 写入一个32位的整数, 4个字节
  /// [length] 需要写入的字节长度, 默认4个字节
  /// [endian] 字节序, 默认大端序, 低位在前, 高位在后
  void writeInt(int value, [int length = 4, Endian endian = Endian.big]) {
    if (endian == Endian.big) {
      for (int i = 0; i < length; i++) {
        _bytes.add((value >> ((length - i - 1) * 8)) & 0xff);
      }
    } else {
      for (int i = 0; i < length; i++) {
        _bytes.add((value >> (i * 8)) & 0xff);
      }
    }
    /*if (endian == Endian.big) {
      _bytes.add((value >> 24) & 0xff);
      _bytes.add((value >> 16) & 0xff);
      _bytes.add((value >> 8) & 0xff);
      _bytes.add(value & 0xff);
    } else {
      _bytes.add(value & 0xff);
      _bytes.add((value >> 8) & 0xff);
      _bytes.add((value >> 16) & 0xff);
      _bytes.add((value >> 24) & 0xff);
    }*/
  }

  /// 写入一个64位的整数, 8个字节
  void writeLong(int value, [int length = 8, Endian endian = Endian.big]) {
    if (endian == Endian.big) {
      for (int i = 0; i < length; i++) {
        _bytes.add((value >> ((length - i - 1) * 8)) & 0xff);
      }
    } else {
      for (int i = 0; i < length; i++) {
        _bytes.add((value >> (i * 8)) & 0xff);
      }
    }
    /*if (endian == Endian.big) {
      _bytes.add((value >> 56) & 0xff);
      _bytes.add((value >> 48) & 0xff);
      _bytes.add((value >> 40) & 0xff);
      _bytes.add((value >> 32) & 0xff);
      _bytes.add((value >> 24) & 0xff);
      _bytes.add((value >> 16) & 0xff);
      _bytes.add((value >> 8) & 0xff);
      _bytes.add(value & 0xff);
    } else {
      _bytes.add(value & 0xff);
      _bytes.add((value >> 8) & 0xff);
      _bytes.add((value >> 16) & 0xff);
      _bytes.add((value >> 24) & 0xff);
      _bytes.add((value >> 32) & 0xff);
      _bytes.add((value >> 40) & 0xff);
      _bytes.add((value >> 48) & 0xff);
      _bytes.add((value >> 56) & 0xff);
    }*/
  }

  /// 写入一个其它字节数组
  /// [length] 需要写入的字节长度, 默认为[bytes]的长度
  void writeBytes(List<int> bytes, [int? length]) {
    if (length == null) {
      _bytes.addAll(bytes);
    } else {
      _bytes.addAll(bytes.sublist(0, length));
    }
  }

  /// 写入一个字符串
  void writeString(String value, [int? length]) {
    writeBytes(utf8.encode(value), length);
  }

  /// 写入一个Hex字符串
  void writeHex(String value, [int? length]) {
    writeBytes(value.toHexBytes(), length);
  }

  /// 填充到指定长度, 比如将字节数据填充到64个字节
  /// [length]需要填充到的字节长度
  void fill(int length, [int fillValue = 0]) {
    while (_bytes.length < length) {
      writeByte(fillValue);
    }
  }

  @output
  List<int> toBytes() {
    return _bytes;
  }
}

/// 字节读取器
class ByteReader {
  final List<int> bytes;

  ByteReader(this.bytes);

  int _index = 0;

  /// 读取一个字节
  int readByte() {
    return bytes[_index++];
  }

  /// 读取一个32位的整数, 4个字节
  int readInt([Endian endian = Endian.big]) {
    if (endian == Endian.big) {
      return (bytes[_index++] << 24) |
          (bytes[_index++] << 16) |
          (bytes[_index++] << 8) |
          bytes[_index++];
    } else {
      return bytes[_index++] |
          (bytes[_index++] << 8) |
          (bytes[_index++] << 16) |
          (bytes[_index++] << 24);
    }
  }

  /// 读取一个64位的整数, 8个字节
  int readLong([Endian endian = Endian.big]) {
    if (endian == Endian.big) {
      return (bytes[_index++] << 56) |
          (bytes[_index++] << 48) |
          (bytes[_index++] << 40) |
          (bytes[_index++] << 32) |
          (bytes[_index++] << 24) |
          (bytes[_index++] << 16) |
          (bytes[_index++] << 8) |
          bytes[_index++];
    } else {
      return bytes[_index++] |
          (bytes[_index++] << 8) |
          (bytes[_index++] << 16) |
          (bytes[_index++] << 24) |
          (bytes[_index++] << 32) |
          (bytes[_index++] << 40) |
          (bytes[_index++] << 48) |
          (bytes[_index++] << 56);
    }
  }

  /// 读取一个其它字节数组
  List<int> readBytes(int length) {
    final result = bytes.sublist(_index, _index + length);
    _index += length;
    return result;
  }

  /// 读取一个字符串
  String readString(int length) {
    final result = utf8.decode(bytes.sublist(_index, _index + length));
    _index += length;
    return result;
  }

  /// 读取一个Hex字符串
  String readHex(int length) {
    final result = bytes.sublist(_index, _index + length).toHex();
    _index += length;
    return result;
  }

  /// 读取剩余的字节
  List<int> readRemaining() {
    final result = bytes.sublist(_index);
    _index = bytes.length;
    return result;
  }

  /// 跳过指定的字节数
  void skip(int length) {
    _index += length;
  }
}

/// [BytesWriter]
@dsl
List<int> bytesWriter(void Function(BytesWriter writer) action) {
  final writer = BytesWriter();
  action(writer);
  return writer.toBytes();
}

/// [ByteReader]
@dsl
void bytesReader(List<int> bytes, void Function(ByteReader writer) action) {
  final reader = ByteReader(bytes);
  action(reader);
}
