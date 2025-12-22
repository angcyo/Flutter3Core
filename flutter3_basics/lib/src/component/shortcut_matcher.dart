part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/22
///
/// 模仿系统的[ShortcutManager], 实现的快捷键匹配处理
/// - [ShortcutActivator] 快捷键触发器
/// - [ShortcutIntent] 快捷键意图
///
/// - [ShortcutMatcher.handleKeypress]调用此方法匹配快捷键
class ShortcutMatcher with Diagnosticable, ChangeNotifier {
  ShortcutMatcher({
    Map<ShortcutActivator, Intent>? shortcuts,
    this.modal = false,
    this.onHandleKeypress,
  }) : _shortcuts = shortcuts ?? {} {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  /// 顶层处理方法
  @configProperty
  final KeyEventResult Function(
    BuildContext? context,
    KeyEvent event,
    dynamic data,
  )?
  onHandleKeypress;

  //MARK: - api

  /// 清空快捷键
  @api
  void clearShortcuts() {
    _shortcuts.clear();
    _indexedShortcutsCache = null;
    notifyListeners();
  }

  /// 添加一个快捷键
  /// - [ShortcutActivator]
  ///   - [SingleActivator]
  ///   - [CharacterActivator]
  ///
  /// - [addShortcut]
  /// - [addSingleShortcut]
  /// - [addCharacterShortcut]
  @api
  void addShortcut(
    ShortcutActivator activator,
    KeyEventResult Function(dynamic data)? action, {
    String? tag,
  }) {
    _shortcuts[activator] = ShortcutIntent(action, tag: tag);
    _indexedShortcutsCache = null;
    notifyListeners();
  }

  /// 添加一个简单的快捷键
  /// - [addShortcut]
  /// - [addSingleShortcut]
  /// - [addCharacterShortcut]
  @api
  void addSingleShortcut(
    LogicalKeyboardKey trigger,
    KeyEventResult Function(dynamic data)? action, {
    String? tag,
    //--
    bool meta = false,
    bool control = false,
    bool shift = false,
    bool alt = false,
    LockState numLock = LockState.ignored,
    bool includeRepeats = true,
  }) {
    addShortcut(
      SingleActivator(
        trigger,
        meta: meta,
        control: control,
        shift: shift,
        alt: alt,
        numLock: numLock,
        includeRepeats: includeRepeats,
      ),
      action,
      tag: tag,
    );
  }

  /// 添加一个简单的快捷键
  /// - [addShortcut]
  /// - [addSingleShortcut]
  /// - [addCharacterShortcut]
  @api
  void addCharacterShortcut(
    String character,
    KeyEventResult Function(dynamic data)? action, {
    String? tag,
    //--
    bool meta = false,
    bool control = false,
    bool alt = false,
    bool includeRepeats = true,
  }) {
    addShortcut(
      CharacterActivator(
        character,
        meta: meta,
        control: control,
        alt: alt,
        includeRepeats: includeRepeats,
      ),
      action,
      tag: tag,
    );
  }

  /// 通过tag查找快捷键
  @api
  ShortcutActivator? findShortcutByTag(String? tag) {
    for (final entry in _indexedShortcuts.entries) {
      for (final pair in entry.value) {
        final intent = pair.intent;
        if (intent is ShortcutIntent && intent.tag == tag) {
          return pair.activator;
        }
      }
    }
    return null;
  }

  /// 匹配快捷键
  /// - [data] 传递的数据
  @api
  KeyEventResult handleKeypress(
    BuildContext? context,
    KeyEvent event,
    dynamic data,
  ) {
    //-
    if (onHandleKeypress?.call(context, event, data) == .handled) {
      return .handled;
    }

    //-
    // Marking some variables as "late" ensures that they aren't evaluated unless needed.
    late final Intent? intent = _find(event, HardwareKeyboard.instance);
    if (intent is ShortcutIntent && intent.action != null) {
      return intent.action!.call(data);
    }

    //MARK: - system
    context ??= primaryFocus?.context;
    if (intent != null && context != null) {
      final action = Actions.maybeFind<Intent>(context, intent: intent);
      if (action != null) {
        final (bool enabled, Object? invokeResult) = Actions.of(
          context,
        ).invokeActionIfEnabled(action, intent, context);
        if (enabled) {
          return action.toKeyEventResult(intent, invokeResult);
        }
      }
    }
    return modal
        ? KeyEventResult.skipRemainingHandlers
        : KeyEventResult.ignored;
  }

  //MARK: - core

  final bool modal;

  Map<ShortcutActivator, Intent> get shortcuts => _shortcuts;
  Map<ShortcutActivator, Intent> _shortcuts = <ShortcutActivator, Intent>{};

  set shortcuts(Map<ShortcutActivator, Intent> value) {
    if (!mapEquals<ShortcutActivator, Intent>(_shortcuts, value)) {
      _shortcuts = value;
      _indexedShortcutsCache = null;
      notifyListeners();
    }
  }

  static Map<LogicalKeyboardKey?, List<_ActivatorIntentPair>> _indexShortcuts(
    Map<ShortcutActivator, Intent> source,
  ) {
    final Map<LogicalKeyboardKey?, List<_ActivatorIntentPair>> result =
        <LogicalKeyboardKey?, List<_ActivatorIntentPair>>{};
    source.forEach((ShortcutActivator activator, Intent intent) {
      // This intermediate variable is necessary to comply with Dart analyzer.
      final Iterable<LogicalKeyboardKey?>? nullableTriggers =
          activator.triggers;
      for (final LogicalKeyboardKey? trigger
          in nullableTriggers ?? <LogicalKeyboardKey?>[null]) {
        result
            .putIfAbsent(trigger, () => <_ActivatorIntentPair>[])
            .add(_ActivatorIntentPair(activator, intent));
      }
    });
    return result;
  }

  Map<LogicalKeyboardKey?, List<_ActivatorIntentPair>> get _indexedShortcuts {
    return _indexedShortcutsCache ??= _indexShortcuts(shortcuts);
  }

  Map<LogicalKeyboardKey?, List<_ActivatorIntentPair>>? _indexedShortcutsCache;

  Iterable<_ActivatorIntentPair> _getCandidates(LogicalKeyboardKey key) {
    return <_ActivatorIntentPair>[
      ..._indexedShortcuts[key] ?? <_ActivatorIntentPair>[],
      ..._indexedShortcuts[null] ?? <_ActivatorIntentPair>[],
    ];
  }

  /// Returns the [Intent], if any, that matches the current set of pressed
  /// keys.
  ///
  /// Returns null if no intent matches the current set of pressed keys.
  Intent? _find(KeyEvent event, HardwareKeyboard state) {
    for (final _ActivatorIntentPair activatorIntent in _getCandidates(
      event.logicalKey,
    )) {
      if (activatorIntent.activator.accepts(event, state)) {
        return activatorIntent.intent;
      }
    }
    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Map<ShortcutActivator, Intent>>(
        'shortcuts',
        shortcuts,
      ),
    );
    properties.add(
      FlagProperty('modal', value: modal, ifTrue: 'modal', defaultValue: false),
    );
  }
}

