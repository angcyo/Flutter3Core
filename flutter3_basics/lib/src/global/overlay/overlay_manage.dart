part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/10
///

mixin OverlayManage<Entry extends OverlayEntry> on Diagnosticable {
  /// [UniqueKey] 用于标识[OverlayEntry]
  final Map<Key, Entry> _overlayEntries = {};

  /// 获取[Entry]
  Entry? getOverlayEntry({required Key key}) {
    return _overlayEntries[key];
  }

  /// 添加[Entry]
  void addOverlayEntry(Entry entry, {required Key key}) {
    _overlayEntries[key] = entry;
  }

  /// 移除[Entry]
  void removeOverlayEntry({required Key key}) {
    _overlayEntries.remove(key);
  }
}
