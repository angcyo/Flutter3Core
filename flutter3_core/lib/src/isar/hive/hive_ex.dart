part of '../../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 分隔符
const kHiveSplitChar = "|";

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
Map<String, dynamic>? hiveAll([Box? box]) {
  try {
    box ??= _hiveBox;
    Map<String, dynamic> map = {};
    for (final key in box.keys) {
      map[key] = box.get(key);
    }
    return map;
  } catch (e) {
    return null;
  }
}

extension HiveStringEx on String {
  /// 保存键值对, 当[value]不支持时, 会自动使用字符串存储
  /// `[HiveError]HiveError: Cannot write, unknown type: TextEditingValue. Did you forget to register an adapter?`
  Future<dynamic> hivePut(dynamic value, [bool notifyChanged = true]) {
    //debugger();
    if (value == null) {
      final result = hiveDelete();
      if (notifyChanged) {
        notifyDebugValueChanged(value);
      }
      return result;
    }
    final result = _hiveBox.put(this, value).get((v, error) {
      if (value != null && error is HiveError) {
        assert(() {
          l.e("存储类型失败:[${value.runtimeType}]:$error, 自动转换为字符串存储");
          return true;
        }());
        return hivePut("$value", notifyChanged);
      }
      return v;
    });
    if (notifyChanged) {
      notifyDebugValueChanged(value);
    }
    return result;
  }

  /// [hivePut]
  Future<dynamic> hiveSet(dynamic value, [bool notifyChanged = true]) =>
      hivePut(value, notifyChanged);

  /// 删除指定键
  Future<void> hiveDelete() => _hiveBox.delete(this);

  /// 是否包含指定key
  bool hiveHaveKey() => _hiveBox.containsKey(this);

  Stream<BoxEvent> hiveWatch() => _hiveBox.watch(key: this);

  /// 获取指定键的值
  T? hiveGet<T>([T? defaultValue]) =>
      _hiveBox.get(this, defaultValue: defaultValue);

  /// 将一个值, 保存到指定键的json列表中
  /// [sort] 是否排序, 开启排序后, 最后添加的数据在最前面
  /// [removeDuplicate] 是否移除重复的数据
  /// [maxCount] 最大保存数量, 超过数量后, 会删除最后的数据
  Future<dynamic> hivePutList(
    String value, {
    bool sort = true,
    bool removeDuplicate = true,
    bool notifyChanged = true,
    int? maxCount,
  }) {
    final list = hiveGetList();
    if (removeDuplicate) {
      list.remove(value);
    }
    if (maxCount != null && list.length + 1 > maxCount) {
      //移除所有超出的数据
      list.removeRange(maxCount - 1, list.length);
    }
    if (sort) {
      list.insert(0, value);
    } else {
      list.add(value);
    }
    return hivePut(list.toJsonString(null), notifyChanged);
  }

  /// [hivePutList]
  /// [hiveGetList]
  Future<dynamic> hiveDeleteList(String value, {bool notifyChanged = true}) {
    final list = hiveGetList();
    list.remove(value);
    return hivePut(list.toJsonString(null), notifyChanged);
  }

  /// 获取指定键的字符串列表值, 使用json解析
  List<String> hiveGetList() {
    final json = hiveGet<String>();
    if (json == null || isNil(json)) {
      return [];
    }
    return json.fromJsonList<String>() ?? [];
  }

  //--

  /// 当前的key对应的value改变后通知
  void onHiveValueChanged(DebugValueChanged debugValueChanged) {
    onDebugValueChanged(debugValueChanged);
  }

  /// 移除当前key对应的value变化监听
  void removeHiveValueChanged(DebugValueChanged debugValueChanged) {
    removeDebugValueChanged(debugValueChanged);
  }
}

/// Flutter extensions for Hive.
extension HiveEx on HiveInterface {
  /// 默认路径在:/data/user/0/com.angcyo.flutter3_abc/app_flutter
  /// 移动到:/storage/emulated/0/Android/data/com.angcyo.flutter3_abc/files
  /// Initializes Hive with the path from [getApplicationDocumentsDirectory].
  ///
  /// You can provide a [subDir] where the boxes should be stored.
  /// [Hive.initFlutter]
  Future<void> initHive([String? subDir]) async {
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
    l.i("[$kHiveBox]HiveBox数据库路径:$defHiveBoxFilePath :${defHiveBoxFilePath.file().lengthSync().toSizeStr()}");
    //_hiveBox.add(value)
    //_hiveBox.get(key)
    //Hive.box
    //_hiveBox.listenable()
  }
}

mixin HiveHookMixin<T extends StatefulWidget> on State<T> {
  late final Map<ValueListenable, VoidCallback> hiveHookMap = {};

  /// 当[notify]改变时, 自动保存至hive中
  /// [key] 持久化存储的key值
  /// [ValueListenable]
  /// [TextEditingValue]
  hookHiveKey(String key, ValueListenable notify, {bool notifyChanged = true}) {
    if (hiveHookMap.containsKey(notify)) {
      return;
    }
    hiveHookMap[notify] = () {
      final value = notify.value;
      if (value is TextEditingValue) {
        key.hivePut(value.text, notifyChanged);
      } else {
        key.hivePut(notify.value, notifyChanged);
      }
    };
    notify.addListener(hiveHookMap[notify]!);
  }

  @override
  void dispose() {
    hiveHookMap.forEach((key, value) {
      key.removeListener(value);
    });
    hiveHookMap.clear();
    super.dispose();
  }
}
