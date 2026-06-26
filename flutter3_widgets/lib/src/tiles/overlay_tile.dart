part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/21
///
/// 覆盖层触发器,
/// 使用[CompositedTransformTarget].[CompositedTransformFollower]+[OverlayEntry]实现
///
/// - [MenuTriggerWidget]
/// - [OverlayTriggerWidget]
///
/// [OverlayPortal]
class OverlayTriggerWidget extends StatefulWidget {
  final Widget? child;

  /// [Overlay]需要显示的内容
  /// - 请自行控制约束大小
  /// - 和[Material]
  final Widget? content;

  /// 是否激活悬停触发显示
  final bool hoverTrigger;

  /// 悬停时的装饰
  @defInjectMark
  final Decoration? hoverDecoration;

  /// 点击的额外回调
  final GestureTapCallback? onTap;

  /// 是否处于选中状态, 会有背景装饰
  final bool? isSelected;

  /// 选中状态的背景
  @defInjectMark
  final Decoration? selectedDecoration;

  /// 鼠标样式
  @defInjectMark
  final MouseCursor? cursor;

  //MARK: - Composited

  /// 对齐锚点的什么位置
  final Alignment targetAnchor;

  /// 浮窗的什么位置
  final Alignment followerAnchor;

  /// 对齐后, 额外的偏移量
  final Offset? alignmentOffset;

  //MARK: - Overlay

  /// 是否使用根Overlay
  final bool rootOverlay;

  const OverlayTriggerWidget({
    super.key,
    this.child,
    this.content,
    this.hoverTrigger = false,
    this.hoverDecoration,
    this.isSelected,
    this.selectedDecoration,
    this.onTap,
    this.cursor,
    //--
    this.targetAnchor = .topLeft,
    this.followerAnchor = .topLeft,
    this.alignmentOffset,
    //--
    this.rootOverlay = false,
  });

  @override
  State<OverlayTriggerWidget> createState() => _OverlayTriggerWidgetState();
}

class _OverlayTriggerWidgetState extends State<OverlayTriggerWidget> {
  /// 1. 创建 LayerLink 用于连接 目标组件 和 悬浮Overlay 组件
  final LayerLink _layerLink = LayerLink();

  /// 2. 维护全局顶层悬浮窗的引用
  OverlayEntry? _overlayEntry;

  /// 显示 Overlay
  void _showOverlay() {
    if (_overlayEntry != null) return; // 防止重复创建
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          // 必须使用 CompositedTransformFollower 来实现坐标跟随
          child: CompositedTransformFollower(
            link: _layerLink,
            // 当目标组件不在屏幕内时隐藏
            showWhenUnlinked: false,
            offset: widget.alignmentOffset ?? .zero /*const Offset(0, 55)*/,
            // 对齐锚点的什么位置
            targetAnchor: widget.targetAnchor,
            // 浮窗的什么位置
            followerAnchor: widget.followerAnchor,
            child: _wrapHoverChild(
              widget.content,
            )?.align(widget.followerAnchor) /*.bounds()*/,
          ),
        );
      },
    );

    // 将创建好的 Entry 插入到全局 Overlay 中
    Overlay.of(context, rootOverlay: widget.rootOverlay).insert(_overlayEntry!);
  }

  /// 隐藏并销毁 Overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    // 关键：如果组件在悬停状态下被销毁，必须手动释放 Overlay，否则会导致内存泄漏和UI残留
    _hideOverlay();
    _debounceTimer?.cancel(); // 销毁时务必释放定时器，防止内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final hoverDecoration =
        widget.hoverDecoration ??
        fillDecoration(
          color: globalTheme.hoverColor,
          radius: kDefaultBorderRadiusH,
        );
    // 3. 必须使用 CompositedTransformTarget 包裹目标组件
    final child = CompositedTransformTarget(
      link: _layerLink,
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
          child: widget.child?.click(() {
            //l.d(_widgetFocusNode.hasFocus);
            if (_overlayEntry == null) {
              _showOverlay();
            } else {
              _hideOverlay();
            }
            widget.onTap?.call();
          }),
        ),
      ),
    );
    //--mouse
    final result = MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: (_) {
        _isMouseOverButtonLive << true;
        if (widget.hoverTrigger) {
          _showOverlay();
        }
      },
      onExit: (_) {
        _isMouseOverButtonLive << false;
        if (widget.hoverTrigger) {
          _scheduleCloseCheck(); // 划出进入缓冲区
        }
      },
      onHover: (_) {
        //l.d("onHover");
      },
      child: child,
    );
    return result;
  }

  //MARK: - hover

  /// 鼠标在当前按钮内
  final _isMouseOverButtonLive = $live(false);

  /// 鼠标在菜单内
  final _isMouseOverMenuLive = $live(false);

  Timer? _debounceTimer;

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
        _hideOverlay();
      }
    });
  }

  /// 将Overlay内容使用鼠标区域包裹起来, 共享鼠标的进入/离开事件
  Widget? _wrapHoverChild(Widget? child) {
    if (child == null) return null;
    if (widget.hoverTrigger) {
      return MouseRegion(
        onEnter: (_) {
          _isMouseOverMenuLive << true; // 鼠标进入任何一级的菜单项
        },
        onExit: (_) {
          _isMouseOverMenuLive << false; // 鼠标离开当前菜单项
          _scheduleCloseCheck(); // 触发延迟关闭检查
        },
        child: child,
      );
    }
    return child;
  }
}

extension OverlayTriggerWidgetEx on Widget {
  /// [Overlay]覆盖层现实触发器
  @dsl
  OverlayTriggerWidget overlayTrigger({
    Key? key,
    Widget? content,
    bool hoverTrigger = false,
    Decoration? hoverDecoration,
    GestureTapCallback? onTap,
    bool? isSelected,
    Decoration? selectedDecoration,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? alignmentOffset,
    MouseCursor? cursor,
  }) {
    return OverlayTriggerWidget(
      key: key,
      hoverTrigger: hoverTrigger,
      content: content,
      hoverDecoration: hoverDecoration,
      isSelected: isSelected,
      selectedDecoration: selectedDecoration,
      targetAnchor: targetAnchor ?? .topLeft,
      followerAnchor: followerAnchor ?? .topLeft,
      alignmentOffset: alignmentOffset,
      onTap: onTap,
      cursor: cursor,
      child: this,
    );
  }
}

/// 浮窗上下文扩展
///
/// - [OverlayTriggerWidget]
/// - [ArrowPopupOverlay]
extension OverlayEx on BuildContext {
  /// 在指定锚点位置显示浮窗 [Overlay]+[OverlayEntry]实现
  /// - [OverlayEntry.remove] 手动移除
  ///
  /// - [PopupEx.showArrowPopupOverlay]
  Future<OverlayEntry> showOverlay(
    Widget? Function(BuildContext, OverlayEntry)? contentBuilder, {
    BuildContext? anchorChild,
    bool rootOverlay = false,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? alignmentOffset,
  }) async {
    final that = this;
    final overlay = Overlay.of(that, rootOverlay: rootOverlay);
    //--
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return AlignmentAnchorLayout(
          anchorChild: anchorChild ?? that,
          anchorAncestor: overlay.context.findRenderObject(),
          targetAnchor: targetAnchor,
          followerAnchor: followerAnchor,
          alignmentOffset: alignmentOffset,
          child: contentBuilder?.call(context, overlayEntry!) ?? empty,
        );
      },
    );
    overlay.insert(overlayEntry);
    return overlayEntry;
  }
}
