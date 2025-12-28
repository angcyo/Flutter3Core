part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/23
///
/// 用来显示全局快捷键的弹窗
/// - [GlobalShortcutManager]
class ShortcutDialog extends StatefulWidget with DialogMixin {
  @override
  TranslationType get translationType => .scaleFade;

  final List<ShortcutDescription> shortcutDescriptions;

  /// 通过此值, 用来关闭当前弹窗
  final ValueNotifier<bool>? closeDialogNotifier;

  const ShortcutDialog({
    super.key,
    required this.shortcutDescriptions,
    this.closeDialogNotifier,
  });

  @override
  State<ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<ShortcutDialog> {
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
    final shortcutDescriptions = widget.shortcutDescriptions;
    return widget.buildAdaptiveCenterDialog(
      context,
      [
        "快捷键列表"
            .text(textStyle: globalTheme.textTitleStyle, bold: true)
            .insets(all: kX),
        for (final description in shortcutDescriptions)
          [
            (description.builderLabel?.call(context) ??
                    description.label?.text(
                      textStyle: globalTheme.textDesStyle,
                    ))
                ?.expanded(),
            description.builderHint?.call(context) ??
                ShortcutHint(activator: description.activator),
          ].row()?.insets(h: kX, v: kH),
        if (isNil(shortcutDescriptions))
          GlobalConfig.of(context)
              .emptyPlaceholderBuilder(
                context,
                LibRes.of(context).libAdapterNoData.text().center(),
              )
              .insets(all: kXxx),
      ].scrollVertical()!,
    );
  }
}

/// 用来触发[GlobalShortcutManager]对应的[ShortcutDialog]
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
    if (event.isKeyUp) {
      if (_isShowing && _showingLogicalKey == event.logicalKey) {
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
            (event.logicalKey == LogicalKeyboardKey.metaLeft ||
                event.logicalKey == LogicalKeyboardKey.metaRight))) {
      //触发
      _showingLogicalKey = event.logicalKey;
      _closeDialogNotifier = ValueNotifier(false);

      //延迟显示
      _timer?.cancel();
      _timer = timerDelay(widget.delay, () {
        if (_isShowing && $isAppResumed) {
          buildContext?.showWidgetDialog(
            ShortcutDialog(
              shortcutDescriptions: $globalShortcutManager.shortcutDescriptions,
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

/// 自动显示[ShortcutDialog]全局快捷键列表对话框
/// - [GlobalShortcutManager]
/// - [GlobalShortcutTriggerWidget]
extension GlobalShortcutTriggerWidgetEx on Widget {
  /// 添加全局快捷键触发器
  Widget wrapGlobalShortcutTrigger() {
    return GlobalShortcutTriggerWidget(child: this);
  }
}
