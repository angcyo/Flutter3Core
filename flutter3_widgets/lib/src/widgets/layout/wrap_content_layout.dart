part of '../../../flutter3_widgets.dart';

///
/// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/20
///
/// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
/// [child] 的约束永远都不会超过自身的约束
///
/// - [CustomScrollView] 在此小部件中wrap会异常.
///
class WrapContentLayout extends SingleChildRenderObjectWidget {
  /// 夹紧[child], 如果[child]使用[wrap_content]测量出的大小不超过自身的约束, 则使用[child]的大小
  /// 如果超过自身的约束, 则使用自身的约束重新测量[child]
  final bool tightChild;

  /// 是否使用[child]的宽度设置自身的宽度
  final bool wrapWidth;

  /// 是否使用[child]的高度设置自身的高度
  final bool wrapHeight;

  /// 对齐方式
  final AlignmentGeometry alignment;

  /// 指定最小的宽度, 不指定则使用[child]的宽度
  /// [BoxConstraints.minWidth]
  final double? minWidth;
  final double? minHeight;

  final String? debugLabel;

  const WrapContentLayout({
    super.key,
    super.child,
    this.tightChild = true,
    this.wrapWidth = false,
    this.wrapHeight = false,
    this.alignment = AlignmentDirectional.center,
    this.minWidth,
    this.minHeight,
    this.debugLabel,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => WrapContentBox(
        tightChild: tightChild,
        wrapWidth: wrapWidth,
        wrapHeight: wrapHeight,
        alignment: alignment,
        textDirection: Directionality.of(context),
        minWidth: minWidth,
        minHeight: minHeight,
        debugLabel: debugLabel,
      );

  @override
  void updateRenderObject(BuildContext context, WrapContentBox renderObject) {
    renderObject
      ..tightChild = tightChild
      ..wrapWidth = wrapWidth
      ..wrapHeight = wrapHeight
      ..alignment = alignment
      ..minWidth = minWidth
      ..minHeight = minHeight
      ..debugLabel = debugLabel
      ..markNeedsLayout();
  }
}

/// [rebuild]->[performRebuild]->[updateChild]->[inflateWidget]->
/// [mount]->[attachRenderObject]->[insertRenderObjectChild].(renderObject.child = child;)
/// [RenderObjectWithChildMixin.child]
/// 要自己实现位置偏移需要考虑, 绘制时的偏移和点击事件的偏移
/// [RenderShiftedBox.paint]实现绘制上的偏移
/// [RenderShiftedBox.hitTestChildren]实现点击事件的偏移
class WrapContentBox extends RenderAligningShiftedBox {
  bool tightChild;
  bool wrapWidth;
  bool wrapHeight;
  double? minWidth;
  double? minHeight;

  String? debugLabel;

  WrapContentBox({
    super.alignment,
    super.textDirection,
    this.tightChild = true,
    this.wrapWidth = false,
    this.wrapHeight = false,
    this.minWidth,
    this.minHeight,
    this.debugLabel,
  });

  @override
  bool get sizedByParent => super.sizedByParent;

  /// [sizedByParent] 为true时, 才会调用此方法
  @override
  void performResize() {
    super.performResize();
  }

  /// [ParentData]只是用来存储测量数据的, 没有逻辑
  /// [RenderBox.setupParentData]
  /// [BoxParentData]
  ///
  /// [RenderProxyBoxMixin.setupParentData]
  @override
  void setupParentData(covariant RenderObject child) {
    //这里不能调用super, 因为会在[RenderProxyBoxMixin.setupParentData]中重置为[ParentData]
    //var parentData = child.parentData;
    //debugger();
    super.setupParentData(child);
    /*if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }*/
  }

  /// [performResize]中触发此方法
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return super.computeDryLayout(constraints);
  }

  /// 最终还是会调用 [computeDryLayout]
  @override
  Size getDryLayout(BoxConstraints constraints) {
    return super.getDryLayout(constraints);
  }

  /// 对齐子元素, 通过修改[child!.parentData]这样的方式手势碰撞就会自动计算
  void _alignChild() {
    alignChildOffset(alignment, size, child: child);
  }

  void _setSize(Size childSize) {
    //debugger();
    final double width, height;
    if (wrapWidth || constraints.maxWidth == double.infinity) {
      width = childSize.width;
    } else {
      width = constraints.maxWidth;
    }
    if (wrapHeight || constraints.maxHeight == double.infinity) {
      height = childSize.height;
    } else {
      height = constraints.maxWidth;
    }
    size = constraints.constrain(Size(width, height));
    //debugger();
    _alignChild();
  }

  @override
  void performLayout() {
    debugger(when: debugLabel != null);
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
    } else {
      //在可以滚动的布局中, maxWidth和maxHeight会是无限大
      final constraints = this.constraints;
      final parent = this.parent;
      final parentConstraints = parent?.constraints;
      double parentMaxWidth = double.infinity;
      double parentMaxHeight = double.infinity;

      if (tightChild) {
        if (constraints.maxWidth == double.infinity) {
          parentMaxWidth = double.infinity;
        } else {
          parentMaxWidth = constraints.maxWidth;
        }
        if (constraints.maxHeight == double.infinity) {
          parentMaxHeight = double.infinity;
        } else {
          parentMaxHeight = constraints.maxHeight;
        }
      } else if (parent is RenderBox && parent.hasSize) {
        if (constraints.maxWidth == double.infinity) {
          parentMaxWidth = parent.size.width;
        }
        if (constraints.maxHeight == double.infinity) {
          parentMaxHeight = parent.size.height;
        }
      } else if (parentConstraints is BoxConstraints) {
        parentMaxWidth = parentConstraints.maxWidth;
        parentMaxHeight = parentConstraints.maxHeight;
      }

      final maxWidth = constraints.maxWidth == double.infinity
          ? parentMaxWidth
          : constraints.maxWidth;
      final maxHeight = constraints.maxHeight == double.infinity
          ? parentMaxHeight
          : constraints.maxHeight;

      if (tightChild) {
        //关键布局
        child.layout(BoxConstraints(), parentUsesSize: true);
        final childSize = child.size;
        debugger(when: debugLabel != null);
        if (childSize.width <= maxWidth && childSize.height <= maxHeight) {
          _setSize(childSize);
          return;
        }
      }

      //debugger();
      final innerConstraints = BoxConstraints(
        minWidth: minWidth ?? 0,
        minHeight: minHeight ?? 0,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      child.layout(innerConstraints, parentUsesSize: true);
      _setSize(child.size);
    }
  }

  /// 由[paint]调用
  @override
  bool paintsChild(covariant RenderObject child) {
    return super.paintsChild(child);
  }

  /// 最终调用[paintsChild]
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }
}

