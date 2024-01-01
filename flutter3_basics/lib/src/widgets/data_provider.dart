part of flutter3_basics;

/// 用来提供数据的一个组件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/24
///

class DataProviderScope extends InheritedWidget {
  final Object? data;

  const DataProviderScope({
    super.key,
    required super.child,
    this.data,
  });

  /// 获取一个上层提供的数据
  /// [DataProviderScope.data]
  static Object? get(BuildContext context, {bool depend = false}) {
    if (depend) {
      return context
          .dependOnInheritedWidgetOfExactType<DataProviderScope>()
          ?.data;
    } else {
      return context.getInheritedWidgetOfExactType<DataProviderScope>()?.data;
    }
  }

  @override
  bool updateShouldNotify(DataProviderScope oldWidget) =>
      isDebug || data != oldWidget.data;
}
