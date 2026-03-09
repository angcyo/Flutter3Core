///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/09
///
class Base62 {
  static const String _chars =
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

  /// 1. 整型数转换成 Base62 字符串
  static String encode(dynamic input) {
    BigInt value;
    if (input is int) {
      value = BigInt.from(input);
    } else if (input is BigInt) {
      value = input;
    } else {
      throw ArgumentError("Input must be int or BigInt");
    }

    if (value == BigInt.zero) return _chars[0];

    String res = "";
    final BigInt base = BigInt.from(62);

    while (value > BigInt.zero) {
      int remainder = (value % base).toInt();
      res = _chars[remainder] + res; // 插入到头部
      value ~/= base;
    }
    return res;
  }

  /// 2. Base62 字符串反转回整型数
  static BigInt decode(String base62) {
    BigInt result = BigInt.zero;
    final BigInt base = BigInt.from(62);

    for (int i = 0; i < base62.length; i++) {
      int digit = _chars.indexOf(base62[i]);
      if (digit == -1)
        throw FormatException("Invalid Base62 character: ${base62[i]}");

      // 多项式累加: result = result * 62 + digit
      result = (result * base) + BigInt.from(digit);
    }
    return result;
  }
}

void main() {
  // 示例 1: 普通整型
  int myNum = 20260309;
  String encoded = Base62.encode(myNum);
  BigInt decoded = Base62.decode(encoded);

  print("原始数据: $myNum");
  print("Base62: $encoded"); // 输出类似: 1BtD9
  print("反转回整型: $decoded");

  // 示例 2: 超大整型 (BigInt)
  BigInt bigNum = BigInt.parse("9223372036854775807"); // Long.MAX_VALUE
  print("\n大数 Base62: ${Base62.encode(bigNum)}");
}
