# json_serializable

[json_serializable: ^6.7.1]

https://pub.dev/packages/json_serializable
https://pub-web.flutter-io.cn/packages/json_serializable

# 1.添加依赖

`dart pub add dev:json_serializable`

```yaml
dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: any
```

可能还需要: `json_annotation: ^4.8.1`依赖

https://pub.dev/packages/json_annotation
https://pub-web.flutter-io.cn/packages/json_annotation

`dart pub add json_annotation`

```yaml
dependencies:
  json_annotation: ^4.8.1
```

# 2.配置

当前的类不能是`part of`.
需要在头部指定`part 'xxx.g.dart';` 必须;

在需要生成json序列化代码的类上添加注解`@JsonSerializable()`
在需要序列化的字段上添加`@JsonKey()`注解, 非必需.

# 3.生成代码

运行命令`dart run build_runner build`生成代码.

```shell
# flutter pub run build_runner build
echo $PUB_HOSTED_URL
export PUB_HOSTED_URL=https://pub.flutter-io.cn
echo $PUB_HOSTED_URL
dart run build_runner build
```

# 4.Other

安装`Idea`的插件`JsonSerializable`可以自动生成`xxx.g.dart`中的`fromJson/toJson`引用方法.

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          # Options configure how source code is generated for every
          # `@JsonSerializable`-annotated class in the package.
          #
          # The default value for each is listed.
          any_map: false
          checked: false
          constructor: ""
          create_factory: true
          create_field_map: false
          create_per_field_to_json: false
          create_to_json: true
          disallow_unrecognized_keys: false
          explicit_to_json: false
          field_rename: none
          generic_argument_factories: false
          ignore_unannotated: false
          include_if_null: true
```

更多配置参数:

https://pub.dev/packages/json_serializable#build-configuration
https://pub-web.flutter-io.cn/packages/json_serializable#build-configuration