class _ActivatorIntentPair with Diagnosticable {
  const _ActivatorIntentPair(this.activator, this.intent);

  final ShortcutActivator activator;
  final Intent intent;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<String>('activator', activator.debugDescribeKeys()),
    );
    properties.add(DiagnosticsProperty<Intent>('intent', intent));
  }
}

/// 快捷键触发的意图
class ShortcutIntent extends Intent {
  /// 标记
  final String? tag;

  /// [data] 传递的数据
  final KeyEventResult Function(dynamic data)? action;

  const ShortcutIntent(this.action, {this.tag});
}

/// 快捷键可视化小部件
/// - [ShortcutActivator]
class ShortcutHint extends StatelessWidget {
  final ShortcutActivator activator;
  final TextStyle? style;

  /// 是否强制使用windows样式
  final bool? winStyle;

  const ShortcutHint({
    super.key,
    required this.activator,
    this.style,
    this.winStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isMac = winStyle == true
        ? false
        : Theme.of(context).platform == TargetPlatform.macOS;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMac) _buildMacStyle(activator) else _buildWinStyle(activator),
      ],
    );
  }

  /// macOS 风格：精致的符号连写
  Widget _buildMacStyle(ShortcutActivator activator) {
    String symbols = '';

    final style =
        this.style ??
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 13);
    if (activator is SingleActivator) {
      if (activator.control) symbols += '⌃';
      if (activator.alt) symbols += '⌥';
      if (activator.shift) symbols += '⇧'; //capsLock ⇪
      if (activator.meta) symbols += '⌘';

      return Text(
        '$symbols${_getReadableKey(key: activator.trigger)}',
        style: style,
      );
    } else if (activator is CharacterActivator) {
      if (activator.control) symbols += '⌃';
      if (activator.alt) symbols += '⌥';
      if (activator.meta) symbols += '⌘';

      return Text(
        '$symbols${_getReadableKey(character: activator.character)}',
        style: style,
      );
    }

    return empty;
  }

  /// Windows/Linux 风格：KBD 按键块
  Widget _buildWinStyle(ShortcutActivator activator) {
    List<String> keys = [];

    if (activator is SingleActivator) {
      if (activator.control) keys.add('Ctrl');
      if (activator.alt) keys.add('Alt');
      if (activator.shift) keys.add('Shift');
      if (activator.meta) keys.add('Win');
      keys.add(_getReadableKey(key: activator.trigger));
    } else if (activator is CharacterActivator) {
      if (activator.control) keys.add('Ctrl');
      if (activator.alt) keys.add('Alt');
      if (activator.meta) keys.add('Win');
      keys.add(_getReadableKey(character: activator.character));
    }

    return Wrap(
      spacing: 4,
      children: keys.map((key) => _buildKeyCap(key)).toList(),
    );
  }

  /// 渲染类似键盘按键的边框
  Widget _buildKeyCap(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style:
            style ??
            const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
      ),
    );
  }

  String _getReadableKey({LogicalKeyboardKey? key, String? character}) {
    // 处理一些特殊的逻辑键显示
    if (key == LogicalKeyboardKey.arrowUp ||
        character == LogicalKeyboardKey.arrowUp.keyLabel) {
      return '↑';
    }
    if (key == LogicalKeyboardKey.arrowDown ||
        character == LogicalKeyboardKey.arrowDown.keyLabel) {
      return '↓';
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        character == LogicalKeyboardKey.arrowLeft.keyLabel) {
      return '←';
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        character == LogicalKeyboardKey.arrowRight.keyLabel) {
      return '→';
    }
    if (key == LogicalKeyboardKey.enter ||
        character == LogicalKeyboardKey.enter.keyLabel) {
      return '⏎';
    }
    if (key == LogicalKeyboardKey.escape ||
        character == LogicalKeyboardKey.escape.keyLabel) {
      return '⎋'; //'Esc'
    }
    if (key == LogicalKeyboardKey.delete ||
        character == LogicalKeyboardKey.delete.keyLabel) {
      return '⌦'; //'Del'
    }
    if (key == LogicalKeyboardKey.backspace ||
        character == LogicalKeyboardKey.backspace.keyLabel) {
      return '⌫'; //'Backspace'
    }
    if (key == LogicalKeyboardKey.space ||
        character == LogicalKeyboardKey.space.keyLabel) {
      return '␣';
    }
    if (key == LogicalKeyboardKey.tab ||
        character == LogicalKeyboardKey.tab.keyLabel) {
      return '⇥';
    }
    if (key == LogicalKeyboardKey.pageDown ||
        character == LogicalKeyboardKey.pageDown.keyLabel) {
      return '⇟';
    }
    if (key == LogicalKeyboardKey.pageUp ||
        character == LogicalKeyboardKey.pageUp.keyLabel) {
      return '⇞';
    }
    // ... 其他映射
    return character ?? key?.keyLabel.toUpperCase() ?? "";
  }
}
