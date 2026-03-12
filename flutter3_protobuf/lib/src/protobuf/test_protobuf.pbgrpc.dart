// This is a generated file - do not edit.
//
// Generated from test_protobuf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'test_protobuf.pb.dart' as $0;

export 'test_protobuf.pb.dart';

/// The greeting service definition.
@$pb.GrpcServiceName('TestRpc')
class TestRpcClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TestRpcClient(super.channel, {super.options, super.interceptors});

  /// Sends a greeting
  $grpc.ResponseFuture<$0.TestProtobuf2> testSayHello(
    $0.TestProtobuf request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$testSayHello, request, options: options);
  }

  // method descriptors

  static final _$testSayHello =
      $grpc.ClientMethod<$0.TestProtobuf, $0.TestProtobuf2>(
          '/TestRpc/testSayHello',
          ($0.TestProtobuf value) => value.writeToBuffer(),
          $0.TestProtobuf2.fromBuffer);
}

@$pb.GrpcServiceName('TestRpc')
abstract class TestRpcServiceBase extends $grpc.Service {
  $core.String get $name => 'TestRpc';

  TestRpcServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TestProtobuf, $0.TestProtobuf2>(
        'testSayHello',
        testSayHello_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TestProtobuf.fromBuffer(value),
        ($0.TestProtobuf2 value) => value.writeToBuffer()));
  }

  $async.Future<$0.TestProtobuf2> testSayHello_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TestProtobuf> $request) async {
    return testSayHello($call, await $request);
  }

  $async.Future<$0.TestProtobuf2> testSayHello(
      $grpc.ServiceCall call, $0.TestProtobuf request);
}
