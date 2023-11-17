import 'package:isar/isar.dart';

part 'isar_test_collection.g.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/17
///

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
