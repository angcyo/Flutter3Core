part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/01
///
/// 画布小部件
class CanvasWidget extends LeafRenderObjectWidget {
  final CanvasDelegate canvasDelegate;

  const CanvasWidget(this.canvasDelegate, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) => CanvasRenderBox(
        context,
        canvasDelegate..delegateContext = context,
      );

  @override
  void updateRenderObject(BuildContext context, CanvasRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    canvasDelegate.delegateContext = context;
    renderObject
      ..context = context
      ..canvasDelegate = canvasDelegate
      ..markNeedsPaint();
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('canvasDelegate', canvasDelegate));
  }
}

/// 画布渲染
class CanvasRenderBox extends RenderBox {
  BuildContext context;
  CanvasDelegate canvasDelegate;

  CanvasRenderBox(
    this.context,
    this.canvasDelegate,
  );

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    double? width =
        constraints.maxWidth == double.infinity ? null : constraints.maxWidth;
    double? height =
        constraints.maxHeight == double.infinity ? null : constraints.maxHeight;
    size =
        Size(width ?? height ?? screenWidth, height ?? width ?? screenHeight);

    canvasDelegate.layout(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    canvasDelegate.paint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    var hitInterceptBox = GestureHitInterceptScope.of(context);
    hitInterceptBox?.interceptHitBox = this;
    canvasDelegate.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    canvasDelegate.repaint.addListener(_repaintListener);
    canvasDelegate.attach();
  }

  @override
  void detach() {
    super.detach();
    canvasDelegate.repaint.removeListener(_repaintListener);
    canvasDelegate.detach();
  }

  /// 重绘
  void _repaintListener() {
    markNeedsPaint();
  }
}

/// 坐标系
const viewCoordinate = AnnotationMeta('视图坐标的值, 以屏幕左上角为原点');
const sceneCoordinate = AnnotationMeta('场景坐标的值, 以内容坐标中心为原点');

/// 画布扩展方法
extension CanvasIterableEx on Iterable<ElementPainter> {
  /// [topLeft] 按照从上到下, 从左到右的顺序, 排序元素. 默认
  /// [leftTop] 按照从左到右, 从上到下的顺序, 排序元素
  List<ElementPainter> sortElement({
    bool resetElementAngle = true,
    bool? topLeft,
    bool? leftTop,
  }) {
    return toList()
      ..sort((a, b) {
        final aBounds = a.paintProperty?.getBounds(resetElementAngle);
        final bBounds = b.paintProperty?.getBounds(resetElementAngle);

        final aTop = aBounds?.top ?? 0;
        final bTop = bBounds?.top ?? 0;

        final aLeft = aBounds?.left ?? 0;
        final bLeft = bBounds?.left ?? 0;

        if (leftTop == true) {
          // 从左到右, 从上到下
          if (aLeft == bLeft) {
            return aTop.compareTo(bTop);
          }
          return aLeft.compareTo(bLeft);
        } else {
          // 从上到下, 从左到右
          if (aTop == bTop) {
            return aLeft.compareTo(bLeft);
          }
          return aTop.compareTo(bTop);
        }
      });
  }

  /// 获取所有单的[ElementPainter]
  /// [ElementPainter.getSingleElementList]
  List<ElementPainter> getAllSingleElement() {
    final result = <ElementPainter>[];
    for (var e in this) {
      result.addAll(e.getSingleElementList());
    }
    return result;
  }
}
