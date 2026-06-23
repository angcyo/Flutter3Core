part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/19
///
/// 使用[MenuAnchor].[MenuItemButton].[SubmenuButton]实现的菜单tile
///
/// 快捷键修饰符号
/// ```
/// _LocalizedShortcutLabeler.instance.getShortcutLabel(
///    shortcut!,
///    MaterialLocalizations.of(context),
///  )
/// ```
///
///
/// - [DropdownMenuTile] tile 内部[Overlay]
/// - [MenuAnchorTile] tile [MenuAnchor]实现
///
/// 用来触发显示菜单的[Widget]
/// - 支持点击触发
/// - 支持悬停触发
///
/// - [MenuTriggerWidget], 使用[MenuAnchor]实现
/// - [SubmenuTriggerWidget], 使用[SubmenuButton]实现
class MenuTriggerWidget extends StatefulWidget {
  /// 触发菜单的[Widget]
  final Widget? child;

  /// 触发菜单的[Widget]的构建
  final MenuAnchorChildBuilder? childBuilder;

  /// 是否激活悬停触发菜单
  /// - 支持多级
  final bool hoverTrigger;

  /// 悬停时的装饰
  @defInjectMark
  final Decoration? hoverDecoration;

  /// 点击菜单的回调
  final GestureTapCallback? onTap;

  /// 是否处于选中状态, 会有背景装饰
  final bool? isSelected;

  /// 选中状态的背景
  @defInjectMark
  final Decoration? selectedDecoration;

  /// 鼠标样式
  @defInjectMark
  final MouseCursor? cursor;

  //MARK: menu style

  /// 菜单的样式
  final MenuStyle? menuStyle;

  /// 菜单样式的背景颜色
  @defInjectMark
  final Color? menuBgColor;

  /// 菜单显示的对齐方式
  /// - 移动端默认null
  /// - 桌面端默认[AlignmentGeometry.topRight]
  final AlignmentGeometry? alignment;

  /// 对齐后, 额外的偏移量
  final Offset? alignmentOffset;

  //MARK: menu items

  /// 菜单项
  final List<Widget>? menuChildren;

  /// 是否显示有菜单时的提示小部件
  /// - 默认有菜单时, 自动显示
  @autoInjectMark
  final bool? showMoreMenuTip;

  /// 右下角显示的更多图标
  @defInjectMark
  final Widget? moreMenuTipWidget;

  const MenuTriggerWidget({
    super.key,
    this.child,
    this.childBuilder,
    this.hoverTrigger = false,
    this.hoverDecoration,
    this.isSelected,
    this.selectedDecoration,
    this.onTap,
    this.cursor,
    //--menu
    this.menuStyle,
    this.alignment,
    this.alignmentOffset,
    this.menuBgColor,
    //--items
    this.menuChildren,
    this.showMoreMenuTip,
    this.moreMenuTipWidget,
  });

  @override
  State<MenuTriggerWidget> createState() => MenuTriggerWidgetState();
}

class MenuTriggerWidgetState extends State<MenuTriggerWidget> {
  final FocusNode _widgetFocusNode = FocusNode(debugLabel: 'MenuTriggerWidget');

  /// 菜单的快捷键注册
  ShortcutRegistryEntry? _menuShortcutsEntry;

  /// 菜单当前的动画状态
  AnimationStatus _menuAnimationStatus = .dismissed;

