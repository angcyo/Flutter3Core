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
    return FlowLayout(
      children: [
        "1123123123".text(),
        FlowLayoutData(child: "21312312".text()),
      ],
    );
  }
}
