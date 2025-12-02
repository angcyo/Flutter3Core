// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_label_value_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibLabelValueBean _$LibLabelValueBeanFromJson(Map<String, dynamic> json) =>
    LibLabelValueBean()
      ..label = json['label'] as String?
      ..des = json['des'] as String?
      ..value = (json['value'] as num?)?.toInt();

Map<String, dynamic> _$LibLabelValueBeanToJson(LibLabelValueBean instance) =>
    <String, dynamic>{
      'label': ?instance.label,
      'des': ?instance.des,
      'value': ?instance.value,
    };
