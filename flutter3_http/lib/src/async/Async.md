# async: ^2.13.1

https://pub.dev/packages/async

## AsyncCache

缓存结果一段时间

```dart
final _usersCache = new AsyncCache<List<String>>(const Duration(hours: 1));

/// Uses the cache if it exists, otherwise calls the closure:
Future<List<String>> get onlineUsers => _usersCache.fetch(() {
  // Actually fetch online users here.
});
```