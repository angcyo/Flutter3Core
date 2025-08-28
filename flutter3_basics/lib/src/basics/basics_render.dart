part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// --[ContainerRenderObjectMixin]--
/// [ContainerRenderObjectMixin]  渲染一组[RenderObject]
/// [ContainerRenderObjectMixin.childCount]
/// [ContainerRenderObjectMixin._firstChild]
/// [ContainerRenderObjectMixin._lastChild]
/// [ContainerRenderObjectMixin.add]
/// [ContainerRenderObjectMixin.insert]
///
/// [ContainerParentDataMixin]
///
/// [RenderObjectElement.mount]->[RenderObjectElement.attachRenderObject]->
/// [MultiChildRenderObjectElement.insertRenderObjectChild]->[ContainerRenderObjectMixin.insert]
///
/// --[RenderObjectWithChildMixin]--
/// [RenderObjectWithChildMixin] 渲染一个[RenderObject]
/// [RenderObjectWithChildMixin.child]
///
/// [RenderObjectElement.mount]->[RenderObjectElement.attachRenderObject]->
/// [SingleChildRenderObjectElement.insertRenderObjectChild]->[RenderObjectWithChildMixin.child]
///
extension ContainerRenderObjectMixinEx<ChildType extends RenderObject,
        ParentDataType extends ContainerParentDataMixin<ChildType>>
    on ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// 可以使用`for in`语法遍历所有的子元素
  /// [ContainerRenderObjectMixin]
  /// [RenderBox]
  Iterable<ChildType> get childrenIterable sync* {
    ChildType? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  /// [childrenIterable]
  List<ChildType> get childrenList => childrenIterable.toList();

  /// 绘制时的遍历对象
  Iterable<ChildType> get childrenInPaintOrderIterable sync* {
    ChildType? child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child);
    }
  }

  /// [childrenInPaintOrderIterable]
  List<RenderObject> get childrenInPaintOrderList =>
      childrenInPaintOrderIterable.toList();
}

extension RenderObjectMixinEx on RenderObject {
  /// 遍历当前渲染对象的所有子元素
  /// `sync*`.`async*`
  Iterable<RenderObject> get childrenList sync* {
    RenderObject? child;
    if (this is ContainerRenderObjectMixin) {
      child = (this as ContainerRenderObjectMixin).firstChild;
      while (child != null) {
        yield child;
        child = (this as ContainerRenderObjectMixin?)?.childAfter(child);
      }
    }
  }

  /// 是否具有大小, 通常在进行了[RenderObject.layout]后才有值
  bool get hasRenderSize {
    if (this is RenderBox) {
      try {
        return (this as RenderBox).hasSize;
      } catch (e) {
        assert(() {
          l.e(e);
          //printError(e);
          return true;
        }());
        return false;
      }
    }
    return false;
  }

  /// 尝试获取[RenderObject]的大小, 只有[parent]才能合理的获取[ui.Size]否则会警告.
  /// ```
  /// RenderBox.size accessed beyond the scope of resize, layout, or permitted parent access.
  /// RenderBox can always access its own size, otherwise,
  /// the only object that is allowed to read RenderBox.size is its parent,
  /// if they have said they will. It you hit this assert trying to access a child's size,
  /// pass "parentUsesSize: true" to that child's layout().
  /// ```
  Size? get renderSize {
    if (this is RenderBox) {
      try {
        if ((this as RenderBox).hasSize) {
          return (this as RenderBox).size;
        }
      } catch (e) {
        assert(() {
          l.e(e);
          //printError(e);
          return true;
        }());
        return null;
      }
    }
    return null;
  }

  /// 尝试获取[RenderObject]的位置
  Offset? get renderGlobalOffset {
    if (this is RenderBox) {
      try {
        return (this as RenderBox).localToGlobal(Offset.zero);
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        return null;
      }
    }
    return null;
  }

  /// 尝试获取[RenderObject]的偏移位置
  Offset? get renderParentOffset {
    if (this is RenderBox) {
      try {
        return ((this as RenderBox).parentData as BoxParentData?)?.offset;
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        return null;
      }
    }
    return null;
  }

