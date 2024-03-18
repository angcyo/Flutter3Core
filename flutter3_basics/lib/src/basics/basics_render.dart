part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

extension ContainerRenderObjectMixinEx<ChildType extends RenderObject,
        ParentDataType extends ContainerParentDataMixin<ChildType>>
    on ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// 可以使用`for in`语法遍历所有的子元素
  /// [ContainerRenderObjectMixin]
  /// [RenderBox]
  Iterable<RenderObject> get childrenList sync* {
    RenderObject? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child as ChildType);
    }
  }

  /// 绘制时的遍历对象
  Iterable<RenderObject> get childrenInPaintOrderList sync* {
    RenderObject? child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child as ChildType);
    }
  }
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

  /// 尝试获取[RenderObject]的大小
  Size? get renderSize {
    if (this is RenderBox) {
      try {
        if ((this as RenderBox).hasSize) {
          return (this as RenderBox).size;
        }
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
}
