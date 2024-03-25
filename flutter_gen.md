# flutter_gen

[flutter_gen: ^5.4.0]

https://pub.dev/packages/flutter_gen
https://pub-web.flutter-io.cn/packages/flutter_gen

# 1.添加依赖

```yaml
dev_dependencies:
  build_runner: any
  flutter_gen_runner: any
```

`flutter pub get`

# 2.执行命令, 生成对应的资源引用

`dart run build_runner build`

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
