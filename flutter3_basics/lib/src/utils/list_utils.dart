///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/24
///

/// Dart不支持可变参数长度, 使用10个参数来模拟可变参数
List<T> listOf<T>(T value,
    [T? v2, T? v3, T? v4, T? v5, T? v6, T? v7, T? v8, T? v9, T? v10]) {
  return [value, v2, v3, v4, v5, v6, v7, v8, v9, v10]
      .takeWhile((value) => value != null)
      .whereType<T>()
      .toList();
}
