part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/17
///

/// https://isar.dev/zh/
/// 专门为 Flutter 打造的超高速跨平台数据库
///

/// 路径名称
const kIsarPath = "isar";

/// 默认的isar数据库名称
const kIsarName = "isar";

/// 路径
String isarPath = "";

/// 默认的数据库对象
/// https://isar.dev/zh/crud.html
late Isar isar;

/// 默认的[isar]文件路径
String defIsarFilePath = "";

/// 打开一个isar数据库
/// [schemas] 指定要打开的数据库表结构
/// [name] 指定要打开的数据库名称, 默认是[kIsarName]
/// [subDir] 指定数据库所在的子目录, 默认在[kIsarPath]子目录的根下
Future<void> openIsar([
  List<CollectionSchema<dynamic>>? schemas,
  String? name,
  String? subDir,
]) async {
  WidgetsFlutterBinding.ensureInitialized();

  //初始化isar数据库
  var isarDir = await fileDirectory();
  if (subDir == null) {
    isarPath = p.join(isarDir.path, kIsarPath);
  } else {
    isarPath = p.join(isarDir.path, subDir, kIsarPath);
  }
  name ??= kIsarName;
  isarPath.createDirectory(); //创建目录
  isar = await Isar.open(
    //At least one collection needs to be opened.
    [if (isDebug) TestCollectionSchema, ...?schemas],
    directory: isarPath,
    name: name,
    inspector: isDebug,
  );

  //检查数据是否需要迁移
  //https://isar.dev/zh/recipes/data_migration.html

  defIsarFilePath = isarPath.join("$name.isar");
  l.i("[$name]isar数据库路径:$defIsarFilePath :${defIsarFilePath.file().lengthSync().toSizeStr()}");
}
