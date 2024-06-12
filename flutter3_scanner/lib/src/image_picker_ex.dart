part of '../flutter3_scanner.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/11
///
/// 使用[ImagePicker]获取图片
/// [ImageSource.gallery] 相册
/// [ImageSource.camera] 拍照
Future<XFile?> pickerImage({
  bool useCamera = false,
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
}) async {
  final ImagePicker picker = ImagePicker();
  // Pick an image.
  final XFile? image = await picker.pickImage(
    source: useCamera ? ImageSource.camera : ImageSource.gallery,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    imageQuality: imageQuality,
  );
  return image;
}

/// Pick a video.
Future<XFile?> pickerVideo({
  bool useCamera = false,
  Duration? maxDuration,
}) async {
  final ImagePicker picker = ImagePicker();
  final XFile? video = await picker.pickVideo(
    source: useCamera ? ImageSource.camera : ImageSource.gallery,
    maxDuration: maxDuration,
  );
  return video;
}

/// 使用[ImagePicker]获取一个图片/视频
Future<XFile?> pickerMedia({
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
}) async {
  final ImagePicker picker = ImagePicker();
  final XFile? media = await picker.pickMedia(
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    imageQuality: imageQuality,
  );
  return media;
}

/// 使用[ImagePicker]获取多个图片/视频
Future<List<XFile>> pickerMultipleMedia({
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
  int? limit,
}) async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> medias = await picker.pickMultipleMedia(
    limit: limit,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    imageQuality: imageQuality,
  );
  return medias;
}

/// 使用[ImagePicker]获取多个图片
Future<List<XFile>> pickMultiImage({
  int? limit,
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
}) async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> medias = await picker.pickMultiImage(
    limit: limit,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    imageQuality: imageQuality,
  );
  return medias;
}
