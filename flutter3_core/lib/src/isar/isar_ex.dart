part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/17
///

/// https://isar.dev/zh/
/// 专门为 Flutter 打造的超高速跨平台数据库
///
/// # 查
/// ```
/// final laserOptionCollection = $isar.collections
///    .filter()
///    .dataModeEqualTo(dataMode)
///    .and()
///    .dpiEqualTo(dpi)
///    .and()
///    .laserOptionTypeEqualTo(LaserOptionType.element.name)
///    .findLastSync();
/// //--
/// $isar.collections.where().findAllSync();
/// ```
///
/// # 增
/// ```
/// final collection = Collection();
/// $isar.writeTxnSync(() {
///   $isar.collections.putSync(collection);
///   $isar.collections.putAllSync([collection]);
///   //--
///   $isar.collections.deleteSync(id);
///   $isar.collections.deleteAllSync([id]);
///   //--
/// });
/// ```

/// 路径名称
const kIsarPath = "isar";

/// 默认的isar数据库名称
const kIsarName = "isar";

/// 路径
String isarPath = "";

/// 默认的数据库对象
/// https://isar.dev/zh/crud.html
late Isar $isar;

/// 默认的[$isar]文件路径
String defIsarFilePath = "";

/// 别名
/// 所有[Collection], 都需要使用[registerIsarCollection]注册
/// `xxxCollectionSchema`
const isarCollection = collection;

/// 别名
/// [Collection]
const isarSchema = collection;

/// 别名
/// [Collection]
const isarEntity = collection;

/// [registerIsarCollection]
final Map<String, List<CollectionSchema<dynamic>>> _collectionSchemaMap = {};

/// 注册一个在[name]数据中的表[schema], 请在[openIsar]之前注册
/// [name] 注册到那个数据库的名称, 默认是[kIsarName]
/// [xxxSchema]
/// [TestCollectionSchema]
void registerIsarCollection(
  CollectionSchema<dynamic> schema, {
  String? name,
}) {
  //注册isar数据库
  name ??= kIsarName;
  //list
  final list = _collectionSchemaMap[name] ?? [];
  list.add(schema);
  _collectionSchemaMap[name] = list;
}

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
  $isar = await Isar.open(
    //At least one collection needs to be opened.
    [
      if (isDebug) TestCollectionSchema,
      ...?schemas,
      ...?_collectionSchemaMap[name],
    ],
    directory: isarPath,
    name: name,
    inspector: isDebug,
  );

  //检查数据是否需要迁移
  //如果需要迁移数据, 请在open之后, 进行迁移
  //https://isar.dev/zh/recipes/data_migration.html

  defIsarFilePath = isarPath.join("$name.isar");
  assert(() {
    l.i("[$name]isar数据库路径:$defIsarFilePath :${defIsarFilePath.file().lengthSync().toSizeStr()}");
    return true;
  }());
}

/// 默认的迁移方法, 用于简单的数据迁移
Future<void> defaultIsarMigrate<T>({
  Isar? isar,
  String? name,
}) async {
  try {
    isar ??= $isar;
    name ??= kIsarName;
    final collection = isar.collection<T>();
    final count = await collection.count();
    for (var i = 0; i < count; i += 50) {
      final list = await collection.where().offset(i).limit(50).findAll();
      await collection.putAll(list);
    }
  } catch (e) {
    printError(e);
  }
  /*final schemaList = _collectionSchemaMap[name];
  for (final schema in schemaList) {
  final collection = isar.getCollectionByNameInternal(schema.name);
  }*/
}

//---

const isarHandle = AnnotationMeta("数据库操作");

/// [QueryExecute]
extension IsarQueryExecute<OBJ, R> on QueryBuilder<OBJ, R, QQueryOperations> {
  /// Offset the query results by a static number.
  QueryBuilder<OBJ, R, QAfterOffset> offsetQuery(int offset) {
    return QueryBuilder.apply(this, (q) => q.copyWith(offset: offset));
  }

  /// 查找最后一个个数据
  /// [QueryExecute.findFirstSync]
  Future<R?> findLast() async {
    final list = await findLastList(1);
    return list?.firstOrNull;
  }

  /// 查找最后一个个数据
  /// [QueryExecute.findFirstSync]
  R? findLastSync() {
    final list = findLastListSync(1);
    return list?.firstOrNull;
  }

  /// 查找最后多少个数据
  /// [QueryExecute.findFirstSync]
  Future<List<R>?> findLastList([int count = 1]) async {
    final allCount = await this.count();
    if (allCount <= 0) {
      return null;
    }
    count = min(count, allCount);
    return offsetQuery(allCount - count).limit(count).findAll();
  }

  /// 查找最后多少个数据
  /// [QueryExecute.findFirstSync]
  List<R>? findLastListSync([int count = 1]) {
    final allCount = countSync();
    if (allCount <= 0) {
      return null;
    }
    count = min(count, allCount);
    return offsetQuery(allCount - count).limit(count).findAllSync();
  }
}
