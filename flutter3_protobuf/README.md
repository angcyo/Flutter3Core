# Language Guide (proto 3)

https://protobuf.dev/programming-guides/proto3/

## 定义消息类型

```proto
syntax = "proto3";

/**
 * SearchRequest represents a search query, with pagination options to
 * indicate which results to include in the response.
 */
message SearchRequest {
  string query = 1;

  // Which page number do we want?
  int32 page_number = 2;

  // Number of results to return per page.
  int32 results_per_page = 3;
}

```

## 枚举

```proto
enum Corpus {
  CORPUS_UNSPECIFIED = 0; //在 proto3 中，enum 定义的第一个值必须为零，且名称应为 ENUM_TYPE_NAME_UNSPECIFIED 或 ENUM_TYPE_NAME_UNKNOWN。
  CORPUS_UNIVERSAL = 1;
  CORPUS_WEB = 2;
  CORPUS_IMAGES = 3;
  CORPUS_LOCAL = 4;
  CORPUS_NEWS = 5;
  CORPUS_PRODUCTS = 6;
  CORPUS_VIDEO = 7;
}

message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 results_per_page = 3;
  Corpus corpus = 4;
}
```

## 使用其它消息类型

```proto
import "myproject/other_protos.proto";

syntax = "proto3";

message SearchResponse {
  repeated Result results = 1;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
}

```

### 标量值类型

| Proto Type | C++ Type | Java/Kotlin Type[1] | Python Type[3]                   | Go Type | Ruby Type                      | C# Type    | PHP Type          | Dart Type | Rust Type   |
|------------|----------|---------------------|----------------------------------|---------|--------------------------------|------------|-------------------|-----------|-------------|
| double     | double   | double              | float                            | float64 | Float                          | double     | float             | double    | f64         |
| float      | float    | float               | float                            | float32 | Float                          | float      | float             | double    | f32         |
| int32      | int32_t  | int                 | int                              | int32   | Fixnum or Bignum (as required) | int        | integer           | int       | i32         |
| int64      | int64_t  | long                | int/long[4]                      | int64   | Bignum                         | long       | integer/string[6] | Int64     | i64         |
| uint32     | uint32_t | int[2]              | int/long[4]                      | uint32  | Fixnum or Bignum (as required) | uint       | integer           | int       | u32         |
| uint64     | uint64_t | long[2]             | int/long[4]                      | uint64  | Bignum                         | ulong      | integer/string[6] | Int64     | u64         |
| sint32     | int32_t  | int                 | int                              | int32   | Fixnum or Bignum (as required) | int        | integer           | int       | i32         |
| sint64     | int64_t  | long                | int/long[4]                      | int64   | Bignum                         | long       | integer/string[6] | Int64     | i64         |
| fixed32    | uint32_t | int[2]              | int/long[4]                      | uint32  | Fixnum or Bignum (as required) | uint       | integer           | int       | u32         |
| fixed64    | uint64_t | long[2]             | int/long[4]                      | uint64  | Bignum                         | ulong      | integer/string[6] | Int64     | u64         |
| sfixed32   | int32_t  | int                 | int                              | int32   | Fixnum or Bignum (as required) | int        | integer           | int       | i32         |
| sfixed64   | int64_t  | long                | int/long[4]                      | int64   | Bignum                         | long       | integer/string[6] | Int64     | i64         |
| bool       | bool     | boolean             | bool                             | bool    | TrueClass/FalseClass           | bool       | boolean           | bool      | bool        |
| string     | string   | String              | str/unicode[5]                   | string  | String (UTF-8)                 | string     | string            | String    | ProtoString |
| bytes      | string   | ByteString          | str (Python 2), bytes (Python 3) | []byte  | String (ASCII-8BIT)            | ByteString | string            | List      | ProtoBytes  |

### 分配场号范围 `1` and `536,870,911`.

```proto
syntax="proto3";

package foo.bar;

message Message1 {}

message Message2 {
  Message1 foo = 1;
}

message Message3 {
  optional Message1 bar = 1;
}

```

# Protocol Buffer Basics: Dart 

https://protobuf.dev/getting-started/darttutorial/

# Dart Generated Code

https://protobuf.dev/reference/dart/dart-generated/

## protoc_plugin: ^25.0.0

https://pub.dev/packages/protoc_plugin

```shell
dart pub global activate protoc_plugin

# code ~/.zshrc
# export PATH="$PATH":"$HOME/.pub-cache/bin"
# source ~/.zshrc
```

## How to build

https://github.com/google/protobuf.dart/tree/master/protoc_plugin#how-to-build

### 安装插件

```shell
dart pub global activate protoc_plugin
```

### 编译

```shell
protoc --dart_out=. test.proto
# protoc --dart_out=. test.proto --plugin=<path to plugin executable>
```

# Downloads

https://protobuf.dev/downloads/

https://github.com/protocolbuffers/protobuf/releases

- [protoc-34.0-osx-aarch_64.zip](https://release-assets.githubusercontent.com/github-production-release-asset/23357588/bbb0fc4e-53bb-4c77-9946-fae6d399b314?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-11T10%3A42%3A09Z&rscd=attachment%3B+filename%3Dprotoc-34.0-osx-aarch_64.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-11T09%3A41%3A15Z&ske=2026-03-11T10%3A42%3A09Z&sks=b&skv=2018-11-09&sig=PDbj%2FtRAkfwqCZchOPOKAo9Ebv24b%2FrPn5EmyUgS1BM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MzIyMjczNiwibmJmIjoxNzczMjIyNDM2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.8-W-G6GMRtT3dlrVDX1agRCsqoEBO5tA-E9BHoiHxTU&response-content-disposition=attachment%3B%20filename%3Dprotoc-34.0-osx-aarch_64.zip&response-content-type=application%2Foctet-stream)
- [protoc-34.0-win64.zip](https://release-assets.githubusercontent.com/github-production-release-asset/23357588/59075939-f896-4fd4-a17e-95f87d1d2087?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-11T10%3A48%3A49Z&rscd=attachment%3B+filename%3Dprotoc-34.0-win64.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-11T09%3A48%3A32Z&ske=2026-03-11T10%3A48%3A49Z&sks=b&skv=2018-11-09&sig=aXf3aa3VJ9b3xOXTwX7VXaRDcD3%2FqFMCqlsQUI0sqAU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MzIyMjgyOCwibmJmIjoxNzczMjIyNTI4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.fnYJSWBpW6WzyUVJ1TjJX-LlEHYn6zPl9zQNfhskkFE&response-content-disposition=attachment%3B%20filename%3Dprotoc-34.0-win64.zip&response-content-type=application%2Foctet-stream)

# grpc: ^5.1.0

https://pub.dev/packages/grpc

https://grpc.io/

## Dart gRPC

https://grpc.io/docs/languages/dart/quickstart/

