part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/15
///
/// 悬停效果/焦点效果混入
/// 使用[buildHoverWidgetMixin]包裹目标小部件
/// 使用[buildHoverDecorationMixin]创建对应的状态装饰器
mixin HoverStateMixin<T extends StatefulWidget> on State<T> {
  /// 是否处于焦点状态
  /// 优先判断此状态
  bool isFocusStateMixin = false;

  /// 是否处于悬停状态
  bool isHoverStateMixin = false;

  /// 焦点节点
  FocusNode? hoverFocusNodeMixin;

  @override
  void initState() {
    hoverFocusNodeMixin ??= FocusNode();
    hoverFocusNodeMixin?.addListener(onHoverFocusChangedMixin);
    super.initState();
  }

  /// 焦点状态发生变化
  void onHoverFocusChangedMixin() {
    isFocusStateMixin = hoverFocusNodeMixin?.hasFocus == true;
    _tryUpdateState();
  }

  @override
  void dispose() {
    hoverFocusNodeMixin?.dispose(); // 释放 FocusNode
    super.dispose();
  }

  /// 包裹目标小部件
  @callPoint
  Widget buildHoverWidgetMixin(BuildContext context, Widget child) {
    return child.mouse(
      onEnter: (event) {
        isHoverStateMixin = true;
        _tryUpdateState(true);
      },
      onExit: (event) {
        isHoverStateMixin = false;
        _tryUpdateState(true);
      },
    );
  }

  /// 创建对应的状态装饰器
  @callPoint
  Decoration? buildHoverDecorationMixin(
    BuildContext context, {
    double? radius = kDefaultBorderRadiusL,
  }) {
    final globalTheme = GlobalTheme.of(context);
    if (isFocusStateMixin) {
      return strokeDecoration(
        color: globalTheme.accentColor,
        radius: radius,
      );
    }
    if (isHoverStateMixin) {
      return fillDecoration(
        color: globalTheme.pressColor,
        radius: radius,
      );
    }
    return null;
  }

  //--

  /// 尝试更新界面
  void _tryUpdateState([bool post = false]) {
    final state = this;
    (state as State).updateState(post: post);
  }
}
