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

import 'test_protobuf.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'test_protobuf.pbenum.dart';

/// - [TestProtobuf]
class TestProtobuf extends $pb.GeneratedMessage {
  factory TestProtobuf({
    $core.String? query,
    $core.int? pageNumber,
    $core.int? resultsPerPage,
    TestEnum? corpus,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (pageNumber != null) result.pageNumber = pageNumber;
    if (resultsPerPage != null) result.resultsPerPage = resultsPerPage;
    if (corpus != null) result.corpus = corpus;
    return result;
  }

  TestProtobuf._();

  factory TestProtobuf.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestProtobuf.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestProtobuf',
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aI(2, _omitFieldNames ? '' : 'pageNumber')
    ..aI(3, _omitFieldNames ? '' : 'resultsPerPage')
    ..aE<TestEnum>(4, _omitFieldNames ? '' : 'corpus',
        enumValues: TestEnum.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestProtobuf clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestProtobuf copyWith(void Function(TestProtobuf) updates) =>
      super.copyWith((message) => updates(message as TestProtobuf))
          as TestProtobuf;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestProtobuf create() => TestProtobuf._();
  @$core.override
  TestProtobuf createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TestProtobuf getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestProtobuf>(create);
  static TestProtobuf? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  /// Which page number do we want?
  @$pb.TagNumber(2)
  $core.int get pageNumber => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageNumber($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageNumber() => $_clearField(2);

  /// Number of results to return per page.
  @$pb.TagNumber(3)
  $core.int get resultsPerPage => $_getIZ(2);
  @$pb.TagNumber(3)
  set resultsPerPage($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResultsPerPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearResultsPerPage() => $_clearField(3);

  @$pb.TagNumber(4)
  TestEnum get corpus => $_getN(3);
  @$pb.TagNumber(4)
  set corpus(TestEnum value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCorpus() => $_has(3);
  @$pb.TagNumber(4)
  void clearCorpus() => $_clearField(4);
}

/// - [TestProtobuf2]
class TestProtobuf2 extends $pb.GeneratedMessage {
  factory TestProtobuf2({
    TestProtobuf? test1,
    TestProtobuf? test2,
    TestProtobuf? test3,
  }) {
    final result = create();
    if (test1 != null) result.test1 = test1;
    if (test2 != null) result.test2 = test2;
    if (test3 != null) result.test3 = test3;
    return result;
  }

  TestProtobuf2._();

  factory TestProtobuf2.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestProtobuf2.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestProtobuf2',
      createEmptyInstance: create)
    ..aOM<TestProtobuf>(1, _omitFieldNames ? '' : 'test1',
        subBuilder: TestProtobuf.create)
    ..aOM<TestProtobuf>(2, _omitFieldNames ? '' : 'test2',
        subBuilder: TestProtobuf.create)
    ..aOM<TestProtobuf>(3, _omitFieldNames ? '' : 'test3',
        subBuilder: TestProtobuf.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestProtobuf2 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestProtobuf2 copyWith(void Function(TestProtobuf2) updates) =>
      super.copyWith((message) => updates(message as TestProtobuf2))
          as TestProtobuf2;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestProtobuf2 create() => TestProtobuf2._();
  @$core.override
  TestProtobuf2 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TestProtobuf2 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestProtobuf2>(create);
  static TestProtobuf2? _defaultInstance;

  /// - [test1]
  @$pb.TagNumber(1)
  TestProtobuf get test1 => $_getN(0);
  @$pb.TagNumber(1)
  set test1(TestProtobuf value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTest1() => $_has(0);
  @$pb.TagNumber(1)
  void clearTest1() => $_clearField(1);
  @$pb.TagNumber(1)
  TestProtobuf ensureTest1() => $_ensure(0);

  /// - [test2]
  @$pb.TagNumber(2)
  TestProtobuf get test2 => $_getN(1);
  @$pb.TagNumber(2)
  set test2(TestProtobuf value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTest2() => $_has(1);
  @$pb.TagNumber(2)
  void clearTest2() => $_clearField(2);
  @$pb.TagNumber(2)
  TestProtobuf ensureTest2() => $_ensure(1);

  /// - [test3]
  @$pb.TagNumber(3)
  TestProtobuf get test3 => $_getN(2);
  @$pb.TagNumber(3)
  set test3(TestProtobuf value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTest3() => $_has(2);
  @$pb.TagNumber(3)
  void clearTest3() => $_clearField(3);
  @$pb.TagNumber(3)
  TestProtobuf ensureTest3() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
