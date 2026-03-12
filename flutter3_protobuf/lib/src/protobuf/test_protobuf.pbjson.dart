// This is a generated file - do not edit.
//
// Generated from test_protobuf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use testEnumDescriptor instead')
const TestEnum$json = {
  '1': 'TestEnum',
  '2': [
    {'1': 'CORPUS_UNSPECIFIED', '2': 0},
    {'1': 'CORPUS_UNIVERSAL', '2': 1},
    {'1': 'CORPUS_WEB', '2': 2},
    {'1': 'CORPUS_IMAGES', '2': 3},
    {'1': 'CORPUS_LOCAL', '2': 4},
    {'1': 'CORPUS_NEWS', '2': 5},
    {'1': 'CORPUS_PRODUCTS', '2': 6},
    {'1': 'CORPUS_VIDEO', '2': 7},
  ],
};

/// Descriptor for `TestEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List testEnumDescriptor = $convert.base64Decode(
    'CghUZXN0RW51bRIWChJDT1JQVVNfVU5TUEVDSUZJRUQQABIUChBDT1JQVVNfVU5JVkVSU0FMEA'
    'ESDgoKQ09SUFVTX1dFQhACEhEKDUNPUlBVU19JTUFHRVMQAxIQCgxDT1JQVVNfTE9DQUwQBBIP'
    'CgtDT1JQVVNfTkVXUxAFEhMKD0NPUlBVU19QUk9EVUNUUxAGEhAKDENPUlBVU19WSURFTxAH');

@$core.Deprecated('Use testProtobufDescriptor instead')
const TestProtobuf$json = {
  '1': 'TestProtobuf',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'page_number', '3': 2, '4': 1, '5': 5, '10': 'pageNumber'},
    {'1': 'results_per_page', '3': 3, '4': 1, '5': 5, '10': 'resultsPerPage'},
    {'1': 'corpus', '3': 4, '4': 1, '5': 14, '6': '.TestEnum', '10': 'corpus'},
  ],
};

/// Descriptor for `TestProtobuf`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testProtobufDescriptor = $convert.base64Decode(
    'CgxUZXN0UHJvdG9idWYSFAoFcXVlcnkYASABKAlSBXF1ZXJ5Eh8KC3BhZ2VfbnVtYmVyGAIgAS'
    'gFUgpwYWdlTnVtYmVyEigKEHJlc3VsdHNfcGVyX3BhZ2UYAyABKAVSDnJlc3VsdHNQZXJQYWdl'
    'EiEKBmNvcnB1cxgEIAEoDjIJLlRlc3RFbnVtUgZjb3JwdXM=');

@$core.Deprecated('Use testProtobuf2Descriptor instead')
const TestProtobuf2$json = {
  '1': 'TestProtobuf2',
  '2': [
    {
      '1': 'test1',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.TestProtobuf',
      '10': 'test1'
    },
    {
      '1': 'test2',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.TestProtobuf',
      '10': 'test2'
    },
    {
      '1': 'test3',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.TestProtobuf',
      '10': 'test3'
    },
  ],
};

/// Descriptor for `TestProtobuf2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testProtobuf2Descriptor = $convert.base64Decode(
    'Cg1UZXN0UHJvdG9idWYyEiMKBXRlc3QxGAEgASgLMg0uVGVzdFByb3RvYnVmUgV0ZXN0MRIjCg'
    'V0ZXN0MhgCIAEoCzINLlRlc3RQcm90b2J1ZlIFdGVzdDISIwoFdGVzdDMYAyABKAsyDS5UZXN0'
    'UHJvdG9idWZSBXRlc3Qz');
