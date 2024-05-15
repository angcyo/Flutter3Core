part of 'popup.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/15
///
/// https://github.com/malikwang/custom_pop_up_menu
/// 使用[OverlayEntry]的方式显示, 不会阻止手势穿透
/// [ArrowPopupRoute]
class ArrowPopupOverlay extends StatefulWidget {
  ArrowPopupOverlay({
    super.key,
    required this.child,
    required this.anchorRect,
    this.backgroundColor = Colors.white,
    this.arrowColor = Colors.white,
    required this.showArrow,
    this.autoArrowDirection = true,
    this.barriersColor,
    this.arrowDirectionMinOffset = 15,
    this.arrowDirection, //可以强制指定箭头方向
    this.animate = true,
    this.animateDuration = const Duration(milliseconds: 150),
    this.enablePassEvent = true,
    this.controller,
  });

  final Rect anchorRect;
  final Widget child;

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();
  final Color? backgroundColor;
  final Color arrowColor;
  final bool showArrow;
  final Color? barriersColor;

  /// 是否根据锚点的位置, 自动设置箭头的方向
  /// 否则在不指定[arrowDirection]的情况下, 会根据剩余空间的大小, 自动设置箭头的方向
  final bool autoArrowDirection;

  /// 指定箭头方向
  final AxisDirection? arrowDirection;

  final double arrowDirectionMinOffset;

  //--

  /// 是否需要显示动画
  final bool animate;

  /// 动画时长
  final Duration animateDuration;

  //--

  /// Pass tap event to the widgets below the mask.
  /// It only works when [barrierColor] is transparent.
  /// 是否要激活窗口外的事件穿透
  final bool enablePassEvent;

  /// 控制器
  final ArrowPopupOverlayController? controller;

  @override
  State<ArrowPopupOverlay> createState() => _ArrowPopupOverlayState();
}

class _ArrowPopupOverlayState extends State<ArrowPopupOverlay>
    with ArrowDirectionMixin, SingleTickerProviderStateMixin {
  bool offstage = false;

  AxisDirection? _arrowDirection;

  @override
  AxisDirection? get arrowDirection => _arrowDirection;

  @override
  set arrowDirection(AxisDirection? value) {
    _arrowDirection = value;
  }

  double _arrowDirectionMinOffset = 15;

  @override
  double get arrowDirectionMinOffset => _arrowDirectionMinOffset;

  @override
  set arrowDirectionMinOffset(double value) {
    _arrowDirectionMinOffset = value;
  }

  late final AnimationController controller = AnimationController(
    duration: widget.animateDuration,
    reverseDuration: widget.animateDuration,
    vsync: this,
  );

  @override
  void initState() {
    _arrowDirection = widget.arrowDirection;
    _arrowDirectionMinOffset = widget.arrowDirectionMinOffset;

    offstage = true;
    applyAutoSetArrowDirection(widget.autoArrowDirection, widget.anchorRect);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Rect? childRect = getGlobalKeyChildRect(widget._childKey);
      Rect? arrowRect = getGlobalKeyChildRect(widget._arrowKey);

      //移除lt的值
      if (childRect != null) {
        childRect = Offset.zero & childRect.size;
      }
      if (arrowRect != null) {
        arrowRect = Offset.zero & arrowRect.size;
      }

      //debugger();
      calculateChildOffset(
        anchorRect: widget.anchorRect,
        childRect: childRect,
      );
      calculateArrowOffset(
        anchorRect: widget.anchorRect,
        childRect: childRect,
        arrowRect: arrowRect,
      );
      offstage = false;
      updateState();
    });
    super.initState();
    widget.controller?.menuIsShowing = true;
    widget.controller?.notify();
    controller.forward();
  }

  /// 隐藏界面
  void _hideOverlay() {
    controller.reverse().then((value) {
      widget.controller?.overlayEntry?.remove();
      widget.controller?.menuIsShowing = false;
      widget.controller?.notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    Widget child = ArrowLayout(
      childKey: widget._childKey,
      arrowKey: widget._arrowKey,
      arrowDirectionOffset: _arrowDirectionOffset,
      arrowDirection: arrowDirection ?? AxisDirection.down,
      backgroundColor: widget.backgroundColor,
      arrowColor: widget.arrowColor,
      showArrow: widget.showArrow,
      child: widget.child,
    );
    if (widget.animate) {
      child = FadeTransition(
        opacity: controller,
        child: ScaleTransition(
          alignment: FractionalOffset(_scaleAlignDx, _scaleAlignDy),
          scale: controller,
          child: child,
        ),
      );
    }

    child = Stack(
      children: [
        Positioned(
          left: _left,
          right: _right,
          top: _top,
          bottom: _bottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ArrowDirectionMixin._viewportRect.width,
              maxHeight: _maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );

    //debugger();
    return Offstage(
      offstage: offstage,
      child: Listener(
        behavior: widget.enablePassEvent
            ? HitTestBehavior.translucent
            : HitTestBehavior.opaque,
        onPointerDown: (PointerDownEvent event) {
          Offset offset = event.localPosition;
          // If tap position in menu
          //debugger();
          final childRect = getGlobalKeyChildRect(widget._childKey);
          if (childRect?.contains(offset) == true ||
              widget.anchorRect.contains(offset)) {
            return;
          }
          _hideOverlay();
          // When [enablePassEvent] works and we tap the [child] to [hideMenu],
          // but the passed event would trigger [showMenu] again.
          // So, we use time threshold to solve this bug.
          widget.controller?.canResponse = false;
          widget.controller?.notify();
          Future.delayed(widget.animateDuration).then((_) {
            widget.controller?.canResponse = true;
            widget.controller?.notify();
          });
        },
        child: widget.barriersColor == Colors.transparent
            ? child
            : Container(
                color: widget.barriersColor,
                child: child,
              ),
      ),
    );
  }
}

class ArrowPopupOverlayController extends ChangeNotifier {
  /// 是否正在显示菜单
  bool menuIsShowing = false;

  /// 是否要相应显示popup事件
  bool canResponse = false;

  /// 载体
  OverlayEntry? overlayEntry;

  /// 隐藏弹窗
  void hidePopup() {
    if (menuIsShowing) {
      menuIsShowing = false;
      overlayEntry?.remove();
      notify();
    }
  }

  void notify() {
    notifyListeners();
  }
}
