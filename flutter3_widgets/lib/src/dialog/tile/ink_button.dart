part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/23
///
/// 可以需要在外层包裹[Material]
class InkButton extends StatelessWidget {
  final double? minWidth;
  final double? minHeight;
  final Widget? child;
  final GestureTapCallback? onTap;
  final bool isCircleWell;
  final EdgeInsetsGeometry? padding;
  final bool enable;
  final Color? splashColor;

  const InkButton(
    this.child, {
    super.key,
    this.onTap,
    this.minWidth = kInteractiveHeight,
    this.minHeight = kInteractiveHeight,
    this.enable = true,
    this.isCircleWell = true,
    this.splashColor,
    this.padding = const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return child
            ?.colorFiltered(color: enable ? null : globalTheme.disableColor)
            .min(minWidth: minWidth, minHeight: minHeight, margin: padding)
            .inkWell(
              enable
                  ? () {
                      onTap?.call();
                    }
                  : null,
              customBorder: isCircleWell ? const CircleBorder() : null,
              splashColor: splashColor,
            )
            .material() ??
        empty;
  }
}
