import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/24
///
/// totp
/// Time-based one-time password
/// 基于时间的一次性密码
/// https://pypi.org/help/#totp
///
/// https://pub.dev/packages/otp
/// https://pub.dev/packages/uuid
/// https://pub.dev/packages/base32
///
/// 绑定二维码内容:
/// otpauth://totp/Twitter:@angcyo?secret=xxx&issuer=Twitter
/// otpauth://totp/Discord:angcyo@126.com?secret=xxx&issuer=Discord
///
void main() async {
  //CXJAJQXJDHWFE6AOGOTJOKKYN6CZW2HW
  //QZMAHO43DMZCSF7ECKARWEW2TYUZFBCY
  // 示例密钥（Base32 编码）
  String secretKey = 'QZMAHO43DMZCSF7ECKARWEW2TYUZFBCY';

  // 创建 TOTP 实例
  TOTP totp = TOTP(secret: secretKey);

  // 生成 TOTP
  String otp = await totp.generateTOTP();

  print('Generated TOTP: $otp'); // 输出生成的 TOTP
  test("description", () {
    return true;
  });
}

class TOTP {
  final int timeStep; // 每个 TOTP 的有效时间（单位：秒）
  final int codeLength; // 生成的 TOTP 长度
  final String secret; // 共享密钥（Base32 编码）

  TOTP({
    this.timeStep = 30,
    this.codeLength = 6,
    required this.secret,
  });

  /// 生成 TOTP
  Future<String> generateTOTP() async {
    // 获取当前时间戳
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeCounter = (timestamp ~/ timeStep);

    // 将密钥从 Base32 转换为字节
    final Uint8List secretBytes = _decodeBase32(secret);

    // 生成 HMAC-SHA1
    final hmac = Hmac.sha1();
    final timeBytes = _intToBytes(timeCounter);
    final hmacResult = await hmac.calculateMac(Uint8List.fromList(timeBytes),
        secretKey: SecretKeyData(secretBytes));

    // 使用动态截断算法
    final offset = hmacResult.bytes.last & 0x0F;
    final binary = (hmacResult.bytes[offset] & 0x7F) << 24 |
        (hmacResult.bytes[offset + 1] & 0xFF) << 16 |
        (hmacResult.bytes[offset + 2] & 0xFF) << 8 |
        (hmacResult.bytes[offset + 3] & 0xFF);

    // 生成 TOTP
    final otp = binary % pow(10, codeLength).toInt();
    return otp.toString().padLeft(codeLength, '0');
  }

  /// 验证 TOTP
  Future<bool> verifyTOTP(String otp) async {
    final generatedOtp = await generateTOTP();
    return generatedOtp == otp;
  }

  Uint8List _intToBytes(int value) {
    final bytes = ByteData(8);
    bytes.setInt64(0, value, Endian.big);
    return bytes.buffer.asUint8List();
  }

  Uint8List _decodeBase32(String input) {
    final base32Chars = r'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    return Uint8List.fromList(List<int>.generate(input.length, (index) {
      final char = input[index];
      if (char == '=' || char == '\n' || char == '\r')
        return -1; // Padding or control characters
      return base32Chars.indexOf(char);
    }).where((byte) => byte != -1).map((byte) {
      // Base32解码
      final byteValue = byte;
      int value = 0;
      for (int i = 0; i < 5; i++) {
        if ((byteValue & (1 << (4 - i))) != 0) {
          value |= (1 << (7 - (i % 8)));
        }
        if (i % 8 == 7) {
          return value;
        }
      }
      return 0; // Placeholder
    }).toList());
  }
}
