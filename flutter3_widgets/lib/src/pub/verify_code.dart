part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/25
///
/// 验证码输入框
/// [flutter_verification_code: ^1.1.7]
class VerifyCode extends StatelessWidget {
  /// 验证码的长度
  final int length;

  /// 是否是全边框
  final bool fullBorder;

  /// 是否是密码输入框
  final bool isSecure;

  /// 输入框的样式
  final Color? underlineColor;
  final Color? cursorColor;
  final Color? fillColor;

  /// 输入框的大小
  final double itemSize;
  final double? itemMargin;

  /// 输入完成回调
  final ValueChanged<String>? onCompleted;

  const VerifyCode({
    super.key,
    this.length = 4,
    this.itemSize = 50,
    this.itemMargin,
    this.fullBorder = false,
    this.isSecure = false,
    this.underlineColor,
    this.cursorColor,
    this.fillColor,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return VerificationCode(
      itemSize: itemSize,
      itemMargin: itemMargin,
      textStyle: globalTheme.textTitleStyle,
      keyboardType: TextInputType.number,
      underlineColor: underlineColor ?? globalTheme.accentColor,
      underlineUnfocusedColor: null,
      underlineWidth: 1,
      isSecure: isSecure,
      fullBorder: fullBorder,
      fillColor: fillColor,
      cursorColor: cursorColor,
      //Colors.amber
      // If this is null it will use primaryColor: Colors.red from Theme
      length: length,
      //cursorColor: Colors.blue,
      onCompleted: onCompleted ??
          (value) {
            toastBlur(text: value);
          },
      onEditing: (bool value) {
        /*setState(() {
          _onEditing = value;
        });
        if (!_onEditing) FocusScope.of(context).unfocus();*/
      },
    );
  }
}
