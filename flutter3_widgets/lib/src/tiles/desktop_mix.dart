part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/12
///
/// 桌面相关混合操作类

/// 自动管理桌面Popup弹窗混入
/// - [DesktopTextMenuTile]
/// - [SingleDesktopGridTile]
///
/// - [wrapShowPopupMixin]
@desktopLayout
mixin DesktopPopupStateMixin<T extends StatefulWidget> on State<T> {
  /// 当前是否显示了弹窗
  bool isShowPopupMixin = false;

  /// 卸载时, 自动移除弹窗
  /// - 此功能需要[widget]指定[Key]
  /// - 需要[LocalLocationWidget]组件支持
  bool autoRemovePopupMixin = true;

  /// 当前元素的位置监听, 卸载时, 自动移除弹窗
  /// - [autoRemovePopupMixin]
  final ValueNotifier<Rect?> locationNotifierMixin = ValueNotifier(null);

  @override
  void initState() {
    //debugger();
    locationNotifierMixin.addListener(() {
      //debugger(when: locationNotifier.value == null);
      if (locationNotifierMixin.value == null || buildContext == null) {
        //unmount
        if (autoRemovePopupMixin && isShowPopupMixin) {
          //debugger();
          $nextFrame(() {
            GlobalConfig.def.findNavigatorState()?.pop();
            isShowPopupMixin = false;
          });
          //buildContext?.pop();
        }
      }
    });
    super.initState();
  }

  /// 包裹一个用来显示弹窗的操作
  @api
  Future wrapShowPopupMixin(FutureOr Function() action) async {
    isShowPopupMixin = true;
    updateState();
    final result = await action();
    isShowPopupMixin = false;
    updateState();
    return result;
  }
}
