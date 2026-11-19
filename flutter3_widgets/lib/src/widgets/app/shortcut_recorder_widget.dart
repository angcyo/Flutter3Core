part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/28
///
/// 快捷键录制小部件
///
/// - [ShortcutConfigBean]
///
/// [ShortcutLabelWidget] 用来显示快捷键
/// [ShortcutRecorderWidget] 用来记录快捷键
class ShortcutRecorderWidget extends StatefulWidget {
  /// 快捷键配置管理, 不指定不查询
  /// - 用来查询快捷键是否被占用
  final ShortcutConfigManager? shortcutConfigManager;

  /// 当前的快捷键
  final ShortcutConfigBean? currentShortcutConfig;

  /// 默认的快捷键
  final ShortcutConfigBean? defaultShortcutConfig;

  /// 快捷键有效性判断回调
  /// @return true 表示可以设置此快捷键
  final bool Function(
    ShortcutConfigBean? defaultShortcutConfig,
    ShortcutConfigBean? shortcutConfig,
  )?
  onShortcutChangeAction;

  /// 录制完成的快捷键回调
  /// - [shortcutConfig] : null 表示清除了
  /// @return true 表示消费了事件
  final bool Function(
    ShortcutConfigBean? defaultShortcutConfig,
    ShortcutConfigBean? shortcutConfig,
  )?
  onShortcutSubmitAction;

  /// 是否只能录制修饰键
  @defInjectMark
  final bool onlyModifierKeys;

  /// 是否必须要包含修饰键
  @defInjectMark
  final bool requireModifierKeys;

  /// 是否要强制指定是否查询快捷键冲突
  @defInjectMark
  final bool checkShortcutConflict;

  //--

  /// 宽度
  @defInjectMark
  final double? width;

  /// 高度
  @defInjectMark
  final double? height;

  //--

  /// 领头小部件
  final Widget? leading;

  /// 尾部小部件
  final Widget? trailing;

  /// 间距
  final double? gap;

  ShortcutRecorderWidget({
    super.key,
    this.shortcutConfigManager,
    this.currentShortcutConfig,
    this.defaultShortcutConfig,
    this.onShortcutChangeAction,
    this.onShortcutSubmitAction,
    bool? onlyModifierKeys,
    bool? requireModifierKeys,
    bool? checkShortcutConflict,
    //--
    this.width,
    this.height,
    //--
    this.leading,
    this.trailing,
    this.gap = kL,
  }) : onlyModifierKeys =
           onlyModifierKeys ?? (defaultShortcutConfig?.isModifierOnly == true),
       requireModifierKeys =
           requireModifierKeys ?? (defaultShortcutConfig?.hasModifier == true),
       checkShortcutConflict =
           checkShortcutConflict ??
           (onlyModifierKeys ??
               (defaultShortcutConfig?.isModifierOnly == true) != true);

  @override
  State<ShortcutRecorderWidget> createState() => _ShortcutRecorderWidgetState();
}

class _ShortcutRecorderWidgetState extends State<ShortcutRecorderWidget> {
  /// 是否已经设置过快捷键
  bool _isSet = false;
  ShortcutConfigBean? _configBean;

