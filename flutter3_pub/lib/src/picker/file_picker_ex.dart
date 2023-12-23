part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/18
///

/// 选择文件
/// ```
/// /data/user/0/com.angcyo.flutter3.abc/cache/file_picker/girl.jpg
/// ```
/// [MethodChannelFilePicker] Unsupported operation. Method not found.
/// The exception thrown was: Binding has not yet been initialized.
/// [initialDirectory] 可以选择设置为绝对路径，以指定对话框的打开位置。仅在 Linux、macOS 和 Windows 上受支持
/// [allowCompression] 是否允许压缩文件
/// [allowMultiple] 是否允许多选
/// [withData] 是否返回数据,而非文件. 在web端时需要.
/// [withReadStream] 是否返回文件流
Future<FilePickerResult?> pickFiles({
  FileType type = FileType.any,
  bool allowMultiple = false,
  String? dialogTitle,
  String? initialDirectory,
  List<String>? allowedExtensions,
  Function(FilePickerStatus)? onFileLoading,
  bool allowCompression = true,
  bool withData = false,
  bool withReadStream = false,
  bool lockParentWindow = false,
  bool readSequential = false,
}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: dialogTitle,
    initialDirectory: initialDirectory,
    type: type,
    allowedExtensions: allowedExtensions,
    onFileLoading: onFileLoading,
    allowCompression: allowCompression,
    allowMultiple: allowMultiple,
    withData: withData,
    withReadStream: withReadStream,
    lockParentWindow: lockParentWindow,
    readSequential: readSequential,
  );

  if (result != null) {
    //Android girl.jpg:/data/user/0/com.angcyo.flutter3.abc/cache/file_picker/girl.jpg
    if (isDebug) {
      result.files.forEachIndexed((index, element) {
        l.d('选择文件[$index]->${element.name}:${element.path}');
      });
    }
  } else {
    l.d('取消选择文件');
  }
  return result;
}

/// 选择文件夹路径
/// initialDirectory 可以选择设置为绝对路径，以指定对话框的打开位置。仅在 Linux 和 macOS 上受支持
Future<String?> pickDirectoryPath({
  String? dialogTitle,
  bool lockParentWindow = false,
  String? initialDirectory,
}) async {
  var path = await FilePicker.platform.getDirectoryPath(
    dialogTitle: dialogTitle,
    lockParentWindow: lockParentWindow,
    initialDirectory: initialDirectory,
  );
  if (path != null) {
    l.d('选择文件夹->$path');
  } else {
    l.d('取消选择文件夹');
  }
  return path;
}

/// 保存文件
/// 此方法仅适用于桌面平台（Linux、macOS 和 Windows）。
Future<String?> saveFile({
  String? dialogTitle,
  String? fileName,
  String? initialDirectory,
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  bool lockParentWindow = false,
}) async {
  var path = await FilePicker.platform.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    initialDirectory: initialDirectory,
    type: type,
    allowedExtensions: allowedExtensions,
    lockParentWindow: lockParentWindow,
  );
  if (path != null) {
    l.d('保存文件至->$path');
  } else {
    l.d('取消保存文件');
  }
  return path;
}
