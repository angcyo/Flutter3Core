// This is a generated file - do not edit.
//
// Generated from test_protobuf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// - [TestEnum]
class TestEnum extends $pb.ProtobufEnum {
  static const TestEnum CORPUS_UNSPECIFIED =
      TestEnum._(0, _omitEnumNames ? '' : 'CORPUS_UNSPECIFIED');
  static const TestEnum CORPUS_UNIVERSAL =
      TestEnum._(1, _omitEnumNames ? '' : 'CORPUS_UNIVERSAL');
  static const TestEnum CORPUS_WEB =
      TestEnum._(2, _omitEnumNames ? '' : 'CORPUS_WEB');
  static const TestEnum CORPUS_IMAGES =
      TestEnum._(3, _omitEnumNames ? '' : 'CORPUS_IMAGES');
  static const TestEnum CORPUS_LOCAL =
      TestEnum._(4, _omitEnumNames ? '' : 'CORPUS_LOCAL');
  static const TestEnum CORPUS_NEWS =
      TestEnum._(5, _omitEnumNames ? '' : 'CORPUS_NEWS');
  static const TestEnum CORPUS_PRODUCTS =
      TestEnum._(6, _omitEnumNames ? '' : 'CORPUS_PRODUCTS');
  static const TestEnum CORPUS_VIDEO =
      TestEnum._(7, _omitEnumNames ? '' : 'CORPUS_VIDEO');

  static const $core.List<TestEnum> values = <TestEnum>[
    CORPUS_UNSPECIFIED,
    CORPUS_UNIVERSAL,
    CORPUS_WEB,
    CORPUS_IMAGES,
    CORPUS_LOCAL,
    CORPUS_NEWS,
    CORPUS_PRODUCTS,
    CORPUS_VIDEO,
  ];

  static final $core.List<TestEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static TestEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TestEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
