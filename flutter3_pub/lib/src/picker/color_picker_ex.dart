part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/15
///
/// 颜色选择扩展
extension ColorPickerEx on BuildContext {
  /// 颜色选择器/对话框
  ///
  /// [ColorPicker]
  /// [MaterialPicker]
  /// [BlockPicker]
  /// [MultipleChoiceBlockPicker]
  ///
  /// https://pub.dev/packages/flutter_colorpicker
  ///
  Future<Color?> pickColor(
    Color currentColor, {
    ValueCallback<Color>? onColorAction,
    //--
    Widget? titleWidget,
    //--
    bool enableAlpha = true,
    bool hexInputBar = false,
  }) async {
    Color? result;
    final globalTheme = GlobalTheme.of(this);
    await showDialog(
      context: this,
      builder: (ctx) => AlertDialog(
        title: titleWidget,
        backgroundColor: globalTheme.dialogSurfaceBgColor,
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (value) {
              result = value;
            },
            enableAlpha: enableAlpha,
            hexInputBar: hexInputBar,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColors,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: (LibRes.maybeOf(this)?.libCancel ?? "Cancel").text(),
            onPressed: () {
              //debugger();
              ctx.popDialog();
            },
          ),
          ElevatedButton(
            child: (LibRes.maybeOf(this)?.libConfirm ?? "Ok").text(),
            onPressed: () {
              //debugger();
              ctx.popDialog(result: result);
            },
          ),
        ],
      ),
    );
    //debugger();
    if (result != null && onColorAction != null) {
      onColorAction(result!);
    }
    return result;
  }
}