  /// 测量一下渲染对象的大小大小, 并尝试返回
  /// ```
  /// (RenderObject.debugActiveLayout == parent && size._canBeUsedByParent)':
  /// RenderBox.size accessed beyond the scope of resize, layout, or permitted parent access.
  /// RenderBox can always access its own size, otherwise,
  /// the only object that is allowed to read RenderBox.size is its parent,
  /// if they have said they will. It you hit this assert trying to access a child's size,
  /// pass "parentUsesSize: true" to that child's layout().
  /// ```
  Size? measureRenderSize({
    Constraints constraints = const BoxConstraints(),
    bool parentUsesSize = false,
  }) {
    if (this is RenderBox && constraints is BoxConstraints) {
      return (this as RenderBox).getDryLayout(constraints);
    }
    //layout(constraints, parentUsesSize: parentUsesSize);
    return renderSize;
  }

  /// 裁剪图层
  /// [PaintingContext.pushClipRect]
  /// [ClipRectLayer]
  void pushClipRectLayer(PaintingContext context, Offset offset, Rect clipRect,
      PaintingContextCallback painter,
      {Clip clipBehavior = Clip.hardEdge, ClipRectLayer? oldLayer}) {
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      clipRect,
      painter,
      clipBehavior: clipBehavior,
      oldLayer: oldLayer ?? layer as ClipRectLayer?,
    );
  }
}

/// [RenderBox]
extension RenderBoxEx on RenderBox {
  /// 当前盒子在父级中的偏移
  Offset get offset => parentData is BoxParentData
      ? (parentData as BoxParentData).offset
      : Offset.zero;

  /// 调试模式下, 绘制盒子的边界
  /// [debugDrawBoxBounds]
  void debugPaintBoxBounds(PaintingContext context, Offset offset) =>
      debugDrawBoxBounds(context, offset);

  /// 绘制盒子的边界
  void debugDrawBoxBounds(PaintingContext context, Offset offset) {
    assert(() {
      context.canvas.drawRect(
        offset & size,
        Paint()
          ..color = Colors.purpleAccent
          ..strokeWidth = 4
          ..style = ui.PaintingStyle.stroke,
      );
      return true;
    }());
  }

  /// 获取内部[RenderBox]对应的方向, 如果有
  /// [RenderFlex.direction]
  Axis? findChildAxis() {
    Axis? axis;
    eachVisitChildRenderObject((child, _, __) {
      if (child is RenderFlex) {
        axis = child.direction;
        return false;
      }
      return true;
    });
    return axis;
  }

  /// 可以访问的child数量
  /// 通过[RenderObject.visitChildren]获取child的数量
  int get visitChildCount {
    int count = 0;
    visitChildren((child) {
      count++;
    });
    return count;
  }

  /// 访问所有[RenderBox]的child
  /// [RenderObject.visitChildren]
  /// [visitChildrenBox]
  /// [visitChildrenBoxIndex]
  void visitChildrenBox(RenderBoxVisitor visitor) {
    visitChildren((child) {
      if (child is RenderBox) {
        visitor(child);
      }
    });
  }

  /// index:第几个child
  void visitChildrenBoxIndex(RenderBoxIndexVisitor visitor) {
    int index = 0;
    visitChildren((child) {
      if (child is RenderBox) {
        visitor(child, index);
      }
      index++;
    });
  }
}

typedef RenderBoxVisitor = void Function(RenderBox child);
typedef RenderBoxIndexVisitor = void Function(RenderBox child, int index);

/// [RenderBoxContainerDefaultsMixin]
extension RenderBoxContainerDefaultsMixinEx on RenderBoxContainerDefaultsMixin {
  /// 访问所有child
  /// [RenderObject.visitChildren]
  /*void visitChildren(RenderObjectVisitor visitor) {
    RenderObject? child = firstChild;
    while (child != null) {
      visitor(child);
      final childParentData = child.parentData;
      if (childParentData is ContainerParentDataMixin) {
        child = childParentData.nextSibling;
      }
    }
  }*/
}
