# flutter_intl

[intl_utils: ^2.8.7]

https://pub.dev/packages/intl_utils
https://pub-web.flutter-io.cn/packages/intl_utils

# 1.配置

```yaml
# https://pub.dev/packages/intl
# https://pub.dev/packages/intl_utils
# https://localizely.com/flutter-arb/
# flutter pub run intl_utils:generate
flutter_intl:
  enabled: true
  class_name: LPS
  main_locale: zh
  arb_dir: lib/l10n
  output_dir: lib/l10n/generated
  use_deferred_loading: false
```

# 2.执行命令, 生成对应的资源引用

`flutter pub run intl_utils:generate`

安装Idea`Flutter Intl`插件, 会自动执行命令.


- arb文件说明: https://localizely.com/flutter-arb/
