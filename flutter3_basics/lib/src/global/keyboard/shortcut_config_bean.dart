part of '../../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 快捷键配置数据结构
/// - 支持持久化
///
/// # 快捷键修饰符号
///
/// - macOS : `⌘ ⌥ ⇧ ⌃`
/// - Windows / Linux : `Ctrl Alt Shift Win`
///
///  - 回车符号 `⏎`
///  - 退格符号 `⌫`
/// - ↵ ← → ↑ ↓
///
/// ```
/// _LocalizedShortcutLabeler.instance.getShortcutLabel(
///    shortcut!,
///    MaterialLocalizations.of(context),
///  )
/// ```
///
/// - [KeyboardShortcutManager]
/// - [ShortcutDescription]
/// - [ShortcutConfigBean]
///
/// - [KeyEventMixin]
/// - [KeyEventStateMixin]
@immutable
class ShortcutConfigBean with Equatable, IProviderText {
  /// 快捷键的唯一标识，如 "save_document"
  final String? id;

  /// 是否是默认的
  final bool? isDefault;

  //--

  /// 主按键，如 keyS
  /// - 0x00000000030
  /// - 0x00000000061
  /// - 0x00200000230
  /// - 0x002000001f4
  final int? keyId;

  /// [keyId] 或者 以下的任意按键
  final List<int>? keyIdList;

  //--

  /// [isCtrlPressed]
  final bool? control;

  /// [isAltPressed]
  final bool? alt;

  /// [isShiftPressed]
  final bool? shift;

  /// macOS 下的 Command 键
  /// - macOS:
  /// - Windows:
  /// [isMetaPressed]
  final bool? meta;

  //--

  /// 是否在[KeyDownEvent]时触发
  /// - [KeyDownEvent]
  final bool? byKeyDown;

  /// 是否包含重复触发
  /// - [KeyRepeatEvent]
  final bool? includeRepeats;

  /// 是否在[KeyUpEvent]时触发
  final bool? byKeyUp;

  //MARK: - get

  /// 是否有修饰键
  bool get hasModifier =>
      control == true || alt == true || shift == true || meta == true;

  /// 是否仅是修饰键
  bool get isModifierOnly => keyId == null && hasModifier;

  /// 是否是有效的快捷键配置
  bool get isValid =>
      keyId != null ||
      control == true ||
      alt == true ||
      shift == true ||
      meta == true;

  /// 触发的非修饰按键
  LogicalKeyboardKey? get triggerKey => keyId?.logicalKeyboardKey;

  /// 是否有触发按键, 并且是非修饰键
  bool get hasTriggerKey => triggerKey != null && !triggerKey!.isModifier;

  ShortcutConfigBean({
    this.id,
    this.keyIdList,
    this.isDefault,
    int? keyId,
    LogicalKeyboardKey? key,
    this.control,
    this.alt,
    this.shift,
    this.meta,
    this.byKeyDown,
    this.byKeyUp,
    this.includeRepeats,
  }) : keyId = key?.keyId ?? keyId;

  /// copyWith
  ShortcutConfigBean copyWith({
    String? id,
    List<int>? keyIdList,
    bool? isDefault,
    int? keyId,
    LogicalKeyboardKey? key,
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
    bool? byKeyDown,
    bool? byKeyUp,
    bool? includeRepeats,
  }) => ShortcutConfigBean(
    id: id ?? this.id,
    keyIdList: keyIdList ?? this.keyIdList,
    isDefault: isDefault ?? this.isDefault,
    keyId: keyId ?? this.keyId,
    key: key,
    control: control ?? this.control,
    alt: alt ?? this.alt,
    shift: shift ?? this.shift,
    meta: meta ?? this.meta,
    byKeyDown: byKeyDown ?? this.byKeyDown,
    byKeyUp: byKeyUp ?? this.byKeyUp,
    includeRepeats: includeRepeats ?? this.includeRepeats,
  );

  /// 序列化为 JSON 保存
  Map<String, dynamic> toJson() => {
    'id': ?id,
    'isDefault': ?isDefault?.trueOrNull,
    'keyId': ?keyId,
    'keyIdList': ?keyIdList,
    'control': ?control?.trueOrNull,
    'alt': ?alt?.trueOrNull,
    'shift': ?shift?.trueOrNull,
    'meta': ?meta?.trueOrNull,
    'byKeyDown': ?byKeyDown?.trueOrNull,
    'byKeyUp': ?byKeyUp?.trueOrNull,
    'includeRepeats': ?includeRepeats?.trueOrNull,
  };

