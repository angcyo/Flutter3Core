part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/28
///
/// 加密算法
extension CryptoStringEx on String {
  ///HMAC-SHA256
  Digest hmacSHA256Digest(String key) {
    final hmacSha256 = Hmac(sha256, utf8.encode(key)); // HMAC-SHA256
    return hmacSha256.convert(utf8.encode(this));
  }

  /// 计算 HMAC-SHA256 加密后的字符串, 十六进制字符串
  String hmacSHA256(String key) => hmacSHA256Digest(key).toString();

  /// 计算 HMAC-SHA256
  List<int> hmacSHA256Bytes(String key) => hmacSHA256Digest(key).bytes;
}
