import 'package:flutter/material.dart';
import 'package:flutter3_ai/src/widgets/glowing_border_button.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// AI 提示词输入对话框
class AiPromptInputDialog extends StatefulWidget with ScreenMixin {
  const AiPromptInputDialog({super.key});

  @override
  State<AiPromptInputDialog> createState() => _AiPromptInputDialogState();
}

class _AiPromptInputDialogState extends State<AiPromptInputDialog> {
  late final promptInputConfig = TextFieldConfig(
    labelText: "提示词",
    hintText: "请输入提示词",
  );

  @override
  Widget build(BuildContext context) {
    //context.tryUpdateState();
    return [
      // 提供商
      ["OpenAI", "OpenRouter"]
          .dropdownMenu(
            null,
            useOverlayStyle: true,
            inputLabel: "提供商",
            onTextChanged: (value) {},
          )
          .insets(h: kX),
      //模型
      ["gpt-5.5", "gpt-image-2"]
          .dropdownMenu(
            null,
            useOverlayStyle: true,
            inputLabel: "模型",
            onTextChanged: (value) {},
          )
          .insets(h: kX),
      //提示词
      SingleInputWidget(
        config: promptInputConfig,
        showInputCounter: false,
        maxLines: 5,
        onSubmitted: (value) {
          //passwordConfig.requestFocus();
        },
      ).insets(h: kX),
      //按钮
      GlowingBorderButton(text: "发送",),
    ].column(gap: kX)!.material();
  }
}
