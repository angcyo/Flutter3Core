part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///
/// 数字键盘输入对话框
class NumberKeyboardDialog extends StatelessWidget {
  const NumberKeyboardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = 6.0;
    return FlowLayout(
      selfConstraints: const LayoutBoxConstraints(
        wrapContentWidth: true,
        wrapContentHeight: true,
      ),
      childConstraints: const BoxConstraints(minHeight: 40),
      childGap: gap,
      enableEqualWidth: true,
      lineMaxChildCount: 4,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StateDecorationWidget(
          decoration: fillDecoration(fillColor: Colors.redAccent),
          child: "1".text().align(Alignment.center),
        ),
        StateDecorationWidget(
          decoration: fillDecoration(fillColor: Colors.redAccent),
          child: "2".text().align(Alignment.center),
        ),
        StateDecorationWidget(
          decoration: fillDecoration(fillColor: Colors.redAccent),
          child: "3".text().align(Alignment.center),
        ),
        StateDecorationWidget(
          decoration: fillDecoration(fillColor: Colors.redAccent),
          child: "4".text().align(Alignment.center),
        ),
        StateDecorationWidget(
          decoration: fillDecoration(fillColor: Colors.redAccent),
          child: "5".text().align(Alignment.center),
        ),
        StateDecorationWidget(
          decoration: fillDecoration(fillColor: Colors.redAccent),
          child: "6".text().align(Alignment.center),
        ),
        FlowLayoutData(child: "21312312".text()),
      ],
    );
  }
}
