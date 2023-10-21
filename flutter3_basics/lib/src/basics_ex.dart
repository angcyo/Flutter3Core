import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region 基础扩展

final random = Random();

int nowTime() => DateTime.now().millisecondsSinceEpoch;

/// [min] ~ [max] 之间的随机数
int nextInt(int max, {int min = 0}) => min + random.nextInt(max);

bool nextBool() => random.nextBool();

/// [0~1] 之间的随机数
double nextDouble() => random.nextDouble();

/// [print] 的简写
void p(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

//endregion 基础扩展

//region Color 扩展

extension ColorEx on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(buffer.toString().toInt(radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

//endregion Color 扩展

//region String 扩展

extension StringEx on String {
  /// 字符串转换成int
  toInt({int? radix}) => int.parse(this, radix: radix);

  /// 字符串转换成int
  toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// 字符转换成Color对象
  toColor() => ColorEx.fromHex(this);

  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  toDateTime() => DateTime.parse(this);
}

//endregion String 扩展

/// https://pub.dev/packages/date_format
/*extension DateTimeEx on DateTime {
  toFormatString() {
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(this);
  }
}*/

//region Asset 扩展

/// ```
/// await loadAssetString('assets/config.json');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-text-assets
Future<String> loadAssetString(String key) async {
  return await rootBundle.loadString(key);
}

/// ```
/// loadAssetImageWidget('assets/png/flutter.png');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-images-1
Image loadAssetImageWidget(String key) => Image.asset(key);

/// [ImageProvider]
/// [AssetBundleImageProvider]
/// [AssetImage]
/// [ExactAssetImage]
AssetImage loadAssetImage(String key) => AssetImage(key);

//endregion Asset 扩展
