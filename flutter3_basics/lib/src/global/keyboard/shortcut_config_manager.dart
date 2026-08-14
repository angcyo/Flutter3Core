part of '../../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 全局快捷键配置管理
///
/// - [addShortcutConfig] 添加快捷键配置
/// - [registerShortcutAction] 添加快捷键配置
/// - [triggerShortcutAction] 触发快捷键执行动作
///
/// - [ShortcutConfigBean]
class ShortcutConfigManager {
  /// 快捷键配置列表
  final List<ShortcutConfigBean> shortcutConfigList;

  /// 快捷键id[ShortcutConfigBean.id]对应的执行动作列表
  final Map<String, ShortcutIntentAction> shortcutActionMap = {};

  ShortcutConfigManager({List<ShortcutConfigBean>? shortcutConfigList})
    : shortcutConfigList = shortcutConfigList ?? [];

  //MARK: - config

  /// 添加快捷键配置
  @api
  void addShortcutConfig(
    ShortcutConfigBean? shortcutConfigBean, {
    ShortcutIntentAction? action,
    bool? ignoreDebug,
  }) {
    if (shortcutConfigBean == null) {
      debugger();
      return;
    }
    assert(() {
      final find = shortcutConfigList.findFirst(
        (e) => e.id == shortcutConfigBean.id,
      );
      debugger(when: ignoreDebug != true && find != null);
      return true;
    }());
    shortcutConfigList.add(shortcutConfigBean);
    if (action != null) {
      registerShortcutAction(shortcutConfigBean.id, action);
    }
  }

  /// 移除快捷键配置
  @api
  void removeShortcutConfig({String? id, ShortcutConfigBean? config}) {
    if (id == null && config == null) {
      debugger();
      return;
    }
    shortcutConfigList.removeWhere(
      (e) => id != null ? e.id == id : e == config,
    );
  }

  /// 查找快捷键配置
  @api
  List<ShortcutConfigBean> findShortcutConfig({
    String? id,
    ShortcutConfigBean? config,
  }) {
    return shortcutConfigList.where((element) {
      if (id != null) {
        return element.id == id;
      }
      return element == config;
    }).toList();
  }

  /// 清除所有快捷键配置
  @api
  void clearShortcutConfig() {
    shortcutConfigList.clear();
  }

  //MARK: - action

  /// 注册一个快捷键执行动作
  @api
  void registerShortcutAction(
    String? id,
    ShortcutIntentAction shortcutIntentAction,
  ) {
    if (id == null) {
      debugger();
      return;
    }
    shortcutActionMap[id] = shortcutIntentAction;
  }

  /// 移除一个快捷键执行动作
  @api
  void unregisterShortcutAction(String? id) {
    if (id == null) {
      debugger();
      return;
    }
    shortcutActionMap.remove(id);
  }

  /// 清除所有快捷键执行动作
  @api
  void clearShortcutAction() {
    shortcutActionMap.clear();
  }

  /// 触发一个快捷键执行动作
  ///
  /// - [context] 布局上下文
  /// - [event] 当前的键盘事件
  /// - [host] 宿主对象, 比如当前所在的窗口/容器/可操作对象等
  /// - [data] 调用传递的数据
  ///
  /// - [ShortcutIntentAction]
  @api
  KeyEventResult? triggerShortcutAction({
    //快捷键
    String? id,
    ShortcutConfigBean? config,
    KeyEvent? event,
    //参数
    BuildContext? context,
    dynamic host,
    dynamic data,
  }) {
    final List<ShortcutConfigBean> list = [];
    if (config == null) {
      if (id != null) {
        //用id查找
        list.addAll(findShortcutConfig(id: id));
      } else if (event != null) {
        //用event查找
        final keyConfig = ShortcutConfigBean.fromKeyEvent(
          event,
          control: isCtrlPressed,
          alt: isAltPressed,
          shift: isShiftPressed,
          meta: isMetaPressed,
        );
        list.addAll(findShortcutConfig(config: keyConfig));
      }
    } else {
      list.add(config);
    }
    //--action
    KeyEventResult? result; //!event.isModifierKey
    for (final element in list) {
      if (event != null) {
        //键盘事件
        if (element.byKeyDown == true) {
          if (element.includeRepeats == true && event.isKeyRepeat) {
            //需要处理重复按键
          } else if (!event.isKeyDown) {
            continue;
          }
        }
      }
      final action = shortcutActionMap[element.id];
      if (action != null) {
        final elementResult = action(context, event, host, data);
        result ??= elementResult;
        if (elementResult == KeyEventResult.handled) {
          result = elementResult;
        }
      }
    }
    return result;
  }
}

/// [ShortcutConfigManager]的实例
@globalInstance
final $globalShortcutConfigManager = ShortcutConfigManager();
