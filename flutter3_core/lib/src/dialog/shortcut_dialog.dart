part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/23
///
/// 用来显示全局快捷键的弹窗
/// - [KeyboardShortcutManager]
class KeyboardShortcutDialog extends StatefulWidget with DialogMixin {
  @override
  TranslationType get translationType => .scaleFade;

  /// 快捷键配置管理器
  @defInjectMark
  final ShortcutConfigManager? shortcutConfigManager;

  /// 指定要显示的快捷键描述列表
  @defInjectMark
  final List<ShortcutIntentBean>? shortcutIntentList;

  /// 通过此值, 用来关闭当前弹窗
  final ValueNotifier<bool>? closeDialogNotifier;

  const KeyboardShortcutDialog({
    super.key,
    this.shortcutConfigManager,
    this.shortcutIntentList,
    this.closeDialogNotifier,
  });

  @override
  State<KeyboardShortcutDialog> createState() => _KeyboardShortcutDialogState();
}

class _KeyboardShortcutDialogState
    extends RebuildByMediaSizeState<KeyboardShortcutDialog> {
  @override
  void initState() {
    widget.closeDialogNotifier?.addListener(_handleCloseDialog);
    super.initState();
  }

  @override
  void dispose() {
    widget.closeDialogNotifier?.addListener(_handleCloseDialog);
    super.dispose();
  }

  void _handleCloseDialog() {
    if (widget.closeDialogNotifier?.value == true) {
      buildContext?.popCurrentRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final libRes = context.libRes;
    final shortcutConfigManager =
        widget.shortcutConfigManager ?? $globalShortcutConfigManager;
    final shortcutIntentList =
        widget.shortcutIntentList ??
        shortcutConfigManager.shortcutIntentList.toList();

    return [
          (libRes?.libHotkeyList ?? "快捷键列表")
              .connect(" (${shortcutIntentList.length})")
              .text(textStyle: globalTheme.textTitleStyle, bold: true)
              .center()
              .insets(all: kX),
          [
            for (final shortcutIntent in shortcutIntentList)
              [
                    textOf(shortcutIntent)?.text().expanded(),
                    ShortcutLabelWidget(
                      configBean: shortcutConfigManager
                          .findShortcutConfig(id: shortcutIntent.id)
                          .firstOrNull,
                    ),
                  ]
                  .row()
                  ?.insets(h: kX, v: kX)
                  .ink(() {}, splashColor: Colors.transparent)
                  .material()
                  .rMasonryGridTile($bpGridItem(300)),
            if (isNil(shortcutIntentList))
              GlobalConfig.of(context)
                  .emptyPlaceholderBuilder(
                    context,
                    LibRes.of(context).libAdapterNoData.text().center(),
                  )
                  .insets(all: kXxx),
          ].rScroll().expanded(),
        ]
        .column()!
        .decoration(
          BoxDecoration(
            color: globalTheme.themeWhiteColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(kDefaultBorderRadiusXX),
            /*boxShadow: [kBoxShadow],*/
          ),
        )
        .blur()
        .insets(all: 40)
        .material();
  }
}

/// 用来触发[KeyboardShortcutManager]对应的[KeyboardShortcutDialog]
class GlobalShortcutTriggerWidget extends StatefulWidget {
  final Widget child;

  /// 自身的触发器
  @defInjectMark
  final ShortcutActivator? activator;

  /// 延迟多久显示
  @configProperty
  final Duration delay;

  const GlobalShortcutTriggerWidget({
    super.key,
    required this.child,
    this.activator,
    this.delay = const Duration(milliseconds: 2000),
  });

  @override
  State<GlobalShortcutTriggerWidget> createState() =>
      _GlobalShortcutTriggerWidgetState();
}

class _GlobalShortcutTriggerWidgetState
    extends State<GlobalShortcutTriggerWidget> {
  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(onHandleKeyEventMixin);
    super.initState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(onHandleKeyEventMixin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @output
  bool get _isShowing => _closeDialogNotifier != null;

  @output
  LogicalKeyboardKey? _showingLogicalKey;

  @output
  ValueNotifier<bool>? _closeDialogNotifier;

  @output
  Timer? _timer;

  @callPoint
  @overridePoint
  bool onHandleKeyEventMixin(KeyEvent event) {
    //debugger();
    /*assert(() {
      l.w("event->$event");
      return true;
    }());*/
    final key = event.logicalKey;
    if (event.isKeyUp) {
      if (_isShowing && _showingLogicalKey == key) {
        //_isShowing = false;
        //通知关闭弹窗
        _closeDialogNotifier?.value = true;
        _closeDialogNotifier = null;
        _timer?.cancel();
        return true;
      }
    } else if (widget.activator?.accepts(event, HardwareKeyboard.instance) ==
            true ||
        (event.isKeyDown &&
            (key == LogicalKeyboardKey.metaLeft ||
                key == LogicalKeyboardKey.metaRight))) {
      //触发
      _showingLogicalKey = key;
      _closeDialogNotifier = ValueNotifier(false);

      //延迟显示
      _timer?.cancel();
      _timer = timerDelay(widget.delay, () {
        if (_isShowing && $isAppResumed) {
          buildContext?.showWidgetDialog(
            KeyboardShortcutDialog(
              /*shortcutDescriptions: $globalShortcutManager.shortcutDescriptions,*/
              closeDialogNotifier: _closeDialogNotifier,
            ),
          );
        }
      });

      return true;
    } else if (event.isKeyDown) {
      //按下其它按键
      _timer?.cancel();
    }
    return false;
  }
}

/// 自动显示[KeyboardShortcutDialog]全局快捷键列表对话框
/// - [KeyboardShortcutManager]
/// - [GlobalShortcutTriggerWidget]
extension GlobalShortcutTriggerWidgetEx on Widget {
  /// 添加全局快捷键触发器
  Widget wrapGlobalShortcutTrigger() {
    return GlobalShortcutTriggerWidget(child: this);
  }
}
