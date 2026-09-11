import 'package:flutter/material.dart';
import 'package:flutter3_ai/flutter3_ai.dart';
import 'package:flutter3_ai/src/widgets/glowing_border_button.dart';
import 'package:flutter3_core/flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// AI 提示词输入对话框
///
/// @return 不同的模型意图[modelIntentType]返回的数据不一样
class AiPromptInputDialog extends StatefulWidget with ScreenMixin {
  /// 模型使用意图
  /// - 决定对话框返回的数据类型
  final AiModelIntentType modelIntentType;

  /// 图片编辑时, 图片的原始数据
  final List<int>? imageEditBytes;

  //--

  /// 标题
  final String? title;
  final Widget? titleWidget;

  /// 模型使用高亮提示
  final String? highlight;
  final Widget? highlightWidget;

  /// 默认的提示词
  final String? defaultPrompt;

  /// 当前选择的供应商配置
  final AiProviderConfigBean? providerConfig;

  /// 供应商配置信息
  final List<AiProviderConfigBean>? providerConfigList;

  /// 供应商配置改变回调
  final void Function(AiProviderConfigBean config)? onConfigChanged;

  /// AI处理结果返回
  final void Function(BuildContext? context, Object? result)? onResult;

  //MARK: - ScreenMixin

  @override
  final ScreenType screenType;

  const AiPromptInputDialog({
    super.key,
    this.screenType = .centerDialog,
    this.modelIntentType = .general,
    this.imageEditBytes,
    this.title,
    this.titleWidget,
    this.highlight,
    this.highlightWidget,
    this.defaultPrompt,
    this.providerConfig,
    this.onConfigChanged,
    this.providerConfigList,
    this.onResult,
  });

  @override
  State<AiPromptInputDialog> createState() => _AiPromptInputDialogState();

  @override
  Widget? buildTitle(
    ScreenStateContext screenContext,
    GlobalTheme globalTheme,
  ) {
    return titleWidget ??
        [
              AiFeatureBadge(),
              /*AiFeatureBadge(type: .chip),*/
              /*AiFeatureBadge.buildShaderMask(),*/
              title?.text(style: globalTheme.textTitleStyle),
            ]
            .row(mainAxisSize: .min, gap: globalTheme.x)
            ?.insets(all: globalTheme.x);
  }
}

