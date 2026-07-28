part of '../../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 全局快捷键配置管理
/// - [ShortcutConfigBean]
class GlobalShortcutConfigManager {
  final List<ShortcutConfigBean> shortcutConfigList;

  GlobalShortcutConfigManager({List<ShortcutConfigBean>? shortcutConfigList})
    : shortcutConfigList = shortcutConfigList ?? [];

  /// 查找快捷键配置
  @api
  List<ShortcutConfigBean> findShortcutConfig({String? id}) {
    return shortcutConfigList.where((element) {
      return element.id == id;
    }).toList();
  }
}

/// [GlobalShortcutConfigManager]的实例
@globalInstance
final $globalShortcutConfigManager = GlobalShortcutConfigManager();
