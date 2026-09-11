// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider_config_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiProviderConfigBean _$AiProviderConfigBeanFromJson(
  Map<String, dynamic> json,
) => AiProviderConfigBean()
  ..providerName = json['providerName'] as String?
  ..baseUrl = json['baseUrl'] as String?
  ..key = json['key'] as String?
  ..model = json['model'] as String?
  ..models = (json['models'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList();

Map<String, dynamic> _$AiProviderConfigBeanToJson(
  AiProviderConfigBean instance,
) => <String, dynamic>{
  'providerName': ?instance.providerName,
  'baseUrl': ?instance.baseUrl,
  'key': ?instance.key,
  'model': ?instance.model,
  'models': ?instance.models,
};
