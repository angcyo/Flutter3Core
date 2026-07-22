part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/30
///
/// 底部菜单tile
/// [BottomMenuItemsDialog]
class BottomMenuItemTile extends StatelessWidget {
  /// [children]布局方向
  final Axis direction;

  /// [Row]children
  final WidgetNullList? children;

  /// [children]
  @indirectProperty
  final Widget? child;

  /// 主轴对齐
  final MainAxisAlignment? mainAxisAlignment;

  //--

  /// 背景色, 不指定使用默认
  final Color? backgroundColor;

  /// 是否可用
  final bool enable;

  /// 激活时的过滤颜色
  final Color? filterColor;

  /// 禁用时的背景色, 不指定使用默认
  /// 可用, 则使用原色
  final Color? disableFilterColor;

  /// 点击事件
  final FutureVoidAction? onTap;

  /// 点击后, 关闭对话框
  final bool closeAfterTap;

  /// [closeAfterTap] 关闭对话框时的返回值
  final dynamic popResult;

  const BottomMenuItemTile({
    super.key,
    this.direction = .horizontal,
    this.children,
    this.child,
    this.mainAxisAlignment,
    //--
    this.onTap,
    this.enable = true,
    this.closeAfterTap = true,
    this.backgroundColor,
    this.filterColor,
    this.disableFilterColor,
    this.popResult,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final list = (children ?? [child]);
    final body = direction == .horizontal
        ? list.row(
            gap: kH,
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          )!
        : list.column(
            gap: kH,
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          )!;
    return body
        .colorFiltered(
          color: enable
              ? filterColor
              : (disableFilterColor ?? filterColor ?? globalTheme.disableColor),
        )
        .paddingAll(kX)
        .constrainedMin(minHeight: kMinInteractiveDimension)
        .ink(() async {
          if (closeAfterTap) {
            context.pop(result: popResult);
          }
          await onTap?.call();
        }, enable: enable)
        .material(color: backgroundColor ?? globalTheme.surfaceBgColor);
  }
}
