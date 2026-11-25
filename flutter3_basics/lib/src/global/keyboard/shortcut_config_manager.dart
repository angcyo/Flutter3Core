part of '../../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 全局快捷键配置管理
/// 1. 先添加快捷键意图[ShortcutIntentBean]
/// 2. 然后添加快捷键配置[ShortcutConfigBean]
/// 3. 然后通过[KeyEvent]查找[ShortcutConfigBean],再通过[ShortcutConfigBean.id]查找[ShortcutIntentBean]并执行动作
///
/// - [addShortcutConfig] 添加快捷键配置
/// - [registerShortcutAction] 添加快捷键配置
/// - [triggerShortcutAction] 触发快捷键执行动作
///
/// - [ShortcutConfigBean]
/// - [ShortcutLabelWidget] 快捷键标签小部件
class ShortcutConfigManager {
  /// 快捷键提示
  static String? shortcutTooltip(
    String? tip, {
    String? shortcutId,
    ShortcutConfigBean? shortcut,
    ShortcutConfigManager? shortcutConfigManager,
  }) {
    String? shortcutLabel;
    if (isDesktopOrWeb) {
      shortcut ??= (shortcutConfigManager ?? $globalShortcutConfigManager)
          .findShortcutConfig(id: shortcutId)
          .firstOrNull;
      shortcutLabel = shortcut?.getShortcutLabel();
      if (!isNil(shortcutLabel)) {
        tip ??= "";
        if (!isNil(tip)) {
          shortcutLabel = shortcutLabel?.wph.connect(null, " ");
        }
      }
    }
    return tip?.connect(shortcutLabel);
  }

  /// 快捷键意图映射
  final Map<String, ShortcutIntentBean> shortcutIntentMap = {};

  final Set<ShortcutIntentBean> shortcutIntentList = {};

  //--

  /// 快捷键配置映射
  final Map<String, ShortcutConfigBean> shortcutConfigMap = {};

  final Set<ShortcutConfigBean> shortcutConfigList = {};

  ShortcutConfigManager();

  //MARK: - register

  /// 注册一个快捷键意图
  @api
  void registerShortcutIntent(
    ShortcutIntentBean? shortcutIntentBean, {
    bool? isOverride,
  }) {
    if (shortcutIntentBean == null) {
      debugger();
      return;
    }
    if ((isOverride ?? false) != true) {
      if (shortcutIntentMap.containsKey(shortcutIntentBean.id)) {
        //debugger();
        return;
      }
    }
    shortcutIntentList.remove(shortcutIntentBean);
    shortcutIntentList.add(shortcutIntentBean);
    shortcutIntentMap[shortcutIntentBean.id] = shortcutIntentBean;
  }

  /// 查找对应的快捷键意图
  @api
  ShortcutIntentBean? findShortcutIntent(String? id) {
    return shortcutIntentMap[id];
  }

  /// 取消注册一个快捷键意图
  @api
  void unregisterShortcutIntent(ShortcutIntentBean? shortcutIntentBean) {
    if (shortcutIntentBean == null) {
      debugger();
      return;
    }
    shortcutIntentList.remove(shortcutIntentBean);
    shortcutIntentMap.remove(shortcutIntentBean.id);
  }

  /// 清除所有快捷键意图
  @api
  void clearShortcutIntent() {
    shortcutIntentList.clear();
    shortcutIntentMap.clear();
  }

  //-- config

