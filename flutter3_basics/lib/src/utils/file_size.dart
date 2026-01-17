part of '../../flutter3_basics.dart';

/// 2023-11-18
/// https://pub.dev/packages/filesize
/// https://github.com/synw/filesize

extension FileSizeEx on num {
  /// 字节大小转换为人类可读的字符串
  /// filesize(1024);                   // "1 KB"
  /// filesize(664365320);              // "633.59 MB"
  /// filesize(4324324232343);          // "3.93 TB"
  /// [fileSize]
  String toSizeStr({int round = 2, String space = "", int divider = 1024}) {
    return fileSize(ceil(), round: round, space: space, divider: divider);
  }
}

/// A method returns a human readable string representing a file _size
///
/// [size] can be passed as number or as string
///
/// the optional parameter [round] specifies the number
/// of digits after comma/point (default is 2)
///
String fileSize(
  dynamic size, {
  int round = 2,
  String space = "",
  int divider = 1024,
}) {
  int s;
  try {
    s = int.parse(size.toString());
  } catch (e) {
    throw ArgumentError('Can not parse the size parameter: $e');
  }

  if (s < divider) {
    return '$s${space}B';
  }

  if (s < divider * divider && s % divider == 0) {
    return '${(s / divider).toStringAsFixed(0)}${space}KB';
  }

  if (s < divider * divider) {
    return '${(s / divider).toStringAsFixed(round)}${space}KB';
  }

  if (s < divider * divider * divider && s % divider == 0) {
    return '${(s / (divider * divider)).toStringAsFixed(0)}${space}MB';
  }

  if (s < divider * divider * divider) {
    return '${(s / divider / divider).toStringAsFixed(round)}${space}MB';
  }

  if (s < divider * divider * divider * divider && s % divider == 0) {
    return '${(s / (divider * divider * divider)).toStringAsFixed(0)}${space}GB';
  }

  if (s < divider * divider * divider * divider) {
    return '${(s / divider / divider / divider).toStringAsFixed(round)}${space}GB';
  }

  if (s < divider * divider * divider * divider * divider && s % divider == 0) {
    num r = s / divider / divider / divider / divider;
    return '${r.toStringAsFixed(0)}${space}TB';
  }

  if (s < divider * divider * divider * divider * divider) {
    num r = s / divider / divider / divider / divider;
    return '${r.toStringAsFixed(round)}${space}TB';
  }

  if (s < divider * divider * divider * divider * divider * divider &&
      s % divider == 0) {
    num r = s / divider / divider / divider / divider / divider;
    return '${r.toStringAsFixed(0)}${space}PB';
  } else {
    num r = s / divider / divider / divider / divider / divider;
    return '${r.toStringAsFixed(round)}${space}PB';
  }
}
