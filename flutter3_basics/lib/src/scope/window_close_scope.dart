part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/23
///
/// 提供一个窗口关闭的监听域
/// - 顶层触发窗口关闭事件
/// - 子层可以拦截关闭事件, 并执行相应的操作

/// 窗口关闭时, 提供的数据
class WindowCloseData {
  /// 是否可以默认处理
  bool canDefaultHandle = true;

  WindowCloseData({this.canDefaultHandle = true});
}

/// 窗口关闭监听域
class WindowCloseScope extends InheritedWidget {
  /// 获取需要打开的数据
  @api
  static UpdateValueNotifier<WindowCloseData?>? get(
    BuildContext? context, {
    bool depend = false,
  }) {
    if (depend) {
      return context
          ?.dependOnInheritedWidgetOfExactType<WindowCloseScope>()
          ?.closeSignal;
    } else {
      return context
          ?.getInheritedWidgetOfExactType<WindowCloseScope>()
          ?.closeSignal;
    }
  }

  /// 触发一个窗口关闭信号
  static WindowCloseData trigger(BuildContext? context, WindowCloseData data) {
    final scope = context?.getInheritedWidgetOfExactType<WindowCloseScope>();
    scope?.closeSignal.updateValue(data);
    return data;
  }

  //MARK:  - scope

  /// 关闭信号监听
  final UpdateValueNotifier<WindowCloseData?> closeSignal;

  WindowCloseScope({
    super.key,
    UpdateValueNotifier<WindowCloseData?>? closeSignal,
    required super.child,
  }) : closeSignal = closeSignal ?? UpdateValueNotifier<WindowCloseData?>(null);

  @override
  bool updateShouldNotify(covariant WindowCloseScope oldWidget) =>
      closeSignal.value != oldWidget.closeSignal.value;
}

//MARK: - ex

extension WindowCloseScopeEx on Widget {
  /// 提供一个窗口关闭的监听[WindowCloseData]
  /// - 监听这个值, 并且处理对应的数据
  /// 配合[WindowCloseScopeStateMixin]使用
  Widget provideWindowCloseSignal({
    Key? key,
    UpdateValueNotifier<WindowCloseData?>? closeSignal,
  }) => WindowCloseScope(closeSignal: closeSignal, key: key, child: this);
}

mixin WindowCloseScopeStateMixin<T extends StatefulWidget> on State<T> {
  /// 需要监听的数据
  UpdateValueNotifier<WindowCloseData?>? windowCloseDataMixin;

  /// 当前终端是否是最后一个处理器
  bool get isLastWindowCloseHandler =>
      windowCloseDataMixin?.lastListener == handleWindowCloseDataMixin;

  @override
  void initState() {
    super.initState();
    windowCloseDataMixin = WindowCloseScope.get(buildContext);
    windowCloseDataMixin?.addListener(handleWindowCloseDataMixin);
  }

  @override
  void dispose() {
    windowCloseDataMixin?.removeListener(handleWindowCloseDataMixin);
    super.dispose();
  }

  /// 处理窗口关闭数据
  @callPoint
  void handleWindowCloseDataMixin() {
    final data = windowCloseDataMixin?.value;
    if (data != null) {
      onHandleWindowCloseDataMixin(data);
    }
  }

  /// 处理窗口关闭数据
  @overridePoint
  void onHandleWindowCloseDataMixin(WindowCloseData data) {
    if (buildContext?.isAppBarDismissal == true ||
        buildContext?.isPopupRoute == true) {
      data.canDefaultHandle = false;
      buildContext?.maybePop();
    }
  }
}
