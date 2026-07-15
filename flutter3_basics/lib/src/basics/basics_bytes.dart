part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/16
///
///
extension TransferableTypedDataEx on TransferableTypedData {
  /// - [ByteBuffer]
  Uint8List get bytes => materialize().asUint8List();
}
