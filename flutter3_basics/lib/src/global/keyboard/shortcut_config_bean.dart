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
/// - [ShortcutManager]
/// - [ShortcutDescription]
/// - [ShortcutConfigBean]
///
/// - [KeyEventMixin]
/// - [KeyEventStateMixin]
@immutable
class ShortcutConfigBean with Equatable, IProviderText {
  /// 快捷键的唯一标识，如 "save_document"
  final String? id;

  /// 快捷键显示的标签国际化资源key / assets key
  final String? labelAssetsKey;

  //--

  /// 主按键，如 keyS
  final int? keyId;
  final bool? control;
  final bool? alt;
  final bool? shift;

  /// macOS 下的 Command 键
  /// - macOS:
  /// - Windows:
  final bool? meta;

  //--

  /// 是否只在key down时触发
  /// - [KeyDownEvent]
  final bool? byKeyDown;

  /// 是否包含重复触发
  /// - [KeyRepeatEvent]
  final bool? includeRepeats;

  //MARK: - get

  /// 是否有效
  bool get isValid =>
      keyId != null ||
      control == true ||
      alt == true ||
      shift == true ||
      meta == true;

  /// 触发的按键
  LogicalKeyboardKey? get triggerKey =>
      keyId == null ? null : LogicalKeyboardKey.findKeyByKeyId(keyId!);

  /// 是否有触发按键, 并且是非修饰键
  bool get hasTriggerKey => triggerKey != null && !triggerKey!.isModifier;

  ShortcutConfigBean({
    this.id,
    this.labelAssetsKey,
    int? keyId,
    LogicalKeyboardKey? key,
    this.control,
    this.alt,
    this.shift,
    this.meta,
    this.byKeyDown,
    this.includeRepeats,
  }) : keyId = key?.keyId ?? keyId;

  /// 序列化为 JSON 保存
  Map<String, dynamic> toJson() => {
    'id': id,
    'labelAssetsKey': labelAssetsKey,
    'keyId': keyId,
    'control': control,
    'alt': alt,
    'shift': shift,
    'meta': meta,
    'byKeyDown': byKeyDown,
    'includeRepeats': includeRepeats,
  };

  /// 反序列化
  factory ShortcutConfigBean.fromJson(Map<String, dynamic> json) {
    return ShortcutConfigBean(
      id: json['id'],
      labelAssetsKey: json['labelAssetsKey'],
      keyId: json['keyId'],
      control: json['control'],
      alt: json['alt'],
      shift: json['shift'],
      meta: json['meta'],
      byKeyDown: json['byKeyDown'],
      includeRepeats: json['includeRepeats'],
    );
  }

  factory ShortcutConfigBean.fromKeyEvent(
    KeyEvent? event, {
    String? id,
    String? labelAssetsKey,
    bool modifier = true,
    //--
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
    //--
    bool? byKeyDown,
    bool? includeRepeats,
  }) => ShortcutConfigBean.fromKey(
    event?.logicalKey,
    id: id,
    labelAssetsKey: labelAssetsKey,
    modifier: modifier,
    control: control,
    alt: alt,
    shift: shift,
    meta: meta,
    byKeyDown: byKeyDown,
    includeRepeats: includeRepeats,
  );

  /// - [modifier] 是否过滤掉修饰符的[key]
  factory ShortcutConfigBean.fromKey(
    LogicalKeyboardKey? key, {
    String? id,
    String? labelAssetsKey,
    bool modifier = true,
    //--
    bool? control,
    bool? alt,
    bool? shift,
    bool? meta,
    //--
    bool? byKeyDown,
    bool? includeRepeats,
  }) {
    return ShortcutConfigBean(
      id: id,
      labelAssetsKey: labelAssetsKey,
      keyId: modifier && key?.isModifier == true ? null : key?.keyId,
      control: modifier && (control == true || key?.isControlKey == true),
      alt: modifier && (alt == true || key?.isAltKey == true),
      shift: modifier && (shift == true || key?.isShiftKey == true),
      meta: modifier && (meta == true || key?.isMetaKey == true),
      byKeyDown: byKeyDown,
      includeRepeats: includeRepeats,
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
      includeRepeats: includeRepeats == true,
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
  String? provideIntlText(BuildContext context) {
    return labelAssetsKey?.intlMessage();
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