  /// https://api.flutter.dev/flutter/material/MenuAnchor-class.html
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dispose of any previously registered shortcuts, since they are about to
    // be replaced.
    _menuShortcutsEntry?.dispose();
    // Collect the shortcuts from the different menu selections so that they can
    // be registered to apply to the entire app. Menus don't register their
    // shortcuts, they only display the shortcut hint text.
    /*final Map<ShortcutActivator, Intent> shortcuts =
        <ShortcutActivator, Intent>{
          for (final MenuEntry item in MenuEntry.values)
            if (item.shortcut != null)
              item.shortcut!: VoidCallbackIntent(() => _activate(item)),
        };
    // Register the shortcuts with the ShortcutRegistry so that they are
    // available to the entire application.
    if (shortcuts.isNotEmpty) {
      _menuShortcutsEntry = ShortcutRegistry.of(context).addAll(shortcuts);
    }*/
  }

  @override
  void dispose() {
    _menuShortcutsEntry?.dispose();
    _widgetFocusNode.dispose();
    _debounceTimer?.cancel(); // 销毁时务必释放定时器，防止内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final menuBgColor = widget.menuBgColor ?? globalTheme.dialogSurfaceBgColor;
    final menuStyle =
        widget.menuStyle ??
        kMenuStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(menuBgColor),
          alignment: widget.alignment ?? (isDesktopOrWeb ? .topRight : null),
        );
    final showMoreMenuTip =
        widget.showMoreMenuTip ?? widget.menuChildren?.isNotEmpty == true;
    final hoverDecoration =
        widget.hoverDecoration ??
        fillDecoration(
          color: globalTheme.hoverColor,
          radius: kDefaultBorderRadiusH,
        );
    return MenuTriggerScope(
      menuTriggerWidgetState: this,
      child: MenuAnchor(
        controller: _menuController,
        animated: true,
        onAnimationStatusChanged: (status) {
          // Store the animation status so that it can be used to determine
          // whether the menu is opening or closing when the button is
          // pressed.
          _menuAnimationStatus = status;
        },
        childFocusNode: _widgetFocusNode,
        style: menuStyle,
        //菜单对齐之后, 额外的偏移量
        alignmentOffset: widget.alignmentOffset ?? .zero,
        reservedPadding: .zero /*insets(all: 8)*/,
        menuChildren: _wrapHoverMenChildren(widget.menuChildren),
        builder: (context, menuController, child) {
          //--body
          Widget body =
              widget.childBuilder?.call(context, menuController, child) ??
              (widget.child ?? empty);
          //--tip
          if (showMoreMenuTip) {
            body = [
              body.paddingOnly(all: 4),
              (widget.moreMenuTipWidget ?? Icon(Icons.more_horiz, size: 8))
                  .position(right: 0, bottom: 0),
            ].stack()!;
          }
          //--click
          if (widget.childBuilder == null) {
            body = body.click(() {
              /*l.d(
                "${_widgetFocusNode.hasFocus} ${menuController.isOpen} $_menuAnimationStatus",
              );*/
              if (_menuAnimationStatus == .forward ||
                  _menuAnimationStatus == .dismissed) {
                //菜单正在动画打开, 则直接打开
                menuController.open();
              } else if (_menuAnimationStatus == .reverse ||
                  menuController.isOpen) {
                menuController.close();
              }
              widget.onTap?.call();
            });
          }
          //--mouse
          final result = MouseRegion(
            cursor: widget.cursor ?? MouseCursor.defer,
            onEnter: (_) {
              _isMouseOverButtonLive << true;
              if (widget.hoverTrigger && !menuController.isOpen) {
                menuController.open();
              }
            },
            onExit: (_) {
              _isMouseOverButtonLive << false;
              if (widget.hoverTrigger && menuController.isOpen) {
                _scheduleCloseCheck(); // 划出进入缓冲区
              }
            },
            onHover: (_) {
              //l.d("onHover");
            },
            child: [_isMouseOverButtonLive, _isMouseOverMenuLive].buildFn(
              () => DecoratedBox(
                decoration: widget.isSelected == true
                    ? widget.selectedDecoration ??
                          fillDecoration(
                            color: globalTheme.hoverColor,
                            radius: kDefaultBorderRadiusH,
                          )
                    : _isMouseOverButtonLive.value == true ||
                          _isMouseOverMenuLive.value == true
                    ? hoverDecoration
                    : kEmptyDecoration,
                child: body,
              ),
            ),
          );
          return result;
        },
      ),
    );
  }

  //MARK: - hover

  final MenuController _menuController = MenuController();

  /// 鼠标在当前按钮内
  final _isMouseOverButtonLive = $live(false);

  /// 鼠标在菜单内
  final _isMouseOverMenuLive = $live(false);
  Timer? _debounceTimer;

  /// 组件包装器：无视菜单层级，只要是菜单项就用它包裹起来
  List<Widget> _wrapHoverMenChildren(List<Widget>? children) {
    if (children == null) return [];
    if (widget.hoverTrigger) {
      return [
        for (final child in children)
          MouseRegion(
            onEnter: (_) {
              _isMouseOverMenuLive << true; // 鼠标进入任何一级的菜单项
            },
            onExit: (_) {
              _isMouseOverMenuLive << false; // 鼠标离开当前菜单项
              _scheduleCloseCheck(); // 触发延迟关闭检查
            },
            child: child,
          ),
      ];
    }
    return children;
  }

  /// 核心控制中枢：延迟检查是否应该关闭菜单
  void _scheduleCloseCheck() {
    if (!widget.hoverTrigger) {
      return;
    }
    _debounceTimer?.cancel(); // 每次触发时清除上一次的计时器
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      // 只有当鼠标既不在触发按钮上，也不在任何层级的菜单上时，才真正关闭
      if (_isMouseOverButtonLive.value != true &&
          _isMouseOverMenuLive.value != true) {
        _menuController.close();
      }
    });
  }
}

/// 子菜单触发器, 使用[SubmenuButton]实现
/// - [MenuTriggerWidget], 使用[MenuAnchor]实现
/// - [SubmenuTriggerWidget], 使用[SubmenuButton]实现
class SubmenuTriggerWidget extends StatefulWidget {
  /// 触发菜单的[Widget]
  final Widget? child;

  /// 按钮的边距
  @defInjectMark
  final EdgeInsets? margin;

  //MARK: menu style

  /// 菜单的样式
  @defInjectMark
  final MenuStyle? menuStyle;

  /// 菜单样式的背景颜色
  @defInjectMark
  final Color? menuBgColor;

  //MARK: menu items

