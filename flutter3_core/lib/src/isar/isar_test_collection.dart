import 'package:isar/isar.dart';

part 'isar_test_collection.g.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/17
///
/// 1:代码构建工具
///
/// ```
/// dev_dependencies:
///  isar_generator: *isar_version`
/// ```
///
/// 2:必须包含part xxx
/// ```
/// part 'xxx.g.dart';
///
/// ```
///
/// 3:执行
/// 创建表之后, 执行命令, 生成对应数据表代码
/// ```
/// dart run build_runner build
/// flutter pub run build_runner build
/// ```

/// https://isar.dev/zh/schema.html
/// Isar 支持的数据类型
/// Isar 支持以下数据类型：
///   bool
///   byte     0 到 255
///   short    -2,147,483,647 到 2,147,483,647
///   int      -9,223,372,036,854,775,807 到 9,223,372,036,854,775,807
///   float    -3.4e38 到 3.4e38
///   double   -1.7e308 到 1.7e308
///   DateTime
///   String
///   List<bool>
///   List<byte>
///   List<short>
///   List<int>
///   List<float>
///   List<double>
///   List<DateTime>
///   List<String>
@collection
@Name("TestCollection")
class TestCollection {
  //Id? id;
  Id id = Isar.autoIncrement; // 你也可以用 id = null 来表示 id 是自增的

  @Name("firstName")
  String? firstName;

  @Name("lastName")
  String? lastName;

  @ignore
  String? testIgnore;
}

/// 查询对象
/// https://isar.dev/zh/crud.html#%E6%9F%A5%E8%AF%A2%E5%AF%B9%E8%B1%A1
/// ```
/// final allRecipes = await isar.recipes.where().findAll();
///
/// final favouires = await isar.recipes.filter()
///   .isFavoriteEqualTo(true)
///   .findAll();
/// ```

/// 插入对象
/// https://isar.dev/zh/crud.html#%E6%8F%92%E5%85%A5%E5%AF%B9%E8%B1%A1
/// ```
/// final pancakes = Recipe()
///   ..name = 'Pancakes'
///   ..lastCooked = DateTime.now()
///   ..isFavorite = true;
///
/// await isar.writeTxn(() async {
///   await isar.recipes.put(pancakes);
/// })
/// ```

/// 修改对象
/// https://isar.dev/zh/crud.html#%E4%BF%AE%E6%94%B9%E5%AF%B9%E8%B1%A1
/// ```
/// await isar.writeTxn(() async {
///   pancakes.isFavorite = false;
///   await isar.recipes.put(recipe);
/// });
/// ```

/// 删除对象
/// https://isar.dev/zh/crud.html#%E5%88%A0%E9%99%A4%E5%AF%B9%E8%B1%A1
/// ```
/// await isar.writeTxn(() async {
///   final success = await isar.recipes.delete(123);
///   print('Recipe deleted: $success');
/// });
///
/// await isar.writeTxn(() async {
///   final count = await isar.recipes.deleteAll([1, 2, 3]);
///   print('We deleted $count recipes');
/// });
/// 
/// await isar.writeTxn(() async {
///   final count = await isar.recipes.filter()
///     .isFavoriteEqualTo(false)
///     .deleteAll();
///   print('We deleted $count recipes');
/// });
/// ```
