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

  const InkButton(
    this.child, {
    super.key,
    this.onTap,
    this.minWidth = kInteractiveHeight,
    this.minHeight = kInteractiveHeight,
    this.isCircleWell = true,
    this.padding = const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
  });

  @override
  Widget build(BuildContext context) {
    return child
            ?.min(minWidth: minWidth, minHeight: minHeight, margin: padding)
            .inkWell(
          () {
            onTap?.call();
          },
          customBorder: isCircleWell ? const CircleBorder() : null,
        ).material() ??
        empty;
  }
}