  /// 快捷键标签
  late final TextFieldConfig _labelConfig = TextFieldConfig(
    text: widget.currentShortcutConfig?.getShortcutLabel() ?? "",
    hintTextBuilder: (ctx) => ctx.libRes?.libSetHotkeys,
    onConfigChanged: (config, text) {
      if (text.isEmpty) {
        config.requestFocus();
        _isSet = true;
        _configBean = null;
        //widget.onShortcutAction?.call(null);
        updateState();
      }
    },
    onKeyEvent: (node, event) {
      if (event.isKeyDown || _configBean?.hasTriggerKey != true) {
        assert(() {
          l.d(event);
          return true;
        }());

        if (event.isEscKey /*event.isBackKey*/ ) {
          _labelConfig.updateText("");
        } else {
          final bean = ShortcutConfigBean.fromKeyEvent(
            event,
            control: isCtrlPressed.trueOrNull,
            shift: isShiftPressed.trueOrNull,
            alt: isAltPressed.trueOrNull,
            meta: isMetaPressed.trueOrNull,
          );
          /*assert(() {
            l.d(bean);
            return true;
          }());*/

          if (widget.onlyModifierKeys) {
            if (bean.hasTriggerKey) {
              // 只能录制修饰键, 当前不符合
              return .handled;
            }
          }
          //--
          if (widget.onShortcutChangeAction?.call(
                widget.defaultShortcutConfig,
                bean,
              ) !=
              false) {
            _isSet = true;
            _configBean = bean;
            _labelConfig.updateText(bean.getShortcutLabel());
          }
        }
        updateState();
      }
      return .handled;
    },
    onFocusAction: (focus, text) {
      if (!focus) {
        if (_isSet) {
          final configBean = _configBean;
          if (widget.requireModifierKeys) {
            if (configBean != null && !configBean.hasTriggerKey) {
              //必须要包含修饰键, 当前不符合
              restoreCurrentShortcut();
              return;
            }
          }

          if (widget.checkShortcutConflict &&
              widget.shortcutConfigManager != null) {
            final find = widget.shortcutConfigManager
                ?.findShortcutConfig(config: configBean)
                .firstOrNull;
            final current = widget.currentShortcutConfig;
            if (find != null && find.id != current?.id) {
              // 快捷键冲突
              restoreCurrentShortcut();
              final intentBean = widget.shortcutConfigManager
                  ?.findShortcutIntent(find.id);
              toastBlur(
                text: context.libRes?.libHotkeysConflict.connect(
                  textOf(intentBean, context)?.wsb,
                ),
              );
              return;
            }
          }

          if (widget.onShortcutSubmitAction?.call(
                widget.defaultShortcutConfig,
                configBean,
              ) ==
              true) {
            _isSet = false;
          }
        }
      }
    },
  );

  /// 不满足要求时, 恢复到当前的快捷键
  void restoreCurrentShortcut({ShortcutConfigBean? configBean}) {
    _isSet = false;
    _configBean = configBean ?? widget.currentShortcutConfig;
    _labelConfig.updateText(_configBean?.getShortcutLabel());
    //updateState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final libRes = context.libRes;
    final fontSize = kShortcutFontSize;
    return [
          widget.leading,
          SingleInputWidget(
            config: _labelConfig,
            contentPadding: insets(h: 6, v: 6),
            textStyle: globalTheme.textBodyStyle.copyWith(fontSize: fontSize),
            hintStyle: globalTheme.textDesStyle.copyWith(fontSize: fontSize),
            /*errorStyle: globalTheme.textError.copyWith(fontSize: fontSize),*/
            /*textAlign: .center,*/
            alwaysShowSuffixIcon: true,
            suffixIconSize: 16,
            suffixIconPadding: insets(all: 0),
            suffixIconConstraints: BoxConstraints.tightFor(
              width: 28,
              height: 28,
            ),
            suffixIconBuilder: (state, ctx, child) {
              if (_labelConfig.isEmpty &&
                  widget.defaultShortcutConfig != null) {
                //显示设置默认的快捷键icon
                return IconButton(
                  /*飞溅的颜色*/
                  color: globalTheme.icoNormalColor,
                  padding: state.widget.suffixIconPadding,
                  constraints: state.widget.suffixIconConstraints,
                  focusNode: state.widget.config.suffixFocusNode,
                  onPressed: () {
                    _labelConfig.requestFocus();
                    _isSet = true;
                    _configBean = widget.defaultShortcutConfig;
                    _labelConfig.updateText(_configBean?.getShortcutLabel());
                    updateState();
                  },
                  tooltip: libRes?.libDefaultHotkeys,
                  icon: Icon(
                    Icons.undo,
                    size: state.widget.suffixIconSize,
                    /*图标的颜色*/
                    color: globalTheme.icoNormalColor,
                  ),
                );
              }
              return child?.invisible(invisible: _labelConfig.isEmpty);
            },
          ).size(
            width: widget.width ?? 130 /*(widget.onlyModifierKeys ? 80 : 140)*/,
            height: widget.height ?? 30,
          ),
          widget.trailing,
        ]
        .row(crossAxisAlignment: .center, gap: widget.gap)!
        .tooltip(null, shortcut: _configBean ?? widget.currentShortcutConfig);
  }
}

/// 快捷键字体大小
const kShortcutFontSize = 12.0;
