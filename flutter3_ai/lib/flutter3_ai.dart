import 'package:flutter/material.dart';
import 'package:flutter3_ai/src/widgets/ai_neural_grid_loading.dart';
import 'package:flutter3_core/flutter3_core.dart';

//import 'package:flutter_gemma/core/chat.dart';
//import 'package:flutter_gemma/core/message.dart';
//import 'package:flutter_gemma/core/model_response.dart';

//export 'package:flutter_gemma/flutter_gemma.dart';

//part 'src/gemma/gemma_input_field.dart';
//part 'src/gemma/gemma_service.dart';

export 'src/bean/ai_provider_config_bean.dart';
export 'src/dialog/ai_prompt_input_dialog.dart';
export 'src/openai/open_ai.dart';
export 'src/widgets/ai_feature_badge.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/22
///

/// 显示一个AI思考Loading
Future wrapAiLoading(Future future) => wrapLoading(
  future,
  loadingWidgetBuilder: (ctx, data) {
    return [
          const AiNeuralGridLoading(size: 100),
          MillisecondStopwatch(textColor: Colors.white),
        ]
        .column(mainAxisAlignment: .center)!
        .insets(all: kX)
        .backgroundDecoration(fillDecoration(color: Colors.black12))
        .center()
        .blur()
        .material();
  },
  onEnd: (value, error) {
    if (error != null) {
      toast(
        "${RNiceException(cause: error)}".text(useDefStyle: false),
        position: .center,
      );
    }
  },
);
