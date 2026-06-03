part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/02
///
/// dynamic 相关的扩展
///
extension ListDynamicEx<T> on List<T> {
  /// 映射类型转换成[Type]的[List]
  /// - [ListEx.mapToList]
  /// - [IterableEx.mapToList]
  List<Type> map2List<Type>(
    Type Function(T e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      //debugger();
      final r = toElement(e);
      return r;
    }).toList(growable: growable);
  }

  List<Type> map2ListIndex<Type>(
    Type Function(T e, int index) toElement, {
    bool growable = false,
  }) {
    return mapIndex<Type>((e, index) {
      //debugger();
      final r = toElement(e, index);
      return r;
    }).toList(growable: growable);
  }
}
