# flutter_gen

将`flutter`的资源文件, 转换成dart代码, 方便引用.

[flutter_gen: ^5.4.0]

https://pub.dev/packages/flutter_gen
https://pub-web.flutter-io.cn/packages/flutter_gen

# 1.添加依赖

全局添加`dart pub global activate flutter_gen`,
或者单独在`dev_dependencies`中添加`flutter_gen`依赖

```yaml
dev_dependencies:
  flutter_gen: ^5.4.0
  build_runner: any
  flutter_gen_runner: any
```

`flutter pub get`

配置`flutter_gen`:

```yaml
# https://pub.dev/packages/flutter_gen#configuration-file
# dart run build_runner build
# flutter pub run build_runner build
flutter_gen:
  output: lib/assets_generated/ # Optional (default: lib/gen/)
```

# 2.执行命令, 生成对应的资源引用

`dart run build_runner build`
`flutter pub run build_runner build`

# 3.配置

```yaml
# pubspec.yaml
# ...

flutter_gen:
  output: lib/gen/ # Optional (default: lib/gen/)
  line_length: 80 # Optional (default: 80)

  # Optional
  integrations:
    flutter_svg: true
    flare_flutter: true
    rive: true
    lottie: true

  colors:
    inputs:
      - assets/color/colors.xml

flutter:
  uses-material-design: true
  assets:
    - assets/images/

  fonts:
    - family: Raleway
      fonts:
        - asset: assets/fonts/Raleway-Regular.ttf
        - asset: assets/fonts/Raleway-Italic.ttf
          style: italic
```

https://pub.dev/packages/flutter_gen#configuration-file
