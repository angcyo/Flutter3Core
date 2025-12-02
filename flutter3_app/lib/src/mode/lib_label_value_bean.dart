import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lib_label_value_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/02
///
/// 为一个[value]添加一个[label]标签，用于显示在UI上
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LibLabelValueBean with ITextProvider, EquatableMixin {
  factory LibLabelValueBean.fromJson(Map<String, dynamic> json) =>
      _$LibLabelValueBeanFromJson(json);

  Map<String, dynamic> toJson() => _$LibLabelValueBeanToJson(this);

  LibLabelValueBean({this.label, this.des, this.value, this.summary});

  /// 唯一标识符
  String? uuid;

  /// 显示在界面上标签
  String? label;

  /// 简要信息
  String? summary;

  /// 描述
  String? des;

  /// 数值
  int? value;

  @override
  String? get provideText => label;

  @override
  String toString() => toJson().toString();

  @override
  List<Object?> get props => [uuid, value];
}
