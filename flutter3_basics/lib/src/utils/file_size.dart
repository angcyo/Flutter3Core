part of '../../flutter3_basics.dart';

/// 2023-11-18
/// https://pub.dev/packages/filesize
/// https://github.com/synw/filesize

extension FileSizeEx on num {
  /// 字节大小转换为人类可读的字符串
  /// filesize(1024);                   // "1 KB"
  /// filesize(664365320);              // "633.59 MB"
  /// filesize(4324324232343);          // "3.93 TB"
  /// [filesize]
  String toSizeStr([int round = 2, String space = ""]) {
    return filesize(this, round, space);
  }
}

/// A method returns a human readable string representing a file _size
String filesize(dynamic size, [int round = 2, String space = ""]) {
  /**
   * [size] can be passed as number or as string
   *
   * the optional parameter [round] specifies the number
   * of digits after comma/point (default is 2)
   */
  var divider = 1024;
  int _size;
  try {
    _size = int.parse(size.toString());
  } catch (e) {
    throw ArgumentError('Can not parse the size parameter: $e');
  }

  if (_size < divider) {
    return '$_size${space}B';
  }

  if (_size < divider * divider && _size % divider == 0) {
    return '${(_size / divider).toStringAsFixed(0)}${space}KB';
  }

  if (_size < divider * divider) {
    return '${(_size / divider).toStringAsFixed(round)}${space}KB';
  }

  if (_size < divider * divider * divider && _size % divider == 0) {
    return '${(_size / (divider * divider)).toStringAsFixed(0)}${space}MB';
  }

  if (_size < divider * divider * divider) {
    return '${(_size / divider / divider).toStringAsFixed(round)}${space}MB';
  }

  if (_size < divider * divider * divider * divider && _size % divider == 0) {
    return '${(_size / (divider * divider * divider)).toStringAsFixed(0)}${space}GB';
  }

  if (_size < divider * divider * divider * divider) {
    return '${(_size / divider / divider / divider).toStringAsFixed(round)}${space}GB';
  }

  if (_size < divider * divider * divider * divider * divider &&
      _size % divider == 0) {
    num r = _size / divider / divider / divider / divider;
    return '${r.toStringAsFixed(0)}${space}TB';
  }

  if (_size < divider * divider * divider * divider * divider) {
    num r = _size / divider / divider / divider / divider;
    return '${r.toStringAsFixed(round)}${space}TB';
  }

  if (_size < divider * divider * divider * divider * divider * divider &&
      _size % divider == 0) {
    num r = _size / divider / divider / divider / divider / divider;
    return '${r.toStringAsFixed(0)}${space}PB';
  } else {
    num r = _size / divider / divider / divider / divider / divider;
    return '${r.toStringAsFixed(round)}${space}PB';
  }
}
