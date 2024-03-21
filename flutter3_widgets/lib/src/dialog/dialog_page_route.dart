part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24
///
/// 参考[DialogRoute]
class DialogPageRoute<T> extends RawDialogRoute<T> {
  DialogPageRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    CapturedThemes? themes,
    super.barrierColor = Colors.black54,
    super.barrierDismissible,
    String? barrierLabel,
    bool useSafeArea = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    //---新增的参数---
    Duration? transitionDuration,
    TranslationType? type,
  }) : super(
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            final Widget pageChild = Builder(builder: builder);
            Widget dialog = themes?.wrap(pageChild) ?? pageChild;
            if (useSafeArea) {
              dialog = SafeArea(child: dialog);
            }
            return dialog;
          },
          barrierLabel: barrierLabel ??
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration:
              transitionDuration ?? const Duration(milliseconds: 150),
          transitionBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            if (type?.withTranslation == true) {
              return TranslationPageRoute(
                      builder: (content) => child,
                      topToBottom: type?.withTopToBottom == true,
                      fade: type?.withFade == true)
                  .buildSameTransitions(
                      context, animation, secondaryAnimation, child);
            }
            if (type == TranslationType.fade) {
              return FadePageRoute(builder: (content) => child)
                  .buildSameTransitions(
                      context, animation, secondaryAnimation, child);
            }
            if (type == TranslationType.slide) {
              return SlidePageRoute(builder: (content) => child)
                  .buildSameTransitions(
                      context, animation, secondaryAnimation, child);
            }
            if (type == TranslationType.scale) {
              return ScalePageRoute(builder: (content) => child)
                  .buildSameTransitions(
                      context, animation, secondaryAnimation, child);
            }
            return buildMaterialDialogTransitions(
                context, animation, secondaryAnimation, child);
          },
        );
}

/// 系统默认的动画
/// [_buildMaterialDialogTransitions]
Widget buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}
