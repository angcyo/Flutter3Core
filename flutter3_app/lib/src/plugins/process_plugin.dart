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
  @api
  Future<bool> uninstall({String? reason}) async => false;

  /// 启动插件, 自动触发下载插件
  /// - [ignoreUpdate] 是否忽略插件的更新, 直接运行?
  /// @return 插件返回值
  @api
  Future<Object?> start(
    BuildContext? context, {
    bool? ignoreUpdate,
    String? reason,
  }) async => null;

  /// 从本地文件安装插件
  /// - [filePath]通常是下载成功的zip文件
  /// @return 是否安装成功
  @api
  Future<bool> install(String filePath, {String? reason}) async => false;

  /// 插进安装成功回调
  /// - [path] 插件安装所在的路径
  @overridePoint
  Future onSelfInstallSuccess(String path, {String? reason}) async {}
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

  /// 是否是否有更新的缓存
  @configProperty
  bool? isUpdateCached;

  /// 插件是否有更新
  @override
  Future<bool> get isUpdate async => isUpdateCached ?? false;

  @override
  Future<dynamic> onSelfInstallSuccess(String path, {String? reason}) {
    //清楚缓存
    if (isUpdateCached != null) {
      //debugger();
      isUpdateCached = null;
    }
    return super.onSelfInstallSuccess(path, reason: reason);
  }

  @override
  Future<Object?> start(
    BuildContext? context, {
    bool? ignoreUpdate,
    String? reason,
  }) async {
    final bool isInstalled = await this.isInstalled;
    final bool isUpdate = await this.isUpdate;
    if (isInstalled && (ignoreUpdate == true || !isUpdate)) {
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
        try {
          final resultList = await shell.run(exeScript);
          final errText = resultList.errText2;
          final outText = resultList.outText2;
          if (!isNil(errText)) {
            l.w("[${classHash()}]插件运行错误->$errText");
          }
          /*if(isNil(outText)){}*/
          //resultList.errText2;
          return outText;
        } catch (e) {
          l.e("[${classHash()}]插件运行失败->$e");
          if (e.isShellException) {
            toast(e.message.text(useDefStyle: false));
            return null;
          } else {
            rethrow;
          }
        }
      }
    } else {
      //下载或更新并安装插件
      context?.buildContext?.showWidgetDialog(
        PluginInstallDialog(this, pluginState: isUpdate ? .update : null),
      );
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

  /// 需要更新
  update,

  /// 下载中...
  downloading,

  /// 安装中...
  installing,

  /// 安装成功
  installed,
}
