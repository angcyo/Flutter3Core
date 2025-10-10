part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/10
///
/// 将[child]布局在指定的锚点[anchor]位置上
///
/// - 无法准确获取[BuildContext]的卸载状态?
@implementation
@Deprecated("implementation")
class AnchorLocationLayout extends SingleChildRenderObjectWidget {
  /// 锚点元素, 用来获取位置
  final BuildContext? anchor;

  /// 锚点元素所在的祖先, 不指定就是全屏幕
  final RenderObject? anchorAncestor;

  /// 当锚点元素被卸载时回调
  final void Function()? onAnchorUnmount;

  /// [child]对齐锚点[anchor]的哪个方向?
  /// - 不指定则根据当前锚点在容器中的位置自动决定
  final Alignment? align;

  /// 偏移锚点的量
  final double alignOffset;

  /// 额外在x/y方向上的偏移量
  final double offsetX;
  final double offsetY;

  const AnchorLocationLayout({
    super.key,
    this.anchor,
    this.anchorAncestor,
    this.onAnchorUnmount,
    this.align,
    this.alignOffset = kH,
    this.offsetX = 0,
    this.offsetY = 0,
    super.child,
  });

  @override
  AnchorLocationRenderObject createRenderObject(BuildContext context) {
    return AnchorLocationRenderObject(config: this);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    AnchorLocationRenderObject renderObject,
  ) {
    renderObject.config = this;
  }

  @override
  void didUnmountRenderObject(AnchorLocationRenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }
}

/// [CustomSingleChildLayout]
class AnchorLocationRenderObject extends RenderProxyBox {
  AnchorLocationLayout? _config;

  AnchorLocationLayout? get config => _config;

  set config(AnchorLocationLayout? value) {
    if (_config != value) {
      _config = value;
      measureAnchorLocation();
    }
  }

  AnchorLocationRenderObject({AnchorLocationLayout? config, RenderBox? child})
    : _config = config,
      super(child) {
    measureAnchorLocation();
    checkAnchorUnmount();
  }

  /// [BoxParentData]
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  ///
  @override
  void performLayout() {
    //super.performLayout();
    checkAnchorUnmount();
    child?.layout(constraints, parentUsesSize: true);
    if (child == null) {
      size = constraints.smallest;
    } else {
      measureChildOffset(child!.size);
      final parentData = child?.parentData;
      if (parentData is BoxParentData) {
        parentData.offset = _anchorOffset;
      }
      debugger();

      size = constraints.biggest;
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final parentData = child?.parentData;
    debugger();
    checkAnchorUnmount();
    super.paint(context, offset);
  }

  @override
  bool paintsChild(covariant RenderObject child) {
    final parentData = child.parentData;
    debugger();
    return super.paintsChild(child);
  }

  @override
  void attach(PipelineOwner owner) {
    //debugger();
    super.attach(owner);
  }

  @override
  void detach() {
    //debugger();
    super.detach();
  }

  //--

  /// 锚点当前的位置
  Rect? _anchorRect;

  Size _ancestorSize = Size.zero;

  /// 测量出来的对齐方式
  Alignment? _anchorAlign;

  /// [child]对齐的偏移
  Offset _anchorOffset = Offset.zero;

  /// 测量锚点在祖先中的位置, 在布局阶段不可以调用此方法
  void measureAnchorLocation() {
    //debugger();
    if (config?.anchor?.isMounted == true) {
      _ancestorSize =
          config?.anchorAncestor?.renderSize ??
          Size($screenWidth, $screenHeight);
      final rect = config?.anchor?.findRenderObject()?.getGlobalBounds(
        config?.anchorAncestor,
      );
      _anchorRect = rect;
    }
  }

  /// 测量child的偏移
  void measureChildOffset(Size childSize) {
    final ancestorSize = _ancestorSize;
    final anchorRect = _anchorRect ?? Rect.zero;
    final childWidth = childSize.width;
    final childHeight = childSize.height;
    final margin = config?.alignOffset ?? 0;
    final offsetX = config?.offsetX ?? 0;
    final offsetY = config?.offsetY ?? 0;

    Alignment? align;
    if (config?.align != null) {
      align = config?.align;
    } else {
      final anchorCx = anchorRect.center.dx;
      final anchorCy = anchorRect.center.dy;
      final screenCx = ancestorSize.width / 2;
      final screenCy = ancestorSize.height / 2;
      if (anchorCx < screenCx) {
        if (anchorCy < screenCy) {
          //锚点在屏幕左上
          align = Alignment.topRight;
        } else {
          //锚点在屏幕左下
          align = Alignment.bottomRight;
        }
      } else {
        if (anchorCy < screenCy) {
          //锚点在屏幕右上
          align = Alignment.topLeft;
        } else {
          //锚点在屏幕右下
          align = Alignment.bottomLeft;
        }
      }
    }
    if (align == Alignment.topLeft) {
      _anchorOffset = Offset(
        anchorRect.left - childWidth - margin - offsetX,
        anchorRect.top + offsetY,
      );
    } else if (align == Alignment.topCenter) {
      _anchorOffset = Offset(
        anchorRect.center.dx - childWidth / 2 + offsetX,
        anchorRect.top - childHeight - margin - offsetY,
      );
    } else if (align == Alignment.topRight) {
      _anchorOffset = Offset(
        anchorRect.right + margin + offsetX,
        anchorRect.top - offsetY,
      );
    } else if (align == Alignment.centerRight) {
      _anchorOffset = Offset(
        anchorRect.right + margin + offsetX,
        anchorRect.center.dy - childHeight / 2 + offsetY,
      );
    } else if (align == Alignment.bottomRight) {
      _anchorOffset = Offset(
        anchorRect.right + margin + offsetX,
        anchorRect.bottom - childHeight + offsetY,
      );
    } else if (align == Alignment.bottomCenter) {
      _anchorOffset = Offset(
        anchorRect.center.dx - childWidth / 2 + offsetX,
        anchorRect.bottom + margin + offsetY,
      );
    } else if (align == Alignment.bottomLeft) {
      _anchorOffset = Offset(
        anchorRect.left - childWidth - margin - offsetX,
        anchorRect.bottom - childHeight + offsetY,
      );
    } else if (align == Alignment.centerLeft) {
      _anchorOffset = Offset(
        anchorRect.left - childWidth - margin - offsetX,
        anchorRect.centerY - childHeight / 2 + offsetY,
      );
    } else {
      _anchorOffset = Offset(
        anchorRect.right + margin + offsetX,
        anchorRect.top + offsetY,
      );
    }
  }

  /// 检查锚点是否已卸载
  void checkAnchorUnmount() {
    //postFrameCallbackIfNeed(callback)
    final schedulerPhase = WidgetsBinding.instance.schedulerPhase;
    if (_anchorRect != null && config?.anchor?.isMounted == false) {
      //config?.onAnchorUnmount?.call();
    }
    debugger();
  }
}
