part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 默认的盒子名称
const kHiveBox = "HiveBox";
const kHiveBoxPath = "hive";

/// 默认的数据盒子
late Box _hiveBox;

/// 默认的Hive数据库路径, 不支持修改
/// [hiveBoxPath/kHiveBox.hive] 完整的文件路径
String hiveBoxPath = "";

/// 默认的[_hiveBox]文件路径
String defHiveBoxFilePath = "";

/// 获取所有
Map<String, dynamic> hiveAll([Box? box]) {
  box ??= _hiveBox;
  Map<String, dynamic> map = {};
  for (var key in box.keys) {
    map[key] = box.get(key);
  }
  return map;
}

extension HiveStringEx on String {
  /// 保存键值对
  Future<void> hivePut(dynamic value) => _hiveBox.put(this, value);

  /// 删除指定键
  Future<void> hiveDelete() => _hiveBox.delete(this);

  Stream<BoxEvent> hiveWatch() => _hiveBox.watch(key: this);

  /// 获取指定键的值
  T? hiveGet<T>([T? defaultValue]) =>
      _hiveBox.get(this, defaultValue: defaultValue);
}

/// Flutter extensions for Hive.
extension HiveEx on HiveInterface {
  /// 默认路径在:/data/user/0/com.angcyo.flutter3_abc/app_flutter
  /// 移动到:/storage/emulated/0/Android/data/com.angcyo.flutter3_abc/files
  /// Initializes Hive with the path from [getApplicationDocumentsDirectory].
  ///
  /// You can provide a [subDir] where the boxes should be stored.
  /// [Hive.initFlutter]
  Future<void> initFlutterEx([String? subDir]) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) return;
    var appDir = await fileDirectory();
    if (subDir == null) {
      hiveBoxPath = p.join(appDir.path, kHiveBoxPath);
    } else {
      hiveBoxPath = p.join(appDir.path, subDir, kHiveBoxPath);
    }

    init(hiveBoxPath);

    _hiveBox = await Hive.openBox(kHiveBox);
    defHiveBoxFilePath = hiveBoxPath.join("${kHiveBox.toLowerCase()}.hive");
    l.i("[$kHiveBox]HiveBox数据库路径:$defHiveBoxFilePath :${defHiveBoxFilePath.file().lengthSync().toFileSizeStr()}");
    //_hiveBox.add(value)
    //_hiveBox.get(key)
    //Hive.box
    //_hiveBox.listenable()
  }
}