class _AiPromptInputDialogState extends State<AiPromptInputDialog>
    with ScreenStateMixin {
  /// 当前界面上的配置数据结构
  AiProviderConfigBean? _providerConfigBean;

  late final keyInputConfig = TextFieldConfig(
    labelText: "API Key",
    hintText: context.libRes?.libAiApiKeyHint,
    text: _providerConfigBean?.key ??= providerApiKey,
    obscureText: true,
    showObscureTooltip: "",
    hideObscureTooltip: "",
  );

  late final apiBaseInputConfig = TextFieldConfig(
    labelText: "API Base Url",
    hintText: context.libRes?.libAiBaseUrlHint,
    text: _providerConfigBean?.baseUrl ??= providerBaseUrl,
  );

  late final promptInputConfig = TextFieldConfig(
    labelText: context.libRes?.libAiPrompt,
    hintText: context.libRes?.libAiPromptHint,
    text: widget.defaultPrompt ?? modelIntentPrompt,
    onChanged: (value) {
      updateState();
    },
  );

  /// 界面返回的数据
  @output
  @override
  Object? screenPopResult;

  //MARK: - hive

  /// 获取持久化的api base url
  @hiveFlag
  String? get providerBaseUrl {
    final key =
        "_provider_${_providerConfigBean?.providerName ?? ""}_api_base_url";
    return key.hiveGet();
  }

  set providerBaseUrl(String? value) {
    final key =
        "_provider_${_providerConfigBean?.providerName ?? ""}_api_base_url";
    key.hiveSet(value);
  }

  /// 获取持久化的api key
  @hiveFlag
  String? get providerApiKey {
    final key = "_provider_${_providerConfigBean?.providerName ?? ""}_api_key";
    return key.hiveGet();
  }

  set providerApiKey(String? value) {
    final key = "_provider_${_providerConfigBean?.providerName ?? ""}_api_key";
    key.hiveSet(value);
  }

  /// 获取持久化的模型意图提示词
  @hiveFlag
  String? get modelIntentPrompt {
    final key =
        "_provider_${_providerConfigBean?.providerName ?? ""}_model_intent_prompt";
    return key.hiveGet();
  }

  set modelIntentPrompt(String? value) {
    final key =
        "_provider_${_providerConfigBean?.providerName ?? ""}_model_intent_prompt";
    key.hiveSet(value);
  }

  @override
  void initState() {
    _providerConfigBean =
        (widget.providerConfig ?? widget.providerConfigList?.firstOrNull)
            ?.copyWithJson() ??
        AiProviderConfigBean();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //context.tryUpdateState();
    final libRes = context.libRes;
    final globalTheme = GlobalTheme.of(context);
    final modelIntent = widget.modelIntentType;
    final providerConfigList = widget.providerConfigList;
    final highlightWidget =
        (widget.highlightWidget ??
        (widget.highlight ??
                switch (modelIntent) {
                  .general => libRes?.libAiGeneralTip,
                  .imageGenerate => libRes?.libAiImageGenerateTip,
                  .imageEdit => libRes?.libAiImageEditTip,
                })
            ?.text()
            .insets(h: kXx, v: kX));
    //--
    final providerNameList = [
      for (var providerConfig in providerConfigList ?? <AiProviderConfigBean>[])
        providerConfig.providerName,
      _providerConfigBean?.providerName,
    ].toUniqueList();
    final modelNameList = [...?_providerConfigBean?.models].toUniqueList();
    return widget.buildScaffold(
      this,
      [
        highlightWidget
            ?.backgroundDecoration(highlightDecoration())
            .matchParentWidth()
            .insets(h: kX, top: kX),
        // 提供商
        providerNameList
            .dropdownMenu(
              _providerConfigBean?.providerName,
              useOverlayStyle: true,
              inputLabel: libRes?.libAiProvider,
              onTextChanged: (value) {
                _providerConfigBean?.providerName = value;
                final find = providerConfigList?.findFirst(
                  (e) => e.providerName == value,
                );
                if (find != null) {
                  _providerConfigBean?.baseUrl =
                      find.baseUrl ?? _providerConfigBean?.baseUrl;
                  _providerConfigBean?.model = null;
                  _providerConfigBean?.models = find.models;
                }
                _sendConfigChanged();
                updateState();
              },
            )
            .insets(h: kX, top: highlightWidget == null ? kX : 0),
        if (!_isDefaultProvider())
          SingleInputWidget(
            config: apiBaseInputConfig,
            showInputCounter: false,
            maxLines: 1,
            onChanged: (value) {
              _providerConfigBean?.baseUrl = value;
              providerBaseUrl = value;
              _sendConfigChanged();
            },
          ).insets(h: kX),
        //模型
        modelNameList
            .dropdownMenu(
              _providerConfigBean?.model,
              useOverlayStyle: true,
              inputLabel: libRes?.libAiModel,
              onTextChanged: (value) {
                _providerConfigBean?.model = value;
                _sendConfigChanged();
              },
            )
            .insets(h: kX),
        //Key
        SingleInputWidget(
          config: keyInputConfig,
          showInputCounter: false,
          maxLines: 1,
          onChanged: (value) {
            _providerConfigBean?.key = value;
            providerApiKey = value;
            _sendConfigChanged();
          },
        ).insets(h: kX), //提示词
        SingleInputWidget(
          config: promptInputConfig,
          showInputCounter: false,
          maxLines: 5,
          onChanged: (value) {
            modelIntentPrompt = value;
          },
        ).insets(h: kX),
        //按钮
        GlowingBorderButton(
          text: libRes?.libAiSend ?? "",
          fillColor: globalTheme.primaryColorDark,
          enable: !isNil(promptInputConfig.text),
          onTap: () {
            final baseUrl = _providerConfigBean?.baseUrl;
            if (isNil(baseUrl)) {
              toastInfo(libRes?.libAiBaseUrlHint);
              return;
            }
            final key = _providerConfigBean?.key;
            if (isNil(key)) {
              toastInfo(libRes?.libAiApiKeyHint);
              return;
            }
            final prompt = promptInputConfig.text;
            if (isNil(prompt)) {
              toastInfo(libRes?.libAiPromptHint);
              return;
            }
            //wrapAiLoading(sleep(3_000));
            wrapAiLoading(() async {
              final openAI = OpenAI()
                ..initClient(
                  baseUrl: baseUrl!,
                  key: key!,
                  model: _providerConfigBean?.model,
                );
              if (modelIntent == .general) {
                // 通用大模型
                final result = await openAI.chatCompletion(prompt);
                widget.onResult?.call(buildContext, result);
              } else if (modelIntent == .imageGenerate) {
                // 图像生成
                final result = await openAI.imageGenerate(prompt);
                widget.onResult?.call(buildContext, result);
              } else if (modelIntent == .imageEdit) {
                // 图像编辑
                final result = await openAI.imageEdit(
                  prompt,
                  widget.imageEditBytes,
                );
                widget.onResult?.call(buildContext, result);
              }
            }());
            //toastInfo("send...${_providerConfigBean?.baseUrl}");
          },
        ).insets(bottom: kX),
      ].column(gap: kX)!.material() /*.interceptPopResult(() {
        //debugger();
      })*/,
    );
  }

  /// 选择的供应商是否是默认的
  bool _isDefaultProvider({String? providerName}) {
    final providerConfigList = widget.providerConfigList;
    return providerConfigList?.findFirst(
          (e) =>
              e.providerName ==
              (providerName ?? _providerConfigBean?.providerName),
        ) !=
        null;
  }

  /// 发送配置改变通知
  void _sendConfigChanged() {
    final config = _providerConfigBean;
    if (config != null) {
      widget.onConfigChanged?.call(config);
    }
  }
}

/// AI模型使用意图
enum AiModelIntentType {
  /// 通用大模型
  general,

  /// 图像生成
  imageGenerate,

  /// 图像编辑
  imageEdit,
}
