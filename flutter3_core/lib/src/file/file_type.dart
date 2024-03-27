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
      lookupMimeType(path, headerBytes: this)?.isImageMimeType == true;
}

/// [defaultExtensionMap]
/// [MimeTypeResolver]
extension MimeEx on String {
  /// 是否是图片类型, svg也属性图片类型
  /// ```
  /// 'svg': 'image/svg+xml',
  /// 'svgz': 'image/svg+xml',
  /// ```
  bool get isImageMimeType => toLowerCase().startsWith('image');

  bool get isVideoMimeType => toLowerCase().startsWith('video');

  bool get isAudioMimeType => toLowerCase().startsWith('audio');

  ///svg类型
  bool get isSvgMimeType => toLowerCase().startsWith('image/svg');

  /// 是否是ttf/otf字体
  /// ```
  /// 'otf': 'application/x-font-otf',
  /// 'ttc': 'application/x-font-ttf',
  /// 'ttf': 'application/x-font-ttf',
  /// ```
  bool get isFontMimeType =>
      toLowerCase().startsWith('application/x-font-otf') ||
      toLowerCase().startsWith('application/x-font-ttf');

  /// 'zip': 'application/zip'
  bool get isZipMimeType => toLowerCase().startsWith('application/zip');

  /// 'txt': 'text/plain',
  bool get isTextMimeType => toLowerCase().startsWith('text/');

  /// 获取文件的Mime类型
  /// ```
  /// print(lookupMimeType('test.html')); // text/html
  ///
  /// print(lookupMimeType('test', headerBytes: [0xFF, 0xD8])); // image/jpeg
  ///
  /// print(lookupMimeType('test.html', headerBytes: [0xFF, 0xD8])); // image/jpeg
  ///
  /// ```
  String? mimeType([List<int>? headerBytes]) {
    final path = toUri()?.path ?? this;
    final mimeType = lookupMimeType(
      path,
      headerBytes: headerBytes,
    );
    if (mimeType == null) {
      return null;
    }
    return mimeType; // image/jpeg
  }

  ///判断当前是否是http/https网络地址
  bool get isHttpUrl {
    return startsWith('http://') || startsWith('https://');
  }

  ///判断当前是否是本地文件地址
  bool get isLocalUrl {
    return startsWith('file://');
  }

  ///判断当前字符串是否是文件路径
  bool get isFilePath {
    return File(this).existsSync();
  }

  /// 判断是否是svg
  bool get isSvg {
    return toUri()?.path.toLowerCase().endsWith('.svg') == true;
  }
}

/// 获取文件类型图标
/// [fileName] 文件名, 包含后缀
/// [def] 未知类型时的默认图标
/// [extMap] 自定义扩展名对应的图标
///
Image? getFileIconWidget(
  String? fileName, {
  double? width,
  double? height,
}) {
  final ext = fileName?.extension();
  if (ext == null) {
    return null;
  }
  final mime = fileName?.mimeType();

  var pngAssets = Assets.png;
  String key = pngAssets.coreFileIconUnknown.keyName;
  if (mime?.isImageMimeType == true) {
    key = pngAssets.coreFileIconPicture.keyName;
  } else if (mime?.isVideoMimeType == true) {
    key = pngAssets.coreFileIconVideo.keyName;
  } else if (mime?.isFontMimeType == true) {
    key = pngAssets.coreFileIconFont.keyName;
  } else if (ext == '.log') {
    key = pngAssets.coreFileIconLog.keyName;
  } else if (ext == '.7z') {
    key = pngAssets.coreFileIcon7z.keyName;
  } else if (ext == '.rar') {
    key = pngAssets.coreFileIconRar.keyName;
  } else if (ext == '.xml') {
    key = pngAssets.coreFileIconXml.keyName;
  } else if (ext == '.apk') {
    key = pngAssets.coreFileIconApk.keyName;
  } else if (mime?.isTextMimeType == true || ext == '.txt') {
    key = pngAssets.coreFileIconText.keyName;
  } else if (mime?.isAudioMimeType == true) {
    key = pngAssets.coreFileIconAudio.keyName;
  } else if (mime?.isZipMimeType == true || ext == '.zip') {
    key = pngAssets.coreFileIconZip.keyName;
  }
  return loadCoreAssetImageWidget(key, width: width, height: height);
}
