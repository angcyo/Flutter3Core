part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/25
///
/// 滚轮选择器[WheelPicker]
/// 使用[ListWheelScrollView]底层实现
/// [CupertinoPicker]
///
/// [list_wheel_scroll_view_nls: ^0.0.3] 支持横向
/// https://pub.dev/packages/list_wheel_scroll_view_nls
class Wheel extends StatelessWidget {
  /// 是否循环
  final bool looping;

  /// 选中的颜色
  final Color? selectedIndexColor;

  /// 滚轮宽高
  final double size;

  /// 滚轮项高度
  final double itemExtent;

  /// 滚轮选项
  final Widget Function(BuildContext context, int index)? builder;
  final WidgetList? children;

  /// 滚轮控制器
  final WheelPickerController? _controller;
  final int initialIndex;

  /// 滚动回调
  final void Function(int index, WheelPickerInteractionType interactionType)?
      onIndexChanged;

  /// 是否激活选中颜色
  final bool enableSelectedIndexColor;

  Wheel({
    super.key,
    this.builder,
    this.children,
    this.size = 150,
    this.itemExtent = 30,
    this.looping = false,
    this.enableSelectedIndexColor = true,
    this.initialIndex = 0,
    this.selectedIndexColor,
    this.onIndexChanged,
    WheelPickerController? controller,
  }) : _controller = controller == null
            ? (children != null
                ? WheelPickerController(
                    itemCount: children.length, initialIndex: initialIndex)
                : null)
            : null;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final wheelStyle = WheelPickerStyle(
      /*size: size,*/
      itemExtent: itemExtent,
      // Text height
      // 上下挤压系数
      squeeze: 1.2,
      // 直径比例, 值越小 圆越小
      diameterRatio: 1.4,
      // 未选中的不透明度, 值越小越透明
      surroundingOpacity: .25,
      // 放大倍数
      magnification: 1.1,
    );
    return WheelPicker(
      builder: builder ??
          (context, index) {
            return children?.getOrNull(index) ?? empty;
          },
      controller: _controller,
      selectedIndexColor: enableSelectedIndexColor
          ? selectedIndexColor ?? globalTheme.accentColor
          : null,
      looping: looping,
      style: wheelStyle,
      onIndexChanged: onIndexChanged ??
          (index, type) {
            assert(() {
              l.d("Wheel选中索引[$type]:$index");
              return true;
            }());
          },
    );
  }
}
