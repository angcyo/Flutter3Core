part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/22
///
/// 通过头几个字节判断文件类型
extension FileTypeEx on Uint8List {
  /// 判断头几个字节是否是图片类型
  /// [path] 指定路径, 备用从扩展名中获取类型
  bool isImageType([String path = ""]) =>
      lookupMimeType(path, headerBytes: this)?.isImageType == true;
}