  /// 注册一个快捷键配置
  /// - [isOverride] 是否覆盖已有的快捷键配置
  /// - [context] 用于通知主题(快捷键)变化
  ///   - [GlobalAppStateMixin]使用此混入刷新界面
  @api
  void registerShortcutConfig(
    ShortcutConfigBean? shortcutConfigBean, {
    bool? isOverride,
    //--
    BuildContext? context,
  }) {
    if (shortcutConfigBean == null || shortcutConfigBean.id == null) {
      debugger();
      return;
    }
    if ((isOverride ?? false) != true) {
      //非覆盖
      if (shortcutConfigMap.containsKey(shortcutConfigBean.id!)) {
        //debugger();
        return;
      }
      final list = findShortcutConfig(config: shortcutConfigBean);
      if (list.isNotEmpty) {
        for (final config in list) {
          if (config.hasTriggerKey) {
            assert(() {
              l.w("已存在相同的快捷键配置: $config <- $shortcutConfigBean");
              return true;
            }());
            debugger(when: shortcutConfigBean.allowExist != true);
          }
        }
      }
    }
    //--
    shortcutConfigList.remove(shortcutConfigBean);
    shortcutConfigList.add(shortcutConfigBean);
    shortcutConfigMap[shortcutConfigBean.id!] = shortcutConfigBean;
    if (isOverride == true && context != null) {
      final globalConfig = GlobalConfig.of(context);
      globalConfig.notifyThemeChanged();
    }
  }

  /// 注册一组快捷键配置
  @api
  void registerShortcutConfigs(
    Iterable<ShortcutConfigBean>? shortcutConfigBeans, {
    bool? isOverride,
  }) {
    if (shortcutConfigBeans == null) {
      debugger();
      return;
    }
    for (final shortcutConfigBean in shortcutConfigBeans) {
      registerShortcutConfig(shortcutConfigBean, isOverride: isOverride);
    }
  }

  /// 取消注册一个快捷键配置
  @api
  void unregisterShortcutConfig(ShortcutConfigBean? shortcutConfigBean) {
    if (shortcutConfigBean == null) {
      debugger();
      return;
    }
    shortcutConfigList.remove(shortcutConfigBean);
    shortcutConfigMap.remove(shortcutConfigBean.id);
  }

  /// 清除所有快捷键配置
  @api
  void clearShortcutConfig() {
    shortcutConfigList.clear();
    shortcutConfigMap.clear();
  }

  //MARK: - method

  /// 指定的[event]是否匹配了指定的[ShortcutIntentBean]
  /// - [intentId] 快捷键意图的id
  @api
  bool isShortcutMatchEvent(
    KeyEvent? event,
    String? intentId, {
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
  }) {
    final configList = findShortcutConfigByKeyEvent(
      event,
      control: control,
      alt: alt,
      shift: shift,
      meta: meta,
    );
    if (configList.isEmpty) {
      return false;
    }
    return configList.findFirst((e) => e.id == intentId) != null;
  }

  /// 当前按键是否匹配指定的[ShortcutConfigBean]快捷键配置
  @api
  bool isShortcutMatchConfig(KeyEvent? event, ShortcutConfigBean? config) {
    if (event == null) return false;
    final keyConfig = ShortcutConfigBean.fromKeyEvent(
      event,
      control: isCtrlPressed.trueOrNull,
      alt: isAltPressed.trueOrNull,
      shift: isShiftPressed.trueOrNull,
      meta: isMetaPressed.trueOrNull,
    );
    return keyConfig.isSameShortcut(config);
  }

  /// 通过按键查找快捷键配置
  /// - [event] 当前的键盘事件, 为null时, 表示匹配修饰符
  @api
  List<ShortcutConfigBean> findShortcutConfigByKeyEvent(
    KeyEvent? event, {
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
  }) {
    final List<ShortcutConfigBean> list = [];
    //用event查找
    final keyConfig = ShortcutConfigBean.fromKeyEvent(
      event,
      control: control ?? isCtrlPressed,
      alt: alt ?? isAltPressed,
      shift: shift ?? isShiftPressed,
      meta: meta ?? isMetaPressed,
    );
    list.addAll(findShortcutConfig(config: keyConfig));
    return list;
  }

  /// 查找匹配的快捷键配置
  @api
  List<ShortcutConfigBean> findShortcutConfig({
    String? id,
    ShortcutConfigBean? config,
  }) {
    if (id == null && config == null) {
      return [];
    }
    return shortcutConfigList.where((e) {
      if (id != null) {
        return e.id == id;
      }
      return e.isSameShortcut(config);
    }).toList();
  }

  //MARK: - action

