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
  /// 实现当[locationNotifierMixin]锚点位置发生变化时, 自动关闭弹窗
  @output
  bool isShowPopupMixin = false;

  /// 卸载时, 自动移除弹窗
  /// - 此功能需要[widget]指定[Key]
  /// - 需要[LocalLocationWidget]组件支持
  bool autoRemovePopupMixin = true;

  /// 当前元素的位置监听, 卸载时, 自动移除弹窗
  /// - [autoRemovePopupMixin]
  final ValueNotifier<Rect?> locationNotifierMixin = ValueNotifier(null);

  /// 记录最后一次的位置
  @output
  @tempFlag
  Rect? _lastLocation;

  @override
  void initState() {
    //debugger();
    locationNotifierMixin.addListener(() {
      //debugger(when: locationNotifier.value == null);
      final location = locationNotifierMixin.value;
      assert(() {
        l.d("[${classHash()}]位置发生改变:$location $isShowPopupMixin");
        return true;
      }());
      if (location == null) {
        //unmount 被移除
        popPopupMixin();
      } else {
        if (_lastLocation == null) {
          _lastLocation = location;
        } else if (_lastLocation != location) {
          //位置发生改变
          popPopupMixin();
        }
      }
    });
    super.initState();
  }

  /// 弹出弹窗
  @api
  void popPopupMixin() {
    if (autoRemovePopupMixin && isShowPopupMixin) {
      if (buildContext == null) {
        $nextFrame(() {
          GlobalConfig.def.findNavigatorState()?.pop();
          isShowPopupMixin = false;
        });
      } else {
        buildContext?.pop(rootNavigator: false);
        isShowPopupMixin = false;
      }
    }
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
