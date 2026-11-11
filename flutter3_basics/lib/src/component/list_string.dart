part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/11
///
/// List String -> String
class ListString {
  /// 列表
  final List<Object> list;

  /// 分隔符
  final String separator;

  /// 是否反序
  final bool reverse;

  ListString(this.list, {this.separator = '', this.reverse = false});

  /// 添加
  void add(Object value) {
    list.add(value);
  }

  /// 添加列表
  void addAll(List<Object> values) {
    list.addAll(values);
  }

  /// 值
  String get value => (reverse ? list.reversed : list).join(separator);

  @override
  String toString() {
    return value;
  }
}
