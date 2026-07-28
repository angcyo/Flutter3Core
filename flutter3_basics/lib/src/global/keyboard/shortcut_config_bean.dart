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
/// - [GlobalShortcutManager]
/// - [ShortcutDescription]
/// - [ShortcutConfigBean]
///
/// - [KeyEventMixin]
/// - [KeyEventStateMixin]
@immutable
class ShortcutConfigBean with Equatable {
  /// 快捷键的唯一标识，如 "save_document"
  final String? id;

  /// 主按键，如 keyS
  final int? keyId;
  final bool? control;
  final bool? alt;
  final bool? shift;

  /// macOS 下的 Command 键
  /// - macOS:
  /// - Windows:
  final bool? meta;

  //MARK: - get

  /// 触发的按键
  LogicalKeyboardKey? get triggerKey =>
      keyId == null ? null : LogicalKeyboardKey.findKeyByKeyId(keyId!);

  /// 是否有触发按键, 并且是非修饰键
  bool get hasTriggerKey => triggerKey != null && !triggerKey!.isModifier;

  ShortcutConfigBean({
    this.id,
    this.keyId,
    this.control,
    this.alt,
    this.shift,
    this.meta,
  });

  /// 序列化为 JSON 保存
  Map<String, dynamic> toJson() => {
    'id': id,
    'keyId': keyId,
    'control': control,
    'alt': alt,
    'shift': shift,
    'meta': meta,
  };

  /// 反序列化
  factory ShortcutConfigBean.fromJson(Map<String, dynamic> json) {
    return ShortcutConfigBean(
      id: json['id'],
      keyId: json['keyId'],
      control: json['control'],
      alt: json['alt'],
      shift: json['shift'],
      meta: json['meta'],
    );
  }

  factory ShortcutConfigBean.fromKeyEvent(
    KeyEvent? event, {
    String? id,
    bool modifier = true,
  }) {
    return ShortcutConfigBean(
      id: id,
      keyId: modifier && event?.logicalKey.isModifier == true
          ? null
          : event?.logicalKey.keyId,
      control: modifier && isCtrlPressed,
      alt: modifier && isAltPressed,
      shift: modifier && isShiftPressed,
      meta: modifier && isMetaPressed,
    );
  }

  //MARK: - api

  /// 转换为 Flutter 官方的 SingleActivator
  @api
  SingleActivator toSingleActivator() {
    return SingleActivator(
      triggerKey!,
      control: control == true,
      alt: alt == true,
      shift: shift == true,
      meta: meta == true,
    );
  }

  /// 获取快捷键的标签
  /// [_LocalizedShortcutLabeler.getShortcutLabel]
  ///
  /// https://resources.jetbrains.com/storage/products/intellij-idea/docs/IntelliJIDEA_ReferenceCard.pdf
  @api
  String getShortcutLabel() {
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    final List<String> parts = [];
    if (isMac) {
      if (control == true) parts.add('⌃');
      if (alt == true) parts.add('⌥');
      if (shift == true) parts.add('⇧');
      if (meta == true) parts.add('⌘'); //⊞
      if (triggerKey != null) {
        parts.add(triggerKey!.formatKeyLabel);
      }
      return parts.join(''); // macOS 风格：⌘⇧S
    } else {
      if (control == true) parts.add('Ctrl');
      if (alt == true) parts.add('Alt');
      if (shift == true) parts.add('Shift');
      if (meta == true) parts.add('Win');
      if (triggerKey != null) {
        parts.add(triggerKey!.formatKeyLabel);
      }
      return parts.join(' + '); // Windows/Linux 风格：Ctrl + Shift + S
    }
  }

  @override
  String toString() => getShortcutLabel();

  /// 快捷键相同即可认为相同
  @override
  List<Object?> get props => [keyId, control, alt, shift, meta];
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
    if (this == .arrowLeft) return isMac ? '←' : 'Left';
    if (this == .arrowRight) return isMac ? '→' : 'Left';
    if (this == .arrowUp) return isMac ? '↑' : 'Up';
    if (this == .arrowDown) return isMac ? '↓' : 'Down';
    /*if (this == .bracketLeft) return '[';
    if (this == .bracketRight) return ']';
    if (this == .comma) return ',';
    if (this == .period) return '.';
    if (this == .slash) return '/';*/
    return keyLabel.toUpperCase();
  }
}