  /// 反序列化
  factory ShortcutConfigBean.fromJson(Map<String, dynamic> json) {
    return ShortcutConfigBean(
      id: json['id'],
      keyIdList: (json['keyIdList'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      isDefault: json['isDefault'],
      keyId: json['keyId'],
      control: json['control'],
      alt: json['alt'],
      shift: json['shift'],
      meta: json['meta'],
      byKeyUp: json['byKeyUp'],
      byKeyDown: json['byKeyDown'],
      includeRepeats: json['includeRepeats'],
    );
  }

  /// 快捷键 esc
  factory ShortcutConfigBean.escape() =>
      ShortcutConfigBean.fromKey(LogicalKeyboardKey.escape);

  /// 快捷键 enter
  factory ShortcutConfigBean.enter() =>
      ShortcutConfigBean.fromKey(LogicalKeyboardKey.enter);

  /// 快捷键 backspace
  factory ShortcutConfigBean.backspace() =>
      ShortcutConfigBean.fromKey(LogicalKeyboardKey.backspace);

  /// - [modifier] 是否过滤掉修饰符的[key]
  ///   - 修饰键, 不使用 [keyId]
  factory ShortcutConfigBean.fromKeyEvent(
    KeyEvent? event, {
    String? id,
    List<int>? keyIdList,
    bool? isDefault,
    bool modifier = true,
    //--
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
    //--
    bool? byKeyDown,
    bool? byKeyUp,
    bool? includeRepeats,
  }) => ShortcutConfigBean.fromKey(
    event?.logicalKey,
    id: id,
    keyIdList: keyIdList,
    isDefault: isDefault,
    modifier: modifier,
    control: control,
    alt: alt,
    shift: shift,
    meta: meta,
    byKeyDown: byKeyDown,
    byKeyUp: byKeyUp,
    includeRepeats: includeRepeats,
  );

  /// - [modifier] 是否过滤掉修饰符的[key]
  ///   - 修饰键, 不使用 [keyId]
  factory ShortcutConfigBean.fromKey(
    LogicalKeyboardKey? key, {
    String? id,
    List<int>? keyIdList,
    bool? isDefault,
    bool modifier = true,
    //--
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
    //--
    bool? byKeyDown,
    bool? byKeyUp,
    bool? includeRepeats,
  }) {
    return ShortcutConfigBean(
      id: id,
      keyIdList: keyIdList,
      isDefault: isDefault,
      keyId: modifier && key?.isModifier == true ? null : key?.keyId,
      control: modifier && (control == true || key?.isControlKey == true),
      alt: modifier && (alt == true || key?.isAltKey == true),
      shift: modifier && (shift == true || key?.isShiftKey == true),
      meta: modifier && (meta == true || key?.isMetaKey == true),
      byKeyDown: byKeyDown,
      byKeyUp: byKeyUp,
      includeRepeats: includeRepeats,
    );
  }

  //MARK: - api

  /// 仅判断快捷键是否相同
  @api
  bool isSameShortcut(ShortcutConfigBean? other) {
    return (keyId == other?.keyId ||
            keyIdList?.contains(other?.keyId) == true) &&
        isBoolEqual(control, other?.control) &&
        isBoolEqual(alt, other?.alt) &&
        isBoolEqual(shift, other?.shift) &&
        isBoolEqual(meta, other?.meta);
  }

  /// 转换为 Flutter 官方的 SingleActivator
  @api
  SingleActivator toSingleActivator() {
    return SingleActivator(
      triggerKey!,
      control: control == true,
      alt: alt == true,
      shift: shift == true,
      meta: meta == true,
      includeRepeats: includeRepeats == true,
    );
  }

  /// 获取快捷键的标签
  /// [_LocalizedShortcutLabeler.getShortcutLabel]
  ///
  /// https://resources.jetbrains.com/storage/products/intellij-idea/docs/IntelliJIDEA_ReferenceCard.pdf
  @api
  String getShortcutLabel() {
    if (!isValid) {
      return '';
    }
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    final List<String> parts = [];
    if (isMac) {
      if (meta == true) parts.add('⌘'); //⊞
      if (control == true) parts.add('⌃');
      if (alt == true) parts.add('⌥');
      if (shift == true) parts.add('⇧');
      if (triggerKey != null) {
        parts.add(triggerKey!.formatKeyLabel);
      }
      return parts.join(''); // macOS 风格：⌘⇧S
    } else {
      if (meta == true) parts.add('Win');
      if (control == true) parts.add('Ctrl');
      if (alt == true) parts.add('Alt');
      if (shift == true) parts.add('Shift');
      if (triggerKey != null) {
        parts.add(triggerKey!.formatKeyLabel);
      }
      return parts.join(' + '); // Windows/Linux 风格：Ctrl + Shift + S
    }
  }

  @override
  String toString() => getShortcutLabel().connect(id?.wph);

  /// 快捷键相同即可认为相同
  @override
  List<Object?> get props =>
      id == null ? [keyId, control, alt, shift, meta] : [id];
}

extension LogicalKeyboardKeyLabelEx on LogicalKeyboardKey {
  String get formatKeyLabel {
    // 处理特殊按键Label展示
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    if (this == .space) return isMac ? '␣' : 'Space';
    if (this == .escape) return isMac ? '⎋' : 'Esc';
    /*if (this == .numpadEnter) return isMac ? '⌤' : 'Enter';*/
    if (this == .tab) return isMac ? '⇥' : 'Tab';
    if (this == .capsLock) return '⇪';
    if (this == .delete) return isMac ? '⌦' : 'Delete';
    if (this == .backspace) return isMac ? '⌫' : 'Backspace'; // ⌘⇧⌨
    if (this == .enter) return isMac ? '↩' : 'Enter';
    if (this == .home) return isMac ? '↖' : 'Home';
    if (this == .end) return isMac ? '↘' : 'End';
    if (this == .pageUp) return isMac ? '⇞' : 'Page Up';
    if (this == .pageDown) return isMac ? '⇟' : 'Page Down';
    if (this == .arrowLeft) return isDesktopOrWeb ? '←' : 'Left';
    if (this == .arrowRight) return isDesktopOrWeb ? '→' : 'Right';
    if (this == .arrowUp) return isDesktopOrWeb ? '↑' : 'Up';
    if (this == .arrowDown) return isDesktopOrWeb ? '↓' : 'Down';
    /*if (this == .bracketLeft) return '[';
    if (this == .bracketRight) return ']';
    if (this == .comma) return ',';
    if (this == .period) return '.';
    if (this == .slash) return '/';*/
    return keyLabel.toUpperCase();
  }
}
