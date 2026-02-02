part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/02
///
/// dynamic 相关的扩展
///
extension ListDynamicEx on List<dynamic> {
  /// 映射类型转换成[Type]的[List]
  /// - [ListEx.mapToList]
  /// - [IterableEx.mapToList]
  List<Type> map2List<Type>(
    Type Function(dynamic e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      //debugger();
      final r = toElement(e);
      return r;
    }).toList(growable: growable);
  }
}
