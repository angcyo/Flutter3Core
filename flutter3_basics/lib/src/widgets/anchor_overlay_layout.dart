part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/16
///
/// 使用[OverlayPortal]在指定的锚点[Widget]上显示内容。
/// [LayerLink] 连接对象
/// - [CompositedTransformTarget]    锚点目标
/// - [CompositedTransformFollower]  跟随目标
///
/// - [AnchorOverlayLayout]
/// - [HoverAnchorLayout] 悬停覆盖布局
/// - [RawAutocomplete] 系统自动完成布局
class AnchorOverlayLayout extends StatefulWidget {
  /// 锚点布局
  final Widget anchor;

  //--

  /// [CompositedTransformFollower]
  /// 需要对齐锚点的什么位置
  final Alignment targetAnchor;

  /// 用目标的什么位置对齐锚点的位置
  /// 这里只负责对齐, 不负责大小
  final Alignment followerAnchor;

  /// [followerAnchor]
  final Offset followerOffset;

  //--

  /// 是否使用根Overlay
  final bool rootOverlay;

  /// 构建浮窗内容
  final AnchorOverlayWidgetBuilder? overlayWidgetBuilder;

  //--

  /// 触发显示/隐藏的焦点节点
  /// 如果指定了, 那么有焦点时, 自动显示浮窗
  final FocusNode? triggerFocusNode;

  /// 触发显示/隐藏的[ValueNotifier]
  /// 如果指定了此值, 又指定了[triggerFocusNode], 则状态会自动同步
  final ValueNotifier<bool>? triggerValueNotifier;

  /// 共享手势区域
  /// [TapRegion]
  /// [TextFieldTapRegion]
  /// [TextField]
  /// [TextFormField]
  final Object? groupId;

  const AnchorOverlayLayout({
    super.key,
    required this.anchor,
    //--
    this.targetAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    this.followerOffset = Offset.zero,
    //--
    this.rootOverlay = false,
    this.overlayWidgetBuilder,
    //--
    this.triggerFocusNode,
    this.triggerValueNotifier,
    this.groupId = EditableText,
  });

  @override
  State<AnchorOverlayLayout> createState() => _AnchorOverlayLayoutState();
}

/// 布局构建
typedef AnchorOverlayWidgetBuilder = Widget Function(
    BuildContext context, Rect anchorBounds);

class _AnchorOverlayLayoutState extends State<AnchorOverlayLayout> {
  /// 锚点定位使用
  final LayerLink _overlayLayerLink = LayerLink();

  /// 浮窗布局显示/隐藏控制器
  final OverlayPortalController _overlayViewController =
      OverlayPortalController(debugLabel: '_AnchorOverlayLayoutState');

  @override
  void initState() {
    /*postDelayCallback(() {
      _overlayViewController.show();
    }, 2.seconds);*/
    super.initState();

    widget.triggerFocusNode
        ?.addListener(_updateOverlayViewVisibilityByFocusNode);
    widget.triggerValueNotifier
        ?.addListener(_updateOverlayViewVisibilityByValueNotifier);
  }

  @override
  void didUpdateWidget(AnchorOverlayLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*if (!identical(oldWidget.textEditingController, widget.textEditingController)) {
      oldWidget.textEditingController?.removeListener(_onChangedField);
      if (oldWidget.textEditingController == null) {
        _internalTextEditingController?.dispose();
        _internalTextEditingController = null;
      }
      widget.textEditingController?.addListener(_onChangedField);
    }*/
    if (!identical(oldWidget.triggerFocusNode, widget.triggerFocusNode)) {
      oldWidget.triggerFocusNode
          ?.removeListener(_updateOverlayViewVisibilityByFocusNode);
      /*if (oldWidget.triggerFocusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }*/
      widget.triggerFocusNode
          ?.addListener(_updateOverlayViewVisibilityByFocusNode);
    }
    if (!identical(
        oldWidget.triggerValueNotifier, widget.triggerValueNotifier)) {
      oldWidget.triggerValueNotifier
          ?.removeListener(_updateOverlayViewVisibilityByValueNotifier);
      widget.triggerValueNotifier
          ?.addListener(_updateOverlayViewVisibilityByValueNotifier);
    }
  }

  @override
  void dispose() {
    /*widget.textEditingController?.removeListener(_onChangedField);
    _internalTextEditingController?.dispose();*/
    widget.triggerFocusNode
        ?.removeListener(_updateOverlayViewVisibilityByFocusNode);
    widget.triggerValueNotifier
        ?.removeListener(_updateOverlayViewVisibilityByValueNotifier);
    /*_internalFocusNode?.dispose();
    _highlightedOptionIndex.dispose();*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.overlayWidgetBuilder == null) {
      return widget.anchor;
    }
    //--
    Widget child = widget.anchor;
    if (widget.groupId != null && widget.triggerFocusNode == null) {
      //未使用焦点触发, 则有可能不是使用的[TextField]
      child = TapRegion(
        groupId: widget.groupId,
        onTapOutside: (event) {
          if (widget.triggerValueNotifier == null) {
            _overlayViewController.hide();
          } else {
            widget.triggerValueNotifier!.value = false;
          }
        },
        child: child,
      );
    }
    //--
    child = CompositedTransformTarget(
      link: _overlayLayerLink,
      child: child,
    );
    if (widget.rootOverlay) {
      return OverlayPortal.targetsRootOverlay(
        controller: _overlayViewController,
        overlayChildBuilder: _buildOverlayView,
        child: child,
      );
    }
    return OverlayPortal(
      controller: _overlayViewController,
      overlayChildBuilder: _buildOverlayView,
      child: child,
    );
  }

  //--

  bool get _canShowOverlayView {
    if (widget.triggerFocusNode != null) {
      return widget.triggerFocusNode?.hasFocus == true;
    }
    return widget.triggerValueNotifier?.value == true;
  }

  /// 显示/隐藏浮窗[triggerFocusNode]
  void _updateOverlayViewVisibilityByFocusNode() {
    if (_canShowOverlayView) {
      widget.triggerValueNotifier?.value = true;
      _overlayViewController.show();
    } else {
      widget.triggerValueNotifier?.value = false;
      _overlayViewController.hide();
    }
  }

  /// 显示/隐藏浮窗[triggerValueNotifier]
  void _updateOverlayViewVisibilityByValueNotifier() {
    if (widget.triggerFocusNode != null) {
      widget.triggerFocusNode!.unfocus();
      return;
    }
    if (_canShowOverlayView) {
      _overlayViewController.show();
    } else {
      _overlayViewController.hide();
    }
  }

  /// 构建浮窗内容
  Widget _buildOverlayView(BuildContext context) {
    final renderBox = buildContext?.findRenderObject();
    final anchorBounds = renderBox?.getGlobalBounds(
      Overlay.maybeOf(context, rootOverlay: widget.rootOverlay)
          ?.context
          .findRenderObject(),
    );
    //l.d("anchorBounds: $anchorBounds");

    final TextDirection textDirection = Directionality.of(context);
    final Alignment followerAlignment =
        widget.followerAnchor.resolve(textDirection);
    final Alignment targetAnchor = widget.targetAnchor.resolve(textDirection);

    Widget body = widget.overlayWidgetBuilder!(context, anchorBounds!);
    body = body.align(
      widget.followerAnchor,
    );

    if (widget.groupId != null) {
      body = TapRegion(
        groupId: widget.groupId,
        child: body,
      );
    }

    return CompositedTransformFollower(
      link: _overlayLayerLink,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAlignment,
      offset: widget.followerOffset,
      child: body,
    );
  }

  //--
}
