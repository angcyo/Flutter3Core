// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_label_value_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibLabelValueBean _$LibLabelValueBeanFromJson(Map<String, dynamic> json) =>
    LibLabelValueBean(
      label: json['label'] as String?,
      des: json['des'] as String?,
      value: (json['value'] as num?)?.toInt(),
      summary: json['summary'] as String?,
    )..uuid = json['uuid'] as String?;

Map<String, dynamic> _$LibLabelValueBeanToJson(LibLabelValueBean instance) =>
    <String, dynamic>{
      'uuid': ?instance.uuid,
      'label': ?instance.label,
      'summary': ?instance.summary,
      'des': ?instance.des,
      'value': ?instance.value,
    };
