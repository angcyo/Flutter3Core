import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_provider_config_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/10
///
/// ai提供者配置
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class AiProviderConfigBean with Equatable, IProviderText {
  static List<AiProviderConfigBean> get all => [
    AiProviderConfigBean()
      ..providerName = 'OpenAI'
      ..baseUrl = 'https://api.openai.com/v1'
      ..models = ["gpt-5.5", "gpt-image-2"],
    AiProviderConfigBean()
      ..providerName = 'OpenRouter'
      ..baseUrl = 'https://openrouter.ai/api/v1'
      ..models = ["openai/gpt-5.5", "openai/gpt-image-2"],
  ];

  /// 提供者名称
  ///
  /// - `OpenAI`
  /// - `OpenRouter`
  String? providerName;

  /// 基础接口地址
  ///
  /// - `https://api.openai.com/v1`
  /// - `https://openrouter.ai/api/v1`
  String? baseUrl;

  /// 接口密钥
  String? key;

  /// 支持的模型列表
  List<String>? models;

  //--

  /// 默认模型/界面选中的模型
  String? model;

  //--

  @override
  String? get provideText => providerName;

  AiProviderConfigBean();

  /// copyWithJson
  AiProviderConfigBean copyWithJson() =>
      AiProviderConfigBean.fromJson(toJson());

  static AiProviderConfigBean? from(Map<String, dynamic>? json) =>
      json == null ? null : AiProviderConfigBean.fromJson(json);

  factory AiProviderConfigBean.fromJson(Map<String, dynamic> json) =>
      _$AiProviderConfigBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AiProviderConfigBeanToJson(this);

  @override
  List<Object?> get props => [providerName, baseUrl];
}
