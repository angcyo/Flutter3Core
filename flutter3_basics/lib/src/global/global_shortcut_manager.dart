part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/23
///
/// 全局快捷方式管理
/// - [ShortcutMatcher]
class GlobalShortcutManager {
  final List<ShortcutDescription> shortcutDescriptions;

  GlobalShortcutManager({List<ShortcutDescription>? shortcutDescriptions})
    : shortcutDescriptions = shortcutDescriptions ?? [];

  @api
  void clearShortcut() {
    shortcutDescriptions.clear();
  }

  @api
  void addShortcut(ShortcutDescription shortcutDescription) {
    shortcutDescriptions.add(shortcutDescription);
  }

  @api
  void removeShortcut(ShortcutDescription shortcutDescription) {
    shortcutDescriptions.remove(shortcutDescription);
  }

  @api
  void removeShortcutByTag(String? tag) {
    shortcutDescriptions.removeWhere((element) => element.tag == tag);
  }

  @api
  ShortcutDescription? findShortcutByTag(String? tag) {
    return shortcutDescriptions.firstWhereOrNull(
      (element) => element.tag == tag,
    );
  }

  /// 触发指定[tag]对应的快捷键意图
  /// - [ShortcutDescription]
  /// - [ShortcutIntentAction]
  @api
  KeyEventResult? triggerShortcut(
    String? tag, {
    BuildContext? context,
    dynamic host,
    dynamic data,
  }) {
    final shortcutDescription = findShortcutByTag(tag);
    if (shortcutDescription != null) {
      return shortcutDescription.action?.call(context, host, data);
    }
    return null;
  }
}

/// 快捷键触发的回调
/// - [context] 布局上下文
/// - [host] 宿主对象, 比如当前所在的窗口/容器/可操作对象等
/// - [data] 调用传递的数据
typedef ShortcutIntentAction =
    KeyEventResult Function(BuildContext? context, dynamic host, dynamic data);

/// 快捷方式描述
class ShortcutDescription {
  //MARK: - shortcut

  /// 标记, 唯一标识
  final String tag;

  /// 激活方式, 触发器
  final ShortcutActivator activator;

  /// 触发的回调
  final ShortcutIntentAction? action;

  //MARK: - ui

  /// 快捷键标签
  final String? label;

  /// 构建快捷键标签
  final Widget Function(BuildContext context)? builderLabel;

  /// 构建快捷键提示
  final Widget Function(BuildContext context)? builderHint;

  ShortcutDescription(
    this.tag,
    this.activator,
    this.action, {
    this.label,
    this.builderLabel,
    this.builderHint,
  });
}

/// [GlobalShortcutManager]的实例
@globalInstance
final $globalShortcutManager = GlobalShortcutManager();
