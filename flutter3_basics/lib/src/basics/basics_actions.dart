import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/01
///
/// 快捷键, 快捷操作
/// - [Actions] 定义操作, 意图[Intent]对应[Action], 内部无逻辑, 主要用于提供[Action]
///   - [Actions.handler] 处理操作
///   - [Actions.invoke] 触发操作, 并获取返回值
///   - [Actions.find] 查找操作
/// - [ActionDispatcher] 默认操作分发
/// - [Shortcuts] 定义操作, 内部使用[Focus] + [ShortcutManager] 组合实现
///   - [ShortcutActivator] 快捷键
///   - [Intent] 操作意图
///   - [ShortcutManager] 管理[ShortcutActivator]
extension ActionsEx on Widget {
  /// 添加键盘快捷键, 快捷方式处理
  Widget shortcutActions(
    List<ShortcutAction> actions, {
    Key? key,
    ActionDispatcher? dispatcher,
    String? debugLabel,
  }) {
    final actionsMap = <Type, Action<Intent>>{};
    final shortcutMap = <ShortcutActivator, Intent>{};
    for (final action in actions) {
      actionsMap[action.intent.runtimeType] = action.action;
      shortcutMap[action.shortcut] = action.intent;
    }
    return Actions(
      key: key,
      actions: actionsMap,
      dispatcher: dispatcher,
      child: Shortcuts(
        shortcuts: shortcutMap,
        debugLabel: debugLabel,
        child: this,
      ),
    );
  }
}

/// 快捷键, 以及对应的行为
class ShortcutAction<I extends Intent> {
  /// 调试标签
  final String? debugLabel;

  /// 操作意图
  final I intent;

  /// 触发[intent]的快捷键
  /// - [CharacterActivator]
  /// - [SingleActivator]
  final ShortcutActivator shortcut;

  /// [intent]对应的行为
  final Action<I> action;

  ShortcutAction({
    this.debugLabel,
    required this.intent,
    required this.shortcut,
    required this.action,
  });
}
