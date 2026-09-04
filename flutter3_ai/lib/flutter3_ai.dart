import 'package:flutter3_ai/src/widgets/ai_neural_grid_loading.dart';
//import 'package:flutter3_ai/src/gemma/chat_message.dart';
//import 'package:flutter3_ai/src/gemma/thinking_widget.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

//import 'package:flutter_gemma/core/chat.dart';
//import 'package:flutter_gemma/core/message.dart';
//import 'package:flutter_gemma/core/model_response.dart';

//export 'package:flutter_gemma/flutter_gemma.dart';

//part 'src/gemma/gemma_input_field.dart';
//part 'src/gemma/gemma_service.dart';

export 'src/dialog/ai_prompt_input_dialog.dart';
export 'src/openai/open_ai.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/22
///

/// 显示一个AI思考Loading
Future wrapAiLoading(Future future) => wrapLoading(
  future,
  loadingWidgetBuilder: (ctx, data) {
    return const AiNeuralGridLoading(size: 100).center().blur();
  },
);
