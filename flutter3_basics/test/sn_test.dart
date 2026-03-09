import 'dart:math';

import 'package:characters/characters.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/09
///
class SNGenerator {
  // 自定义字符集 (排除容易混淆的 I, O, Z)
  static const String _charset = "0123456789ABCDEFGHJKLMNPQRSTUVWXY";

  /// 生成 SN: PID(2) + Year(1) + Month(1) + Batch(2) + Random(8) + Check(2)
  static String generate({required String pid, required String batch}) {
    String raw = pid.toUpperCase(); // 2位

    // 1. 时间处理 (Year 使用 36 进制, Month 1-C)
    DateTime now = DateTime.now();
    //print(String.fromCharCode(now.year.toRadixString(36).codeUnits.last).toUpperCase());
    raw += now.year.toRadixString(36).characters.last.toUpperCase();
    /*raw += String.fromCharCode(
      now.year.toRadixString(36).codeUnits.last,
    ).toUpperCase();*/
    raw += now.month.toRadixString(16).toUpperCase();

    // 2. 批次
    raw += batch.padLeft(2, '0');

    // 3. 随机位 (8位)
    final random = Random();
    for (int i = 0; i < 8; i++) {
      raw += _charset[random.nextInt(_charset.length)];
    }

    // 4. 计算并附加校验码 (2位)
    return raw + _calculateCheckSum(raw);
  }

  /// 基于 Mod 36 的校验和算法
  static String _calculateCheckSum(String input) {
    int sum = 0;
    for (int i = 0; i < input.length; i++) {
      int val = _charset.indexOf(input[i]);
      // 偶数位加权 (简单示例：翻倍)
      if (i % 2 == 0) {
        val *= 2;
        if (val >= _charset.length) val = (val % _charset.length) + 1;
      }
      sum += val;
    }

    int checkVal =
        (_charset.length - (sum % _charset.length)) % _charset.length;
    // 返回两位校验码（简单映射）
    return _charset[checkVal % _charset.length] +
        _charset[(sum % _charset.length)];
  }

  /// 验证 SN 是否合法
  static bool verify(String sn) {
    if (sn.length != 16) return false;
    String data = sn.substring(0, 14);
    String check = sn.substring(14);
    return _calculateCheckSum(data) == check;
  }
}

void main() {
  // 示例：生成一个空调(AC) 01号线的SN
  String mySN = SNGenerator.generate(pid: "AC", batch: "01");
  print("Generated SN: $mySN");
  // 输出示例: AC6301B5R4K7W9F1 (具体随随机数变化)

  print("Is Valid: ${SNGenerator.verify(mySN)}");
}
