part of '../../flutter3_pub_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/01
///
/// 跑马灯
extension MarqueeWidgetEx on Widget {
  /// 转换成跑马灯
  /// - [interaction] 手势是否可以影响滚动?
  /// - [scrollablePointerIgnoring] 是否忽略滚动手势
  /// - [pps] 每秒像素数，控制滚动动画的速度。例如， pps: 15.0 表示每秒滚动 15 像素。
  /// - [infinity] ：一个 bool 用于确定滚动条到达列表末尾后的行为。启用后，将复制内容或反转动画。
  /// - [autoStart] ：一个 bool ，控制在构建小部件时跑马灯是否自动启动。
  ///
  /// ```
  /// "123".text().wrapContentHeight().toMarqueeWidget().bounds().rItemTile()
  /// ---
  /// "sadflkjsdfljsadlfjasdkfjlsd阿斯顿发斯蒂芬阿斯蒂芬拉水电费阿斯蒂芬萨达发斯蒂芬的"
  ///     .text()
  ///     .wrapContentHeight()
  ///     .click(() {
  ///       ydToast("click".text(useDefStyle: false));
  ///     })
  ///     .toMarqueeWidget()
  ///     .rItemTile()
  /// ```
  Widget toMarqueeWidget({
    bool infinity = false,
    bool autoStart = true,
    bool interaction = false,
  }) {
    return Marqueer(
      intrinsicCrossAxisSize: true,
      interaction: interaction,
      //如果启用，则在用户交互后自动重新启动滚动。
      restartAfterInteraction: true,
      infinity: infinity,
      scrollablePointerIgnoring: true,
      autoStart: autoStart,
      pps: 15.0,
      child: this,
    );
  }
}

extension MarqueeWidgetListEx on List<Widget> {
  /// 转换成跑马灯
  /// - [interaction]  ：如果 true ，则在用户触摸时暂停动画。
  /// - [intrinsicCrossAxisSize] ：根据子控件自动调整交叉轴的大小。无需使用 SizedBox 包装器。默认值为 false 。
  Widget toMarqueeWidget() {
    return Marqueer.builder(
      itemCount: length,
      interaction: true,
      intrinsicCrossAxisSize: true,
      scrollablePointerIgnoring: true,
      pps: 15.0,
      itemBuilder: (context, index) {
        return this[index % length];
      },
    );
  }
}
