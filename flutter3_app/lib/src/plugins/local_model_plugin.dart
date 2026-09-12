part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/12
///
/// 本地模型插件
/// - 下载模型
/// - 更新模型
///
/// - [PluginInstallDialog] 插件安装/更新对话框
class LocalModelPlugin with PluginMixin {
  /// 模型所在的文件夹名
  final String folderName;

  /// [folderName]下, 模型配置信息所在的文件名
  final String configFileName;

  /// 下载地址
  @override
  @configProperty
  String? downloadUrl;

  /// 模型下载时的版本
  @configProperty
  int? downloadVersion;

  //MARK: - get

  /// 模型名称
  String? get modelName => _modelConfig?['name'];

  set modelName(String? value) {
    _modelConfig ??= {};
    _modelConfig?['name'] = value;
  }

  /// 模型的版本号
  int? get modelVersion => _modelConfig?['version'];

  set modelVersion(int? value) {
    _modelConfig ??= {};
    _modelConfig?['version'] = value;
  }

  /// 模型文件名
  String? get modelFileName => _modelConfig?['fileName'];

  set modelFileName(String? value) {
    _modelConfig ??= {};
    _modelConfig?['fileName'] = value;
  }

  /// 模型的文件路径
  String? get modelFilePath => _modelConfig?['filePath'];

  set modelFilePath(String? value) {
    _modelConfig ??= {};
    _modelConfig?['filePath'] = value;
  }

  LocalModelPlugin({
    required this.folderName,
    required this.configFileName,
    this.downloadUrl,
  });

  @output
  Map<String, dynamic>? _modelConfig;

  /// 初始化模型配置信息
  Future _initModelConfig() async {
    //获取模型所在的文件夹
    final modelFolder = await fileFolder(folderName);
    //获取模型配置文件
    final modelConfig = configFileName.file(parentPath: modelFolder.path);
    //debugger();
    if (modelConfig.existsSync()) {
      final text = await modelConfig.readAsString();
      _modelConfig = text.toJson();
      _modelConfig?['filePath'] ??= joinPath(modelFolder.path, modelFileName);
    }
  }

  /// 模型是否安装
  @override
  Future<bool> get isInstalled async {
    await _initModelConfig();
    if (modelFilePath?.isFileExistsSync() == true) {
      return true;
    }
    return false;
  }

  /// 安装模型
  /// - 复制模型文件
  /// - 更新模型配置信息
  @override
  Future<bool> install(String filePath, {String? reason}) async {
    modelFileName = filePath.fileName();
    final modelFolder = await fileFolder(folderName);
    modelFilePath = joinPath(modelFolder.path, modelFileName);
    await filePath.copyTo(modelFilePath!);
    modelVersion = downloadVersion ?? modelVersion;
    final jsonText = _modelConfig?.toJsonString(null);
    if (!isNil(jsonText)) {
      await jsonText!.writeToFile(
        file: configFileName.file(parentPath: modelFolder.path),
      );
    }
    return true;
  }
}
