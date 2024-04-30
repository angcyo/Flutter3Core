# flutter3_ff1

2024-04-30

- 提供`Uint8List`<->`ffi.Pointer<Vec_uint8_t>`的方法.
- 提供`String`<->`ffi.Pointer<Vec_uint8_t>`的方法.

# 参考

https://dart.dev/interop/c-interop

使用`safer_ffi`生成c绑定的头文件`.h`.

使用`ffigen`将`.h`头文件生成`flutter bindings`.

# safer_ffi

https://github.com/getditto/safer_ffi

## 在`rust`工程中引入`safer_ffi`.

```
[lib]
crate-type = [
    "staticlib", # Ensure it gets compiled as a (static) C library
    "cdylib", # If you want a shared/dynamic C library (advanced)
    #"lib", # For `generate-headers`, `examples/`, `tests/` etc.
]

#在写代码阶段，可以注释掉这个部分
#[[bin]]
#name = "generate-headers"
#required-features = ["headers"]  # Do not build unless generating headers.

[dependencies]
# Use `cargo add` or `cargo search` to find the latest values of x.y.z.
# For instance:
#   cargo add safer-ffi
# https://crates.io/crates/safer-ffi
safer-ffi.version = "0.1.7"
safer-ffi.features = [] # you may add some later on.

[features]
# If you want to generate the headers, use a feature-gate
# to opt into doing so:
headers = ["safer-ffi/headers"]
```

## 在`lib.rs`文件中加入

```dart
#[test]
#[cfg(feature = "headers")] // c.f. the `Cargo.toml` section
pub fn generate_headers() -> std::io::Result<()> {
    safer_ffi::headers::builder()
        .to_file("rust_headers.h")?
        .generate()
}
```

## 在`api.rs`文件中加入需要导出的接口

```dart
/// 测试输入一个字符串, 返回对应的字符串
#[ffi_export]
fn test_string(str: &safer_ffi::String) -> safer_ffi::String {
    //let rust_str = str.to_string();
    //let safer_str = safer_ffi::String::from(result);
    format!("Hello, {}", str).into()
}

/// 测试输入一个字节数组, 返回对应的字节长度
#[ffi_export]
fn test_bytes(bytes: &safer_ffi::Vec<u8>) -> usize {
    //let safer_vec = safer_ffi::Vec::from(result);
    //let rust_data = data.to_vec();
    bytes.len()
}
```

对象的导出:

```dart
/// A `struct` usable from both Rust and C
#[derive_ReprC]
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct Point {
    x: f64,
    y: f64,
}

/* Export a Rust function to the C world. */
/// Returns the middle point of `[a, b]`.
#[ffi_export]
fn mid_point(a: &Point, b: &Point) -> Point {
    Point {
        x: (a.x + b.x) / 2.,
        y: (a.y + b.y) / 2.,
    }
}

/// Pretty-prints a point using Rust's formatting logic.
#[ffi_export]
fn print_point(point: &Point) {
    println!("{:?}", point);
}
```

## 生成

使用命令生成对应的头文件.

```
cargo test --package rust --lib generate_headers --features headers
```

# ffigen

https://pub.dev/packages/ffigen

使用`flutter`创建一个`ffi`工程, 就会自动依赖`ffigen`

## ffigen.yaml

创建一个`yaml`配置文件

```
# Run with `flutter pub run ffigen --config ffigen.yaml`.
name: FfigenSaferFfiDemoBindings
description: |
  Bindings for `src/ffigen_safer_ffi_demo.h`.

  Regenerate bindings with `flutter pub run ffigen --config ffigen.yaml`.
output: 'lib/ffigen_safer_ffi_demo_bindings_generated.dart'
headers:
  entry-points:
    - 'src/ffigen_safer_ffi_demo.h'
    - 'rust/rust_headers.h'
  include-directives:
    - 'src/ffigen_safer_ffi_demo.h'
    - 'rust/rust_headers.h'
    - '*.h'
preamble: |
  // ignore_for_file: always_specify_types
  // ignore_for_file: camel_case_types
  // ignore_for_file: non_constant_identifier_names
comments:
  style: any
  length: full
```

## 生成

使用命令生成对应的`flutter`绑定文件

```
@echo off
rem 通过.h文件生成dart 绑定代码
rem flutter pub run ffigen --config ffigen.yaml
dart run ffigen --config ffigen.yaml
```

### Vec_uint8_t String Uint8List 转换

```
/// [test_string]
String? testString(String str) {
  final bytes = utf8.encode(str);
  final Pointer<Uint8> bytesPtr = calloc.allocate<Uint8>(bytes.length);
  final Uint8List nativeBytes = bytesPtr.asTypedList(bytes.length);
  nativeBytes.setAll(0, bytes);

  final ptr = calloc<Vec_uint8_t>();
  ptr.ref.len = bytes.length;
  ptr.ref.cap = bytes.length;
  ptr.ref.ptr = bytesPtr;

  try {
    final resultVec = _bindings.test_string(ptr);
    final result = resultVec.ptr;
    final reversedBytes = result.asTypedList(resultVec.len);
    final reversedString = utf8.decode(reversedBytes);
    return reversedString;
  } catch (e) {
    print(e);
    return null;
  } finally {
    calloc.free(ptr);
    calloc.free(bytesPtr);
  }
}

/// [test_bytes]
int testBytes(Uint8List bytes) {
  final watchGenerate = Stopwatch()..start();
  final Pointer<Uint8> bytesPtr = malloc.allocate<Uint8>(bytes.length);
  final Uint8List nativeBytes = bytesPtr.asTypedList(bytes.length);
  nativeBytes.setAll(0, bytes);
  watchGenerate.stop();
  print("allocate: ${watchGenerate.elapsedMilliseconds}ms");

  final ptr = malloc<Vec_uint8_t>();
  ptr.ref.len = bytes.length;
  ptr.ref.cap = bytes.length;
  ptr.ref.ptr = bytesPtr;

  try {
    final watchBinding = Stopwatch()..start();
    final result = _bindings.test_bytes(ptr);
    watchBinding.stop();
    print("bindings: ${watchBinding.elapsedMilliseconds}ms");
    return result;
  } catch (e) {
    print(e);
    return 0;
  } finally {
    malloc.free(ptr);
    malloc.free(bytesPtr);
  }
}
```