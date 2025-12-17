part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/18
///
/// 文件选择扩展
/// 选择单图片, 默认关闭了图片压缩.
/// 关闭图片压缩后, `file_picker`插件不会走sd卡权限获取
Future<PlatformFile?> pickSingleImage({
  bool allowCompression = false,
  int compressionQuality = 0,
}) async {
  return (await pickFiles(
    type: FileType.image,
    allowCompression: allowCompression,
    compressionQuality: compressionQuality,
    allowMultiple: false,
  ))?.files.firstOrNull;
}

/// 选择单个文件, 选择多个文件请使用[pickFiles]
/// @return null表示取消了选择
Future<PlatformFile?> pickFile({
  String? dialogTitle,
  String? initialDirectory,
  List<String>? allowedExtensions,
  bool withData = false,
  bool withReadStream = false,
}) async {
  return (await pickFiles(
    type: isNil(allowedExtensions) ? FileType.any : FileType.custom,
    allowCompression: false,
    compressionQuality: 0,
    allowMultiple: false,
    dialogTitle: dialogTitle,
    initialDirectory: initialDirectory,
    allowedExtensions: allowedExtensions,
    withData: withData,
    withReadStream: withReadStream,
  ))?.files.firstOrNull;
}

/// 选择多个文件[allowMultiple], 使用系统自带的文件选择器
/// 选择图片
/// 选择视频
/// ```
/// /data/user/0/com.angcyo.flutter3.abc/cache/file_picker/girl.jpg
/// ```
/// [MethodChannelFilePicker] Unsupported operation. Method not found.
/// The exception thrown was: Binding has not yet been initialized.
/// [allowedExtensions] 允许的文件扩展名, Optionally, [allowedExtensions] might be provided (e.g. `[pdf, svg, jpg]`.).
/// [initialDirectory] 可以选择设置为绝对路径，以指定对话框的打开位置。仅在 Linux、macOS 和 Windows 上受支持
/// [allowCompression] 是否允许压缩文件
/// [onFileLoading] 文件加载状态回调
/// [allowMultiple] 是否允许多选
/// [withData] 是否返回数据,而非文件. 在web端时需要.
/// [withReadStream] 是否返回文件流
/// [readSequential] 可以选择在 Web 上设置以在导入过程中保持导入文件顺序。
@allPlatformFlag
Future<FilePickerResult?> pickFiles({
  FileType type = FileType.any,
  bool allowMultiple = false,
  String? dialogTitle,
  String? initialDirectory,
  List<String>? allowedExtensions,
  Function(FilePickerStatus)? onFileLoading,
  bool allowCompression = true,
  int? compressionQuality,
  bool withData = false,
  bool withReadStream = false,
  bool lockParentWindow = false,
  bool readSequential = false,
}) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: dialogTitle,
    initialDirectory: initialDirectory ?? _lastPickDirectory,
    type: type,
    allowedExtensions: allowedExtensions,
    compressionQuality: allowCompression ? (compressionQuality ?? 30) : 0,
    onFileLoading: onFileLoading,
    allowCompression: allowCompression,
    allowMultiple: allowMultiple,
    withData: withData,
    withReadStream: withReadStream,
    lockParentWindow: lockParentWindow,
    readSequential: readSequential,
  );

  //temp
  _lastPickDirectory = result?.files.firstOrNull?.path ?? _lastPickDirectory;

  //Android girl.jpg:/data/user/0/com.angcyo.flutter3.abc/cache/file_picker/girl.jpg
  assert(() {
    if (result != null) {
      result.files.forEachIndexed((index, element) {
        l.d(
          '选择文件[$index][${element.name}:${element.size.toSizeStr()}][${element.path?.mimeType(element.bytes)}]->${element.path} bytes:${element.bytes?.length}',
        );
      });
    } else {
      l.d('取消选择文件');
    }
    return true;
  }());

  return result;
}

/// 选择文件夹路径
/// initialDirectory 可以选择设置为绝对路径，以指定对话框的打开位置。仅在 Linux 和 macOS 上受支持
/// https://pub.dev/packages/file_picker
@PlatformFlag("Android iOS Linux macOS Windows")
Future<String?> pickDirectoryPath({
  String? dialogTitle,
  bool lockParentWindow = false,
  String? initialDirectory,
}) async {
  final path = await FilePicker.platform.getDirectoryPath(
    dialogTitle: dialogTitle,
    lockParentWindow: lockParentWindow,
    initialDirectory: initialDirectory,
  );
  assert(() {
    if (path != null) {
      l.d('选择文件夹->$path');
    } else {
      l.d('取消选择文件夹');
    }
    return true;
  }());
  return path;
}

/// 调用平台的对话框保存文件, 返回平台对应的保存文件路径
/// 此方法仅适用于桌面平台（Linux、macOS 和 Windows）。
///
/// 桌面端显示本地对话框保存文件.
///
/// ## macOS
///
/// 需要权限: ENTITLEMENT_REQUIRED_WRITE, 在 `DebugProfile.entitlements`和`Release.entitlements` 文件中加入:
///
/// ```
/// <key>com.apple.security.files.user-selected.read-write</key>
/// <true/>
/// ```
///
/// https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#--desktop
///
/// @return 待保存文件的路径(文件可能不存在)
///
/// https://pub.dev/packages/file_picker
@PlatformFlag("Android iOS Linux macOS Windows")
Future<String?> saveFile({
  String? dialogTitle,
  String? fileName,
  String? initialDirectory,
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  bool lockParentWindow = false,
}) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    initialDirectory: initialDirectory ?? _lastPickDirectory,
    type: type,
    allowedExtensions: allowedExtensions,
    lockParentWindow: lockParentWindow,
  );
  //temp
  _lastPickDirectory = path ?? _lastPickDirectory;
  assert(() {
    if (path != null) {
      l.d('保存文件至->$path [${path.fileSizeStr}]');
    } else {
      l.d('取消保存文件');
    }
    return true;
  }());
  return path;
}

/// 缓存上次选择的文件夹路径
@tempFlag
String? _lastPickDirectory;

extension PickerImageEx on UiImage {
  /// 调用系统弹窗, 选择文件路径, 保存图片
  @desktopFlag
  Future<File?> saveAsFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    UiImageByteFormat format = UiImageByteFormat.png,
  }) async {
    final filePath = await saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: initialDirectory,
    );
    if (!isNil(filePath)) {
      final Uint8List? bytes = await toBytes(format);
      if (bytes == null) {
        return null;
      }
      return filePath!.file().writeAsBytes(bytes);
    }
    return null;
  }
}

extension PickerBytesEx on List<int> {
  /// 调用系统弹窗, 选择文件路径, 保存数据
  @desktopFlag
  Future<File?> saveAsFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
  }) async {
    final filePath = await saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: initialDirectory,
    );
    if (!isNil(filePath)) {
      return filePath!.file().writeAsBytes(this);
    }
    return null;
  }
}