extension WrapContentLayoutEx on Widget {
  /// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
  /// [wrapBoth] 同时设置2个值
  /// [wrapWidth]  自身的宽度是否和[child]的宽度一致
  /// [MatchParentLayoutEx.matchParent]
  /// [WrapContentLayoutEx.wrapContent]
  WrapContentLayout wrapContent({
    bool tightChild = true,
    bool? wrapBoth,
    bool wrapWidth = false,
    bool wrapHeight = false,
    AlignmentGeometry alignment = AlignmentDirectional.center,
    double? minWidth,
    double? minHeight,
    String? debugLabel,
  }) =>
      WrapContentLayout(
        tightChild: tightChild,
        wrapWidth: wrapBoth ?? wrapWidth,
        wrapHeight: wrapBoth ?? wrapHeight,
        alignment: alignment,
        minWidth: minWidth,
        minHeight: minHeight,
        debugLabel: debugLabel,
        child: this,
      );

  /// [wrapContent]
  /// [wrapContentWidth]
  /// [wrapContentHeight]
  WrapContentLayout wrapContentWidth({
    bool tightChild = true,
    bool wrapWidth = true,
    bool wrapHeight = false,
    AlignmentGeometry alignment = AlignmentDirectional.center,
    double? minWidth,
    double? minHeight,
    String? debugLabel,
  }) =>
      wrapContent(
        tightChild: tightChild,
        wrapWidth: wrapWidth,
        wrapHeight: wrapHeight,
        alignment: alignment,
        minWidth: minWidth,
        minHeight: minHeight,
        debugLabel: debugLabel,
      );

  /// [wrapContent]
  /// [wrapContentWidth]
  /// [wrapContentHeight]
  WrapContentLayout wrapContentHeight({
    bool tightChild = true,
    bool wrapWidth = false,
    bool wrapHeight = true,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    double? minWidth,
    double? minHeight,
    String? debugLabel,
  }) =>
      wrapContent(
        tightChild: tightChild,
        wrapWidth: wrapWidth,
        wrapHeight: wrapHeight,
        alignment: alignment,
        minWidth: minWidth,
        minHeight: minHeight,
        debugLabel: debugLabel,
      );
}
