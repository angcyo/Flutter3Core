# flutter_intl

国际化插件, 用来将`arb`文件生成对应的`dart`文件.

[intl: ^0.19.0] - 国际化, 一些api

https://pub.dev/packages/intl
https://pub-web.flutter-io.cn/packages/intl

[intl_utils: ^2.8.7] - 根据配置,将arb生成代码

https://pub.dev/packages/intl_utils
https://pub-web.flutter-io.cn/packages/intl_utils

实例参考:
https://github.com/lizhuoyuan/flutter_intl_example

# 1.配置

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  # https://pub.dev/packages/intl
  # https://localizely.com/flutter-arb/
  # https://github.com/localizely/flutter-intl-plugin-sample-app
  # https://github.com/cfug/flutter.cn/tree/main/examples/internationalization/gen_l10n_example
  # https://pub.dev/packages/clock
  # https://pub.dev/packages/meta
  # https://pub.dev/packages/path
  intl: any
  clock: any

# https://pub.dev/packages/intl
# https://pub.dev/packages/intl_utils
# https://localizely.com/flutter-arb/
# flutter pub run intl_utils:generate
flutter_intl:
  enabled: true
  class_name: LibRes
  main_locale: zh
  arb_dir: lib/l10n
  output_dir: lib/l10n/generated
  use_deferred_loading: false
```

# 2.执行命令, 生成对应的资源引用

`flutter pub run intl_utils:generate`

安装Idea`Flutter Intl`插件, 会自动执行命令.

- arb文件说明: https://localizely.com/flutter-arb/

# 3.初始化`delegate`

```dart

final app = MaterialApp(
  localizationsDelegates: const [
    LibRes.delegate, //必须
  ],
);
```

# 注意

多个模块同时使用时, 会出现其余模块无法切换语言的问题.

主要是因为`intl_helpers.messageLookup`是全局共享导致的.

解决方法, 将所有资源合并到一起.

https://juejin.cn/post/7041125659308982302

# 问题

- pub.dev/analyzer-6.5.0/lib/src/summary2/macro_application.dart:1261:7: Error: The non-abstract
  class '_StaticTypeImpl' is missing implementations for these members:StaticType.asInstanceOf

```
flutter pub global activate intl_utils
```