  /// 通过[ShortcutIntentBean.id]触发一个快捷键执行动作
  @api
  KeyEventResult? triggerShortcutActionById(
    String? id, {
    BuildContext? context,
    Object? host,
    Object? data,
  }) {
    return triggerShortcutAction(
      id: id,
      context: context,
      host: host,
      data: data,
    );
  }

  /// 通过[KeyEvent]触发一个快捷键执行动作
  @api
  KeyEventResult? triggerShortcutActionByEvent(
    KeyEvent event, {
    BuildContext? context,
    Object? host,
    Object? data,
  }) {
    return triggerShortcutAction(
      event: event,
      context: context,
      host: host,
      data: data,
    );
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
    KeyEvent? event,
    //参数
    BuildContext? context,
    Object? host,
    Object? data,
  }) {
    if (id == null && event == null) {
      return null;
    }
    final List<ShortcutConfigBean> configList = [];
    if (id != null) {
      //用id查找
      configList.addAll(findShortcutConfig(id: id));
    } else if (event != null) {
      //用event查找
      final keyConfig = ShortcutConfigBean.fromKeyEvent(
        event,
        control: isCtrlPressed.trueOrNull,
        alt: isAltPressed.trueOrNull,
        shift: isShiftPressed.trueOrNull,
        meta: isMetaPressed.trueOrNull,
      );
      configList.addAll(findShortcutConfig(config: keyConfig));
    }
    //--action
    KeyEventResult? eventResult; //!event.isModifierKey
    for (final config in configList) {
      if (event != null) {
        //键盘事件
        if (event.isKeyDown) {
          if (config.byKeyDown == true) {
            //处理按键down
            if (event.isKeyRepeat) {
              //需要处理重复按键
              if (config.includeRepeats != true) {
                continue;
              }
            }
          } else if (config.byKeyUp == null) {
            //默认使用 key down
          } else {
            continue;
          }
        } else if (event.isKeyUp) {
          if (config.byKeyUp == true) {
            //处理按键up
          } else {
            continue;
          }
        }
      }
      //--处理action
      final intentId = config.id;
      final intent = shortcutIntentMap[intentId];
      final action = intent?.action;
      if (action != null) {
        //debugger(when: intentId == "canvas.paste.selected.element");
        final actionResult = action(context, event, host, data);
        assert(() {
          l.v("快捷键触发[${config.getShortcutLabel()}]($intentId)->$actionResult");
          return true;
        }());
        eventResult ??= actionResult;
        if (actionResult == .handled) {
          eventResult = actionResult;
        }
      }
    }
    return eventResult;
  }
}

/// 快捷键触发的回调
/// - [context] 布局上下文
/// - [event] 当前的键盘事件
/// - [host] 宿主对象, 比如当前所在的窗口/容器/可操作对象等
/// - [data] 调用传递的数据
typedef ShortcutIntentAction =
    KeyEventResult Function(
      BuildContext? context,
      KeyEvent? event,
      Object? host,
      Object? data,
    );

/// 快捷键/操作执行动作
/// - [ShortcutConfigBean] 快捷键配置
@immutable
class ShortcutIntentBean with Equatable, IProviderText {
  /// 快捷操作的唯一标识, 应该和[ShortcutConfigBean.id]对应上
  final String id;

  /// 快捷键显示的标签
  final String? label;

  /// 快捷键显示的标签国际化资源key / assets key
  final String? labelResKey;

  /// 快捷键执行的动作
  final ShortcutIntentAction? action;

  /// 是否在快捷键列表中不可见
  final bool? invisible;

  /// 可见
  bool get visible => !(invisible ?? false);

  const ShortcutIntentBean({
    required this.id,
    this.label,
    this.labelResKey,
    this.action,
    this.invisible,
  });

  @override
  String? provideIntlText(BuildContext context) {
    return labelResKey?.intlMessage(defMessage: label) ?? label;
  }

  @override
  List<Object?> get props => [id];
}

/// [ShortcutConfigManager]的实例
@globalInstance
final $globalShortcutConfigManager = ShortcutConfigManager();
