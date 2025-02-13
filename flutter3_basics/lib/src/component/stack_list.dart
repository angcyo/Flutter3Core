part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///
/// 使用[List]实现的栈结构
class StackList<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E? popOrNull() => _list.isEmpty ? null : pop();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  E? get lastOrNull => _list.lastOrNull;

  E get last => _list.last;

  @override
  String toString() => _list.toString();
}
