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

  /// 限制写入的最大字节长度
  final int? limitMaxLength;

  /// 字节序, 默认大端序, 低位在前, 高位在后
  /// 小端序, 低位在前, 高位在后
  final Endian endian;

  BytesWriter({this.limitMaxLength, this.endian = Endian.big});

  /// 是否可以继续写入
  bool _canWrite() => limitMaxLength == null || _bytes.length < limitMaxLength!;

  /// 写入一个字节
  void writeByte(int value) {
    if (_canWrite()) {
      _bytes.add(value);
    }
  }

  /// 写入一个无符号字节
  void writeUByte(int value) {
    if (_canWrite()) {
      _bytes.add(value & 0xff);
    }
  }

  /// 写入一个32位的整数, 4个字节
  /// [length] 需要写入的字节长度, 默认4个字节
  /// [endian] 字节序, 默认大端序, 低位在前, 高位在后
  void writeInt(int value, [int length = 4, Endian? endian]) {
    endian ??= this.endian;
    if (endian == Endian.big) {
      //大端序, 默认
      for (int i = 0; i < length; i++) {
        if (!_canWrite()) {
          break;
        }
        _bytes.add((value >> ((length - i - 1) * 8)) & 0xff);
      }
    } else {
      //小端序
      for (int i = 0; i < length; i++) {
        if (!_canWrite()) {
          break;
        }
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

  /// 写入一个32位的整数, 4个字节, 小端序
  /// 低字节在高位
  void writeIntLittle(int value, [int length = 4]) {
    writeInt(value, length, Endian.little);
  }

  /// 写入一个64位的整数, 8个字节
  void writeLong(int value, [int length = 8, Endian? endian]) {
    endian ??= this.endian;
    if (endian == Endian.big) {
      for (int i = 0; i < length; i++) {
        if (!_canWrite()) {
          break;
        }
        _bytes.add((value >> ((length - i - 1) * 8)) & 0xff);
      }
    } else {
      for (int i = 0; i < length; i++) {
        if (!_canWrite()) {
          break;
        }
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

  /// 写入一个32位的整数, 4个字节, 小端序
  /// 低字节在高位
  void writeLongLittle(int value, [int length = 8]) {
    writeLong(value, length, Endian.little);
  }

  /// 在指定位置写入一个其它字节数组
  /// [writeBytes]
  /// [insertBytes]
  void insertBytes(int index, List<int>? bytes, [int? length]) {
    if (bytes == null || bytes.isEmpty) {
      return;
    }
    if (!_canWrite()) {
      return;
    }
    if (length == null) {
      _bytes.insertAll(index, bytes);
    } else {
      _bytes.insertAll(index, bytes.sublist(0, math.min(length, bytes.size())));
    }
  }

  /// 写入一个其它字节数组
  /// [length] 需要写入的字节长度, 默认为[bytes]的长度
  ///
  /// [writeFill]
  /// [writeBytes]
  /// [insertBytes]
  ///
  void writeBytes(List<int>? bytes, [int? length]) {
    if (bytes == null || bytes.isEmpty) {
      return;
    }
    if (!_canWrite()) {
      return;
    }
    if (length == null) {
      _bytes.addAll(bytes);
    } else {
      _bytes.addAll(bytes.sublist(0, math.min(length, bytes.size())));
    }
  }

  /// 写入一个文本
  /// [writeText]
  /// [writeString]
  void writeText(String? value, [int? length]) {
    if (value == null || value.isEmpty) {
      return;
    }
    writeBytes(utf8.encode(value), length);
  }

  /// 写入一个ASCII文本
  void writeAsciiText(String? value, [int? length]) {
    if (value == null || value.isEmpty) {
      return;
    }
    writeBytes(value.asciiBytes, length);
  }

  /// 写入一个字符串
  /// [writeText]
  /// [writeString]
  void writeString(String? value, [int? length, bool writeEnd = true]) {
    if (value == null || value.isEmpty) {
      return;
    }
    writeBytes(utf8.encode(value), length);
    if (writeEnd) {
      writeByte(0x00); //字符串结束符
    }
  }

  /// 写入一个Hex字符串
  void writeHex(String? value, [int? length]) {
    writeBytes(value?.toHexBytes(), length);
  }

  /// 写入指定字节的长度数据
  void writeFill(int length, [int fillValue = 0]) {
    for (int i = 0; i < length; i++) {
      writeByte(fillValue);
    }
  }

  /// 按照 [00000000][00000001]...[0000000F][FFFFFFFF] 的格式填充字节
  /// 写入填充到指定数字的字节数据
  void writeFillHex({
    int? number,
    int? length,
    bool writeEnd = true,
  }) {
    final builder = StringBuffer();
    for (int i = 0; i <= (number ?? intMax32Value); i++) {
      builder.write("[${i.toHex().padLeft(8, '0')}]");
      if (length != null) {
        if (builder.toString().bytes.length > length) {
          break;
        }
      }
    }
    writeString(builder.toString(), length, writeEnd);
  }

  /// 填充到多少个字节长度, 不包含当前[length], 比如将字节数据填充到64个字节
  /// [length]需要填充到的字节长度
  void fillTo(int length, [int fillValue = 0]) {
    while (_bytes.length < length) {
      writeByte(fillValue);
    }
  }

  /// 返回写入的字节数据
  @output
  List<int> toBytes() {
    if (limitMaxLength != null) {
      if (_bytes.length > limitMaxLength!) {
        return _bytes.sublist(0, limitMaxLength!);
      }
    }
    return _bytes;
  }
}

/// 字节读取器
class ByteReader {
  final List<int> bytes;

  int get sumLength => bytes.length - excludeLength;

  /// 排除多少个字节
  int excludeLength = 0;

  /// 字节序, 默认大端序, 低位在前, 高位在后
  /// 小端序, 低位在前, 高位在后
  Endian endian;

  ByteReader(this.bytes, {this.excludeLength = 0, this.endian = Endian.big});

  int _index = 0;

  /// 是否读取完毕
  bool get isDone => _index >= sumLength;

  /// 读取一个字节
  int readByte([int overflow = -1]) {
    if (isDone) {
      return overflow;
    }
    return bytes[_index++];
  }

  /// 读取有符号的一个字节, 这个方法支持返回负数
  /// [width] 宽度, 默认8位
  int readByteSigned([int width = 8, int overflow = -1]) {
    if (isDone) {
      return overflow;
    }
    return bytes[_index++].toSigned(width);
  }

  /// 读取一个32位的整数, 4个字节
  /// [length] 需要读取的字节长度
  int readInt([int length = 4, int overflow = -1, Endian? endian]) {
    if (isDone) {
      return overflow;
    }
    endian ??= this.endian;
    return readBytes(length)?.toInt(length, endian) ?? overflow;
  }

  /// 读取一个64位的整数, 8个字节
  int readLong([int overflow = -1, Endian? endian]) {
    if (isDone) {
      return overflow;
    }
    endian ??= this.endian;
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
  /// [length] 需要读取的字节长度
  List<int>? readBytes(int length, [List<int>? overflow]) {
    if (isDone) {
      return overflow;
    }
    final result = bytes.sublist(_index, math.min(_index + length, sumLength));
    _index += length;
    return result;
  }

  /// 读取指定字节长度的一个字符串
  /// [length] 需要读取的字节长度
  String? readString(int length, [String? overflow]) {
    if (isDone) {
      return overflow;
    }
    final result = utf8.decode(
        bytes.sublist(_index, math.min(_index + length, sumLength)),
        allowMalformed: true);
    _index += length;
    return result;
  }

  /// 读取字符串, 直到遇到结束符0x00
  String? readStringEnd([String? overflow, Encoding codec = utf8]) {
    if (isDone) {
      return overflow;
    }
    while (!isDone) {
      final bytes = readLoop((bytes, byte) {
        return byte.uint == 0;
      });
      if (bytes.isEmpty) {
        break;
      }
      return bytes.toStr(codec);
    }
    return overflow;
  }

  /// 循环读取连续的字符串
  /// [maxSize] 需要读取的最大字节数
  List<String> readStringList([int? maxSize, Encoding codec = utf8]) {
    final result = <String>[];
    var count = 0;
    while (!isDone) {
      final bytes = readLoop((bytes, byte) {
        return byte.uint == 0;
      });
      if (bytes.isEmpty) {
        break;
      }
      result.add(bytes.toStr(codec));
      count += bytes.size();
      if (maxSize != null && count >= maxSize) {
        //超出范围
        break;
      }
    }
    return result;
  }

  /// 循环读取, 直到满足条件时退出
  /// [predicate] 返回true, 停止读取
  List<int> readLoop(bool Function(List<int> bytes, int byte) predicate) {
    final result = <int>[];
    while (!isDone) {
      final byte = readByte();
      result.add(byte);
      if (predicate(result, byte)) {
        break;
      }
    }
    return result;
  }

  /// 读取几个字节[length]并转换成Hex字符串
  /// [overflow] 超范围时返回
  String? readHex([int length = 1, String? overflow]) {
    if (isDone) {
      return overflow;
    }
    final result =
        bytes.sublist(_index, math.min(_index + length, sumLength)).toHex();
    _index += length;
    return result;
  }

  /// 读取剩余的字节数组
  List<int> readRemaining() {
    if (isDone) {
      return [];
    }
    final end = sumLength;
    final result = bytes.sublist(_index, end);
    _index = end;
    return result;
  }

  /// 跳过指定的字节数
  void skip(int length) {
    _index += length;
  }

  /// 读取指定长度位代表的字节数据长度的数据
  /// [readBytes]
  /// [readRemaining]
  void readLengthBytes(int length,
      [Endian? endian, BytesReaderFn? bytesAction]) {
    //读取后续字节的长度
    final byteCount = readInt(length, 0, endian);
    final bytes = readBytes(byteCount);
    if (bytes != null && bytesAction != null) {
      bytesReader(bytes, bytesAction);
    }
  }
}

/// 字节写入
typedef BytesWriterFn = void Function(BytesWriter writer);

/// 字节读取
typedef BytesReaderFn<T> = T Function(ByteReader reader);

/// [BytesWriter]
@dsl
List<int> bytesWriter(BytesWriterFn action) {
  final writer = BytesWriter();
  action(writer);
  return writer.toBytes();
}

/// [ByteReader]
@dsl
T bytesReader<T>(List<int> bytes, BytesReaderFn<T> action) {
  final reader = ByteReader(bytes);
  return action(reader);
}
