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

## emoji

https://github.com/googlefonts/noto-emoji


