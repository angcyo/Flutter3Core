part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// 屏幕布局混入
/// - 支持在page中显示
/// - 支持在dialog中显示
/// - 支持在popup中显示
/// - 支持在overlay中显示
///
/// - [DialogMixin]
mixin ScreenMixin implements TranslationTypeImpl {
  //MARK: - TranslationTypeImpl

  /// [Dialog]对话框外点击是否关闭
  @override
  bool get dialogBarrierDismissible => true;

  @override
  Color? get dialogBarrierColor => null;

  @override
  bool get dialogUseRootNavigator => true;

  /// 对话框路径过度动画
  @override
  TranslationType get translationType {
    final type = runtimeType.toString().toLowerCase();
    //debugger();
    if (type.isScreenName) {
      return .translation;
    }
    if (type.contains("desktop")) {
      return .scaleFade;
    }
    if (type.contains("bottom")) {
      return .translationFade;
    }
    /*if (isDesktopOrWeb) {
      //桌面从右到左滑动
      if (adaptiveDialogDesktopSlideStyle == null && type.contains("slide")) {
        return .slide;
      }
      if (adaptiveDialogDesktopSlideStyle != null &&
          adaptiveDialogDesktopSlideStyle == true) {
        return .slide;
      }
    }*/
    return isDesktopOrWeb ? .scaleFade : .translationFade;
  }

  @override
  Alignment? get preferredFollowerAlignment => .bottomCenter;
}
