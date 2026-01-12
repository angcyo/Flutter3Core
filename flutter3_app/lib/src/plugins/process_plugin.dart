part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/11
///
/// 用来启动第三方进行的插件
/// - [ProcessShell]

mixin PluginMixin {
  //MARK: - state

  /// 插件是否安装
  Future<bool> get isInstalled async => false;

  /// 插件是否有更新
  Future<bool> get isUpdate async => false;

  /// 插件下载地址
  @configProperty
  String? get downloadUrl => null;

  //MARK: - api

  /// 卸载插件
  /// @return 是否卸载成功
  Future<bool> uninstall() async => false;

  /// 启动插件, 自动触发下载插件
  /// @return 插件返回值
  Future<String?> start(BuildContext? context) async => null;

  /// 从本地文件安装插件
  /// - [filePath]通常是下载成功的zip文件
  /// @return 是否安装成功
  Future<bool> install(String filePath) async => false;
}

/// 执行进程程序的插件
/// - 本地进程
/// - 内置进程等
class ProcessPlugin with PluginMixin {
  /// 进程执行的脚本
  @configProperty
  Future<String?> get script async => null;

  @override
  Future<bool> get isInstalled async => !isNil((await script));

  @override
  Future<String?> start(BuildContext? context) async {
    if (await isInstalled && !(await isUpdate)) {
      //已经安装了插件并且无新插件, 则直接启动
      final exeScript = await script;
      if (exeScript == null) {
        debugger();
        return null;
      } else {
        l.i("[${classHash()}]启动进程->$exeScript");
        final ProcessShell shell = ProcessShell();
        /*shell.stdout.stream.listen((value) {
            addLastMessage(value.utf8Str, isReceived: true);
        });*/
        final resultList = await shell.run(exeScript);
        return resultList.outText2;
      }
    } else {
      //下载或更新并安装插件
      context?.buildContext?.showWidgetDialog(PluginInstallDialog(this));
      return null;
    }
  }
}

/// 可执行文件插件
class ExecutablePlugin extends ProcessPlugin {
  /// 可执行文件所在的本地路径
  @configProperty
  Future<String?> get executablePath async => null;

  @override
  Future<String?> get script => executablePath;

  /// 本地文件存在则视为已安装
  @override
  Future<bool> get isInstalled async =>
      (await executablePath)?.isFileExistsSync() == true;
}

/// 插件的状态
enum PluginState {
  /// 未安装
  uninstall,

  /// 下载中...
  downloading,

  /// 安装中...
  installing,

  /// 安装成功
  installed,
}
