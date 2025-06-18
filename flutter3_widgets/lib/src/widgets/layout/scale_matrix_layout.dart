part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a> \
/// @date 2025/06/14
///
/// 通过计算出一个[Matrix3], 然后将此[Matrix3]作用到所有child上
class ScaleMatrixContainerLayout extends MultiChildRenderObjectWidget {
  /// 使用最大的约束计算child的大小, 然后将其适应到容器, 得到一个[Matrix3]
  final BoxConstraints? refChildConstraints;

  /// 参考的child的索引,用来计算[Matrix3]
  final int? refChildIndex;

  //--

  /// 设置容器自身的宽高比, 不指定则不限制
  /// [AspectRatio]
  final double? aspectRatio;

  /// 处理手势事件
  /// [tx].[ty] 手势移动与手势按下时的偏移量
  final void Function(
    ScaleMatrixContainerRenderObject render,
    PointerEvent event,
    double tx,
    double ty,
  )? onHandlePointerEvent;

  const ScaleMatrixContainerLayout({
    super.key,
    super.children,
    this.refChildConstraints,
    this.refChildIndex = 0,
    this.aspectRatio,
    this.onHandlePointerEvent,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      ScaleMatrixContainerRenderObject(this);

  @override
  void updateRenderObject(
      BuildContext context, ScaleMatrixContainerRenderObject renderObject) {
    renderObject
      ..config = this
      ..markNeedsLayout();
  }
}

/// [ParentData]
///
/// 使用[ParentDataWidget]对[ParentData]进行赋值操作
class ScaleMatrixParentData extends ContainerBoxParentData<RenderBox> {
  /// 指定child的约束, 不指定则使用parent传递的约束
  LayoutBoxConstraints? childConstraints;

  /// child 在没有作用矩阵之前的偏移量
  Offset childOffset = Offset.zero;

  /// 和[childOffset]会一起生效
  /// ```
  /// offsetLeft = (pWidth - cWidth) * dxR
  /// offsetTop = (pHeight - cHeight) * dyR
  /// ```
  /// [0~1]
  Offset? childOffsetRadio;

  /// 是否作为参考的child
  /// [ScaleMatrixContainerLayout.refChildIndex]
  bool? isRefChild;

  /// 当前child是否忽略矩阵
  bool? ignoreTransform;

  //--

  /// [tag]
  String? tag;

  /// [childOffset]
  /// [childOffsetRadio]
  Offset getChildRadioOffset(Size parentSize, Size childSize) {
    if (childOffsetRadio != null) {
      return Offset(
        (parentSize.width - childSize.width) * childOffsetRadio!.dx,
        (parentSize.height - childSize.height) * childOffsetRadio!.dy,
      );
    }
    return Offset.zero;
  }
}

/// 用来修改[ScaleMatrixParentData]
class ScaleMatrixParentDataWidget
    extends ParentDataWidget<ScaleMatrixParentData> {
  const ScaleMatrixParentDataWidget({
    super.key,
    required super.child,
    this.childConstraints,
    this.childOffsetRadio,
    this.childOffset = Offset.zero,
    this.isRefChild,
    this.tag,
    this.ignoreTransform,
  });

  final LayoutBoxConstraints? childConstraints;
  final Offset childOffset;
  final Offset? childOffsetRadio;
  final bool? isRefChild;
  final bool? ignoreTransform;
  final String? tag;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is ScaleMatrixParentData);
    final parentData = renderObject.parentData as ScaleMatrixParentData;

    bool needsLayout = false;
    if (parentData.childConstraints != childConstraints) {
      parentData.childConstraints = childConstraints;
      needsLayout = true;
    }

    if (parentData.childOffset != childOffset) {
      parentData.childOffset = childOffset;
      needsLayout = true;
    }

    if (parentData.isRefChild != isRefChild) {
      parentData.isRefChild = isRefChild;
      needsLayout = true;
    }

    if (parentData.childOffsetRadio != childOffsetRadio) {
      parentData.childOffsetRadio = childOffsetRadio;
      needsLayout = true;
    }

    if (parentData.ignoreTransform != ignoreTransform) {
      parentData.ignoreTransform = ignoreTransform;
      needsLayout = true;
    }

    if (parentData.tag != tag) {
      parentData.tag = tag;
    }

    if (needsLayout) {
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => ScaleMatrixContainerLayout;
}

/// [RenderTransform]->[RenderObject]
/// [Transform]->[SingleChildRenderObjectWidget]
class ScaleMatrixContainerRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ScaleMatrixParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ScaleMatrixParentData> {
  @configProperty
  ScaleMatrixContainerLayout config;

  ScaleMatrixContainerRenderObject(this.config);

  //--

  /// 获取指定child的偏移量
  @api
  RenderBox? findChildByTag(String? tag) {
    RenderBox? child = lastChild;
    while (child != null) {
      // The x, y parameters have the top left of the node's box as the origin.
      final ScaleMatrixParentData childParentData =
          child.parentData! as ScaleMatrixParentData;
      if (childParentData.tag == tag) {
        return child;
      }
      child = childParentData.previousSibling;
    }
    return null;
  }

  /// 当前手势坐标是否命中某个child
  @api
  bool hitTestChild(String? tag, ui.Offset position) {
    RenderBox? child = findChildByTag(tag);
    if (child == null) {
      return false;
    }
    bool isHit = false;
    final result = BoxHitTestResult();
    result.addWithPaintTransform(
      transform: _effectiveTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        // The x, y parameters have the top left of the node's box as the origin.
        final ScaleMatrixParentData childParentData =
            child.parentData! as ScaleMatrixParentData;
        final childOffset = getChildOffset(child);
        isHit = result.addWithPaintOffset(
          offset: childOffset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childOffset);
            return child.hitTest(result, position: transformed);
          },
        );
        return isHit;
      },
    );
    return isHit;
  }

  //--

  /// 计算出来的矩阵
  Matrix4? _effectiveTransform;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ScaleMatrixParentData) {
      child.parentData = ScaleMatrixParentData();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required ui.Offset position}) {
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return super.hitTestSelf(position);
  }

  /// [defaultHitTestChildren]
  @override
  bool hitTestChildren(BoxHitTestResult result, {required ui.Offset position}) {
    return result.addWithPaintTransform(
      transform: _effectiveTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        RenderBox? child = lastChild;
        while (child != null) {
          // The x, y parameters have the top left of the node's box as the origin.
          final ScaleMatrixParentData childParentData =
              child.parentData! as ScaleMatrixParentData;

          final childOffset = getChildOffset(child);
          final bool isHit = result.addWithPaintOffset(
            offset: childOffset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              assert(transformed == position - childOffset);
              return child!.hitTest(result, position: transformed);
            },
          );
          if (isHit) {
            return true;
          }
          child = childParentData.previousSibling;
        }
        return false;
      },
    );
  }

  /// 手势按下时的位置
  Offset _downPosition = Offset.zero;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    super.handleEvent(event, entry);
    final position = event.localPosition;
    if (event.isPointerDown) {
      _downPosition = event.localPosition;
    }
    config.onHandlePointerEvent?.call(
      this,
      event,
      position.x - _downPosition.x,
      position.y - _downPosition.y,
    );
  }

  @override
  void performLayout() {
    BoxConstraints constraints = this.constraints;
    Size parentSize = constraints.biggest;

    final aspectRatio = config.aspectRatio;
    if (aspectRatio != null) {
      if (parentSize.width == double.infinity) {
        parentSize = Size(
          parentSize.height * aspectRatio,
          parentSize.height,
        );
      } else {
        parentSize = Size(
          parentSize.width,
          parentSize.width / aspectRatio,
        );
      }
      constraints = constraints.tighten(
        width: parentSize.width,
        height: parentSize.height,
      );
    }

    Size? refChildSize;
    int childIndex = 0;
    for (final child in childrenList) {
      final parentData = child.parentData as ScaleMatrixParentData;
      BoxConstraints childConstraints = parentData.childConstraints ??
          config.refChildConstraints ??
          BoxConstraints();

      if (childConstraints is LayoutBoxConstraints) {
        if (childConstraints.isMatchParent) {
          if (aspectRatio != null) {
            continue;
          }
          childConstraints = constraints;
        }
      }

      final drySize = child.getDryLayout(childConstraints);
      //debugger();
      if (drySize.isEmpty || !drySize.isFinite) {
        //重新测量
        child.layout(constraints, parentUsesSize: true);
      } else {
        child.layout(childConstraints, parentUsesSize: true);
      }
      //debugger();
      if (parentData.ignoreTransform != true) {
        if (childIndex == config.refChildIndex ||
            parentData.isRefChild == true) {
          refChildSize = child.size;
        }
      }
      childIndex++;
    }

    //计算矩阵
    if (refChildSize != null) {
      final sx = parentSize.width / refChildSize.width;
      final sy = parentSize.height / refChildSize.height;
      //debugger();
      _effectiveTransform = Matrix4.diagonal3Values(sx, sy, 1.0);
    } else {
      _effectiveTransform = null;
    }
    //debugger();

    //再次测量[MatchParent]的child
    if (aspectRatio != null) {
      final fixedConstraints = BoxConstraints.tight(parentSize);
      for (final child in childrenList) {
        final parentData = child.parentData as ScaleMatrixParentData;
        LayoutBoxConstraints? childConstraints = parentData.childConstraints;
        if (childConstraints?.isMatchParent == true) {
          child.layout(fixedConstraints);
        }
      }
    }

    size = parentSize;
  }

  /// [defaultPaint]
  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final Matrix4? transform = _effectiveTransform;
    if (transform != null) {
      final Offset? childOffset = MatrixUtils.getAsTranslation(transform);
      if (childOffset == null) {
        // if the matrix is singular the children would be compressed to a line or
        // single point, instead short-circuit and paint nothing.
        final double det = transform.determinant();
        if (det == 0 || !det.isFinite) {
          layer = null;
          return;
        }
        layer = context.pushTransform(
          needsCompositing,
          offset,
          transform,
          paintSelf,
          oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
        );
      } else {
        paintSelf(context, offset + childOffset);
        layer = null;
      }
    } else {
      paintSelf(context, offset);
    }
  }

  /// [paint]
  @entryPoint
  void paintSelf(PaintingContext context, ui.Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as ScaleMatrixParentData;
      final childOffset = getChildOffset(child);
      context.paintChild(child, offset + childOffset);
      child = childParentData.nextSibling;
    }
  }

  /// [getChildOffset]
  Offset getChildOffset(RenderBox child) {
    final childParentData = child.parentData! as ScaleMatrixParentData;
    final transform = _effectiveTransform?.invertedMatrix();
    final childOffset = childParentData.offset +
        childParentData.childOffset +
        childParentData.getChildRadioOffset(
          transform == null ? size : transform.mapSize(size),
          child.size,
        );
    return childOffset;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Matrix4? transform = _effectiveTransform;
    if (transform != null) {
      transform.multiply(transform);
    }
  }
}

/// [ScaleMatrixContainerLayout]
/// [ScaleMatrixParentDataWidget]
extension ScaleMatrixContainerWidgetEx on Widget {}
