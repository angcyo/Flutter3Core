part of '../../../flutter3_basics.dart';

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
    entry.addListener(_checkRemove);
  }

  /// 移除[Entry]
  void removeOverlayEntry({required Key key}) {
    _overlayEntries.remove(key);
  }

  /// 检查[OverlayEntry]是否已被移除
  void _checkRemove() {
    _overlayEntries.removeWhere((key, value) => value.mounted == false);
  }
}

mixin OverlayManageMixin<T extends StatefulWidget> on State<T> {
  final List<OverlayEntry> _overlayEntryList = [];

  /// 在[dispose]时, 移除所有的[OverlayEntry]
  void hookOverlayEntry(OverlayEntry entry) {
    _overlayEntryList.add(entry);
  }

  @override
  void dispose() {
    for (var entry in _overlayEntryList) {
      try {
        entry.remove();
      } catch (e) {
        printError(e);
      }
    }
    _overlayEntryList.clear();
    super.dispose();
  }
}
