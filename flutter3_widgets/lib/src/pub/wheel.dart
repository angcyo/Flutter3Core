part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/25
///
/// 滚轮选择器
/// 使用[ListWheelScrollView]底层实现
class Wheel extends StatelessWidget {
  /// 是否循环
  final bool looping;

  /// 选中的颜色
  final Color? selectedIndexColor;

  /// 滚轮宽高
  final double width;
  final double height;

  /// 滚轮项高度
  final double itemExtent;

  /// 滚轮选项
  final Widget Function(BuildContext context, int index)? builder;
  final WidgetList? children;

  /// 滚轮控制器
  final WheelPickerController? _controller;
  final int initialIndex;

  /// 滚动回调
  final void Function(int index)? onIndexChanged;

  Wheel({
    super.key,
    this.builder,
    this.children,
    this.width = 50,
    this.height = 150,
    this.itemExtent = 30,
    this.looping = false,
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
      width: width,
      height: height,
      itemExtent: itemExtent,
      // Text height
      // 上下挤压系数
      squeeze: 1.25,
      // 直径比例, 值越小圆越小
      diameterRatio: .8,
      // 未选中的不透明度, 值越小越透明
      surroundingOpacity: .25,
      // 放大倍数
      magnification: 1.2,
    );

    return WheelPicker(
      builder: builder ??
          (context, index) {
            return children![index];
          },
      controller: _controller,
      selectedIndexColor: selectedIndexColor ?? globalTheme.accentColor,
      looping: looping,
      style: wheelStyle,
      onIndexChanged: onIndexChanged ??
          (index) {
            l.d("选中索引:$index");
          },
    );
  }
}
