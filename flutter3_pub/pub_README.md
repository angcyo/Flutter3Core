# 2023-11-6

https://pub.dev/ 上的一些开源库

## cached_network_image

一个 flutter 库，用于显示来自 Internet 的图像并将它们保存在缓存目录中。

https://github.com/Baseflow/flutter_cached_network_image

- [cached_network_image: ^3.3.0](https://pub.dev/packages/cached_network_image)
- [flutter_cache_manager: ^3.3.1](https://pub.dev/packages/flutter_cache_manager)
- [octo_image: ^2.0.0](https://pub.dev/packages/octo_image)

## swiper

flutter 最强大的 swiper, 多种布局方式，无限轮播，Android 和 iOS 双端适配.

https://github.com/feicien/flutter_swiper_view

- [flutter_swiper_view: ^1.1.8](https://pub.dev/packages/flutter_swiper_view)
- [card_swiper: ^3.0.1](https://pub.dev/packages/card_swiper)
- [carousel_slider: ^4.2.1](https://pub.dev/packages/carousel_slider)

## ref

Ref: 这是一个支持flutter数据响应式的组合Api插件

响应式，简单，灵活，可组合，可移植性高，侵入性低。支持数据同步修改，缓存队列异步刷新。

https://gitee.com/kgm0515/flutter_ref

### 特征

- Ref：把数据包装成一个响应式对象
- RefBuilder：数据修改通知对应的widget刷新
- Ref.update：内部监听所有响应对象的读取和修改，执行副作用并更新widget
- RefCompute：支持计算属性
- RefWatch：数据修改，执行副作用
- RefKey：可以很方便的代理复杂响应式对象的某一个属性值
- refKeys： 函数，可以把一个复杂响应式对象的所有键代理到一个简单对象中，返回一个Map<dynamic, RefKey>对象
- ...

https://pub.dev/packages/ref

## flutter_html

一个 Flutter widget，用于将 HTML 和 CSS 渲染为 Flutter widget。

https://github.com/Sub6Resources/flutter_html

- [flutter_html: ^3.0.0-beta.2](https://pub.dev/packages/flutter_html/versions/3.0.0-beta.2)
- [html: ^0.15.3](https://pub.dev/packages/html)
- [csslib: ^0.17.2](https://pub.dev/packages/csslib)
- [collection: ^1.17.0](https://pub.dev/packages/collection)
- [list_counter: ^1.0.2](https://pub.dev/packages/list_counter)

## lottie

Lottie 是一个适用于 Android 和 iOS 的移动库，它使用 Bodymovin 解析导出为 json 的 Adobe After Effects
动画，并在移动设备上原生渲染它们！

- [lottie: ^2.7.0](https://pub.dev/packages/lottie)

## objectbox

ObjectBox Flutter 数据库是将 Dart 对象存储在跨平台应用程序中的绝佳选择。
ObjectBox Flutter 数据库专为高性能而设计，是移动和物联网设备的理想选择。
ObjectBox 使用最少的 CPU、内存和电池，使您的应用程序不仅有效，而且可持续。
通过在设备上本地存储数据，ObjectBox 可帮助您降低云成本，并制作一个不依赖于连接的应用程序。
在几分钟内开始使用我们直观的原生 Dart API，无需 SQL 的麻烦。
另外：我们构建了一个数据同步解决方案，允许您在设备和服务器之间保持数据同步，包括在线和离线。

https://docs.objectbox.io/getting-started

- [objectbox: ^2.3.1](https://pub.dev/packages/objectbox)

```yaml
dependencies:
  objectbox: ^2.3.1
  objectbox_flutter_libs: any
  # For ObjectBox Sync this dependency should appear instead:
  # objectbox_sync_flutter_libs: any

dev_dependencies:
  build_runner: ^2.0.0
  objectbox_generator: any
```

## animate_do

受 Animate.css 启发的动画包，仅使用 Flutter 动画构建，零依赖性。

https://github.com/Klerith/animate_do_package

- [animate_do: ^3.1.2](https://pub.dev/packages/animate_do)

## flutter_gen

用于资产、字体、颜色等的 Flutter 代码生成器 — 摆脱所有基于字符串的 API。

- [flutter_gen: ^5.3.2](https://pub.dev/packages/flutter_gen)

## flutter_svg

使用 Flutter 绘制 SVG 文件。

https://github.com/dnfield/flutter_svg/tree/master/packages/flutter_svg

https://github.com/dnfield/vector_graphics

- [flutter_svg: ^2.0.9](https://pub.dev/packages/flutter_svg)
- [vector_graphics: ^1.1.9+1](https://pub.dev/packages/vector_graphics)
- [vector_graphics_codec: ^1.1.9+1](https://pub.dev/packages/vector_graphics_codec)
- [vector_graphics_compiler: ^1.1.9+1](https://pub.dev/packages/vector_graphics_compiler)

## jovial_svg

强大、高效的 SVG 静态图像渲染，支持定义明确的 SVG 配置文件和高效的二进制存储格式。
使用这种二进制格式可以带来非常快的加载时间——加载预编译的二进制文件通常比解析 XML SVG 文件快一个数量级。
观察到加载较大 SVG 文件的加速范围从 5 倍到 20 倍不等。

https://github.com/zathras/jovial_svg

- [jovial_svg: ^1.1.18](https://pub.dev/packages/jovial_svg)
- [xml: ^6.4.2](https://pub.dev/packages/xml)
- [args: ^2.4.2](https://pub.dev/packages/args)
- [vector_math: ^2.1.4](https://pub.dev/packages/vector_math)

# url_launcher

用于启动 URL 的 Flutter 插件。

https://github.com/flutter/packages/tree/main/packages/url_launcher/url_launcher

- [url_launcher: ^6.2.1](https://pub.dev/packages/url_launcher)

## emoji

https://github.com/googlefonts/noto-emoji

## font_awesome_flutter

免费的 Font Awesome Icon 包以一组 Flutter 图标的形式提供 - 基于 font awesome 版本 6.4.2。

- [font_awesome_flutter: ^10.6.0](https://pub.dev/packages/font_awesome_flutter)

## overlay

- [overlay_support: ^2.1.0](https://pub.dev/packages/overlay_support) 提供程序支持 overlay ，使构建
  Toast 和应用内通知变得容易。
- [debug_overlay: ^0.2.10](https://pub.dev/packages/debug_overlay) 🐛 通过应用的中央叠加层查看调试信息和更改设置。

## flutter_neumorphic

一个完整的、随时可用的、用于 Flutter 的 Neumorphic ui 套件

https://github.com/Idean/Flutter-Neumorphic

- [flutter_neumorphic: ^3.2.0](https://pub.dev/packages/flutter_neumorphic)

## flutter_colorpicker

HSV（HSB）/HSL/RGB/材质颜色选择器的灵感来自您令人惊叹的 FLUTTER 应用程序的所有优秀设计。
开箱即用的可爱颜色选择器，具有高度定制的小部件，可满足所有开发人员的需求。

- [flutter_colorpicker: ^1.0.3](https://pub.dev/packages/flutter_colorpicker)
- [flutter_material_color_picker: ^1.2.0](https://pub.dev/packages/flutter_material_color_picker) 默认情况下，它是材质颜色，但您可以定义自己的颜色。
- [flutter_hsvcolor_picker: ^1.5.0](https://pub.dev/packages/flutter_hsvcolor_picker) 专为您的 Flutter 应用程序设计的 HSV 颜色选择器。
- [iglu_color_picker_flutter: ^1.0.4](https://pub.dev/packages/iglu_color_picker_flutter)
- [flex_color_picker: ^3.3.0](https://pub.dev/packages/flex_color_picker) FlexColorPicker 是 Flutter 的可自定义颜色选择器。 ColorPicker 可以显示六种不同类型的颜色选择器，其中三种用于标准的 Flutter Material Design 2 颜色及其阴影。用于拣选物品的尺寸和样式可以定制。
- [fast_color_picker: ^0.1.1](https://pub.dev/packages/fast_color_picker)

## flutter_smart_dialog: ^4.9.5+1

一个优雅的 Flutter Dialog 解决方案。

- [flutter_smart_dialog: ^4.9.5+1](https://pub.dev/packages/flutter_smart_dialog)

## others

https://github.com/fluttercommunity/plus_plugins

- [quiver: ^3.2.1](https://pub.dev/packages/quiver) Quiver 是一组 Dart 的实用程序库，它使许多 Dart
  库的使用更轻松、更方便，或者添加了额外的功能。
- [flutter_simple_treeview: ^3.0.2](https://pub.dev/packages/flutter_simple_treeview)
  此小部件可视化了树形结构，其中节点可以是任何小部件。
- [file: ^7.0.0](https://pub.dev/packages/file) Dart 的通用文件系统抽象。
- [json_serializable: ^6.7.1](https://pub.dev/packages/json_serializable) 为操作 JSON 提供 Dart
  构建系统构建器。
- [vector_math: ^2.1.4](https://pub.dev/packages/vector_math) 用于 2D 和 3D 应用程序的矢量数学库。
- [intent: ^1.4.0](https://pub.dev/packages/intent) 一个简单的 flutter 插件来处理 Android Intents。
- [android_intent_plus: ^4.0.3](https://pub.dev/packages/android_intent_plus) 该插件允许 Flutter 应用程序在平台为 Android 时启动任意意图。
- [device_info_plus: ^9.1.0](https://pub.dev/packages/device_info_plus) 从 Flutter 应用程序中获取当前设备信息。
- [package_info_plus: ^4.2.0](https://pub.dev/packages/package_info_plus) 这个 Flutter 插件提供了一个 API，用于查询有关应用程序包的信息。
- [share_plus: ^7.2.1](https://pub.dev/packages/share_plus) 一个 Flutter 插件，用于通过平台的共享对话框共享 Flutter 应用程序中的内容。
- [get_it: ^7.6.4](https://pub.dev/packages/get_it) 
- [rxdart: ^0.27.7](https://pub.dev/packages/rxdart) RxDart 扩展了 Dart Streams 和 StreamController 的功能。
- [flutter_downloader: ^1.11.4](https://pub.dev/packages/flutter_downloader) 用于创建和管理下载任务的插件。支持 iOS 和 Android。
- [flutter_blurhash: ^0.7.0](https://pub.dev/packages/flutter_blurhash) 图像占位符的紧凑表示形式。