  /// 菜单项
  final List<Widget>? menuChildren;

  //MARK: SubmenuButton

  /// 菜单首部图标
  final Widget? leadingIcon;

  /// 菜单尾部图标
  final Widget? trailingIcon;

  /// 按钮样式
  @defInjectMark
  final ButtonStyle? buttonStyle;

  const SubmenuTriggerWidget({
    super.key,
    this.child,
    this.margin,
    //--
    this.menuStyle,
    this.menuBgColor,
    this.menuChildren,
    //--
    this.buttonStyle,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  State<SubmenuTriggerWidget> createState() => _SubmenuTriggerWidgetState();
}

class _SubmenuTriggerWidgetState extends State<SubmenuTriggerWidget> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final menuBgColor = widget.menuBgColor ?? globalTheme.dialogSurfaceBgColor;
    final menuStyle =
        widget.menuStyle ??
        kMenuStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(menuBgColor),
          alignment: .topRight,
        );
    return SubmenuButton(
      animated: true,
      /*onAnimationStatusChanged: ,*/
      style:
          widget.buttonStyle ??
          ButtonStyle(
            /*overlayColor: WidgetStatePropertyAll(Colors.transparent),*/
            overlayColor: WidgetStatePropertyAll(globalTheme.hoverColor),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(kDefaultBorderRadiusH),
                ),
              ),
            ),
            //按钮内部填充
            padding: WidgetStatePropertyAll(.zero),
            visualDensity: VisualDensity.compact,
            minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
          ),
      menuStyle: menuStyle,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
      menuChildren: _wrapHoverMenChildren(context, widget.menuChildren),
      child: widget.child,
    ).paddingOnly(horizontal: kM, vertical: kM, insets: widget.margin);
  }

  /// 组件包装器：无视菜单层级，只要是菜单项就用它包裹起来
  List<Widget> _wrapHoverMenChildren(
    BuildContext context,
    List<Widget>? children,
  ) {
    if (children == null) return [];
    return [
      for (final child in children)
        MouseRegion(
          onEnter: (_) {
            // 鼠标进入任何一级的菜单项
            MenuTriggerScope.of(
              context,
            )?._isMouseOverMenuLive.updateValue(true);
          },
          onExit: (_) {
            // 鼠标离开当前菜单项
            MenuTriggerScope.of(context)
              ?.._isMouseOverMenuLive.updateValue(false)
              .._scheduleCloseCheck(); // 触发延迟关闭检查
          },
          child: child,
        ),
    ];
  }
}

/// - 提供一个[MenuController]
class MenuTriggerScope extends InheritedWidget {
  static MenuTriggerWidgetState? of(
    BuildContext context, {
    bool depend = false,
  }) {
    if (depend) {
      return context
          .dependOnInheritedWidgetOfExactType<MenuTriggerScope>()
          ?.menuTriggerWidgetState;
    } else {
      return context
          .getInheritedWidgetOfExactType<MenuTriggerScope>()
          ?.menuTriggerWidgetState;
    }
  }

  /// 关闭上层菜单
  static void close(BuildContext context, {bool depend = false}) {
    MenuTriggerScope.of(context, depend: depend)?._menuController.close();
  }

  final MenuTriggerWidgetState menuTriggerWidgetState;

  const MenuTriggerScope({
    super.key,
    required this.menuTriggerWidgetState,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant MenuTriggerScope oldWidget) {
    return menuTriggerWidgetState != oldWidget.menuTriggerWidgetState;
  }
}

extension MenuTriggerWidgetEx on Widget {
  /// 主菜单显示触发器
  @dsl
  MenuTriggerWidget menuTrigger({
    Key? key,
    List<Widget>? menuChildren,
    bool hoverTrigger = false,
    bool? showMoreMenuTip,
    Widget? moreMenuTipWidget,
    Decoration? hoverDecoration,
    GestureTapCallback? onTap,
    bool? isSelected,
    Decoration? selectedDecoration,
    AlignmentGeometry? alignment,
    Offset? alignmentOffset,
    MouseCursor? cursor,
  }) {
    return MenuTriggerWidget(
      key: key,
      hoverTrigger: hoverTrigger,
      menuChildren: menuChildren,
      showMoreMenuTip: showMoreMenuTip,
      moreMenuTipWidget: moreMenuTipWidget,
      hoverDecoration: hoverDecoration,
      isSelected: isSelected,
      selectedDecoration: selectedDecoration,
      onTap: onTap,
      alignment: alignment,
      alignmentOffset: alignmentOffset,
      cursor: cursor,
      child: this,
    );
  }

  /// 子菜单显示触发器
  @dsl
  SubmenuTriggerWidget submenuTrigger({
    Key? key,
    List<Widget>? menuChildren,
    EdgeInsets? margin,
    ButtonStyle? buttonStyle,
  }) {
    return SubmenuTriggerWidget(
      key: key,
      buttonStyle: buttonStyle,
      margin: margin,
      menuChildren: menuChildren,
      child: this,
    );
  }
}
