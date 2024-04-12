part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/10
///
/// 配置文件相关操作

class ConfigFile {
  /// 配置文件在磁盘上的目录
  static Future<Directory> get configFolderFile => fileFolder('config');

  /// 读取一个配置文件
  /// 如果文件在磁盘, 则从磁盘读取, 否则从assets中读取.
  /// 如果指定了http地址, 则从网络上下载文件到磁盘
  /// [httpUrl] 如果磁盘文件不存在, 则从网络上下载
  /// [forceFetch] 是否要强制拉取网络数据, 否则只在磁盘上没数据时才拉取
  static Future<String?> readConfigFile(
    String key, {
    String prefix = 'assets/',
    String? package,
    bool forceFetch = false,
    String? httpUrl,
    ValueCallback? onHttpAction,
  }) async {
    String? result;
    final folder = await configFolderFile;
    final file = p.join(folder.path, key).file();
    if (file.existsSync()) {
      //磁盘上的文件已经存在
      result = await file.readAsString();
    } else {
      result = await loadAssetString(key, prefix: prefix, package: package);
      forceFetch = true;
    }

    if (forceFetch && httpUrl != null) {
      //这里不等待网络数据的返回
      httpUrl.dioGetString().getValue((value, error) {
        if (!isNil(value)) {
          value!.writeToFile(file: file);
          onHttpAction?.call(value);
        }
      });
    }

    return result;
  }
}