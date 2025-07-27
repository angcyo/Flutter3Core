part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/10
///
/// 配置文件相关操作
class ConfigFile {
  ConfigFile._();

  /// 配置文件在磁盘上的目录
  static Future<Directory> get configFolderFile => fileFolder('config');

  /// 当调用一次[readConfigFile]之后, 会缓存配置文件的目录
  /// 以便之后可以使用同步方法读取文件内容
  static String? _configFolderFilePath;

  /// 读取一个配置文件
  /// 如果文件在磁盘, 则从磁盘读取, 否则从assets中读取.
  /// 如果指定了http地址, 则从网络上下载文件到磁盘
  /// [key] 通常是文件名, [loadAssetString]
  /// [subFolder] 子目录
  /// [httpUrl] 如果磁盘文件不存在, 则从网络上下载
  /// [forceFetch] 是否要强制拉取网络数据, 否则只在磁盘上没数据时才拉取
  /// [forceAssetToFile] 是否要强制将Asset中的文件, 拷贝到磁盘
  /// [waitHttp] 是否要等待网络数据的返回
  /// [onHttpAction] 网络数据返回后的回调
  /// [onValueAction] 读取到数据后的回调
  static Future<String?> readConfigFile(
    String key, {
    String prefix = kDefAssetsConfigPrefix,
    String? package,
    String? subFolder,
    bool forceFetch = false,
    bool forceAssetToFile = false,
    bool waitHttp = false,
    String? httpUrl,
    ValueCallback? onHttpAction,
    ValueCallback? onValueAction,
  }) async {
    String? result;
    final configFolder = await configFolderFile;
    _configFolderFilePath = configFolder.path;
    //目标配置文件对象
    final file = (subFolder == null
            ? p.join(configFolder.path, key)
            : p.join(configFolder.path, subFolder, key))
        .file();
    try {
      if (!forceAssetToFile && file.existsSync()) {
        //磁盘上的文件已经存在, 则直接读取
        result = await file.readAsString();
      } else {
        //如果磁盘没有, 则降级读取assets中的文件
        forceFetch = true;
        result = await loadAssetString(key, prefix: prefix, package: package);
        if (forceAssetToFile) {
          await result.writeToFile(file: file);
        }
      }
    } catch (e) {
      if (httpUrl == null) {
        assert(() {
          l.w('读取失败[$key]:$e');
          return true;
        }());
      }
    }
    if (result != null) {
      try {
        onValueAction?.call(result);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }

    //判断是否要从网络获取数据
    if (forceFetch && httpUrl != null) {
      //这里不等待网络数据的返回
      final httpFuture = httpUrl.dioGetString().getValue((value, error) {
        if (!isNil(value)) {
          try {
            value!.writeToFile(file: file);
            onHttpAction?.call(value);
            onValueAction?.call(value);
            assert(() {
              l.i("保存配置[$key]: $httpUrl -> ${file.path}");
              return true;
            }());
          } catch (e) {
            assert(() {
              printError(e);
              return true;
            }());
          }
        }
      });
      if (waitHttp) {
        result = (await httpFuture) ?? result;
      }
    }
    return result;
  }

  /// 读取配置文件内容
  static Future<String?> readConfigFileString(
    String key, {
    String? subFolder,
  }) async {
    String? result;
    final configFolder = await configFolderFile;
    _configFolderFilePath = configFolder.path;
    //目标配置文件对象
    final file = (subFolder == null
            ? p.join(configFolder.path, key)
            : p.join(configFolder.path, subFolder, key))
        .file();
    try {
      result = await file.readString();
    } catch (e) {
      assert(() {
        l.w('读取文件失败[$file]:$e');
        return true;
      }());
    }
    return result;
  }

  /// 同步读取配置文件内容, 请确保调用过一次[readConfigFile]
  /// [_configFolderFilePath]
  static String? readConfigFileStringSync(
    String key, {
    String? subFolder,
  }) {
    String? result;
    final configFolder = _configFolderFilePath ?? "";
    //目标配置文件对象
    final file = (subFolder == null
            ? p.join(configFolder, key)
            : p.join(configFolder, subFolder, key))
        .file();
    try {
      result = file.readAsStringSync();
    } catch (e) {
      assert(() {
        l.w('读取文件失败[$file]:$e');
        return true;
      }());
    }
    return result;
  }
}
