# 2023-11-6

https://pub.dev/ 上的一些开源库

## 状态管理

- [riverpod: ^2.4.6](https://pub.dev/packages/riverpod) https://github.com/rrousselGit/riverpod
- [flutter_riverpod: ^2.4.6](https://pub.dev/packages/flutter_riverpod)
- [hooks_riverpod: ^2.4.6](https://pub.dev/packages/hooks_riverpod)

- [jetpack: ^1.0.3](https://pub.dev/packages/jetpack) 一组抽象的实用程序，灵感来自 Android Jetpack
- [provider: ^6.1.1](https://pub.dev/packages/provider) 对 InheritedWidget 组件的上层封装，使其更易用，更易复用。 🚀，用于帮助管理 flutter 应用程序中的状态。
- [nested: ^1.0.0](https://pub.dev/packages/nested) 一个小组件，用于简化深度嵌套小组件树的语法。

## ref

Ref: 这是一个支持flutter数据响应式的组合Api插件

响应式，简单，灵活，可组合，可移植性高，侵入性低。支持数据同步修改，缓存队列异步刷新。

https://gitee.com/kgm0515/flutter_ref
https://pub.dev/packages/ref

### 特征

- Ref：把数据包装成一个响应式对象
- RefBuilder：数据修改通知对应的widget刷新
- Ref.update：内部监听所有响应对象的读取和修改，执行副作用并更新widget
- RefCompute：支持计算属性
- RefWatch：数据修改，执行副作用
- RefKey：可以很方便的代理复杂响应式对象的某一个属性值
- refKeys： 函数，可以把一个复杂响应式对象的所有键代理到一个简单对象中，返回一个Map<dynamic, RefKey>对象
- ...

## path_provider: ^2.1.1

一个 Flutter 插件，用于查找文件系统上的常用位置。支持 Android、iOS、Linux、macOS 和
Windows。并非所有平台都支持所有方法。

- [path_provider: ^2.1.1](https://pub.dev/packages/path_provider)

## cached_network_image

一个 flutter 库，用于显示来自 Internet 的图像并将它们保存在缓存目录中。

https://github.com/Baseflow/flutter_cached_network_image

- [cached_network_image: ^3.3.0](https://pub.dev/packages/cached_network_image)
- [flutter_cache_manager: ^3.3.1](https://pub.dev/packages/flutter_cache_manager)
- [octo_image: ^2.0.0](https://pub.dev/packages/octo_image)

## swiper

flutter 最强大的 swiper, 多种布局方式，无限轮播，Android 和 iOS 双端适配.

https://github.com/feicien/flutter_swiper_view

- [CarouselView] 系统自带
- [flutter_swiper_view: ^1.1.8](https://pub.dev/packages/flutter_swiper_view)
- [card_swiper: ^3.0.1](https://pub.dev/packages/card_swiper)
- [carousel_slider: ^4.2.1](https://pub.dev/packages/carousel_slider)

## flutter_html

一个 Flutter widget，用于将 HTML 和 CSS 渲染为 Flutter widget。

https://github.com/Sub6Resources/flutter_html

- [flutter_html: ^3.0.0-beta.2](https://pub.dev/packages/flutter_html/versions/3.0.0-beta.2)
- [html: ^0.15.3](https://pub.dev/packages/html) A Dart implementation of an HTML5 parser.
- [csslib: ^0.17.2](https://pub.dev/packages/csslib)
- [collection: ^1.17.0](https://pub.dev/packages/collection)
- [list_counter: ^1.0.2](https://pub.dev/packages/list_counter)

## lottie

Lottie 是一个适用于 Android 和 iOS 的移动库，它使用 Bodymovin 解析导出为 json 的 Adobe After Effects
动画，并在移动设备上原生渲染它们！

- [lottie: ^2.7.0](https://pub.dev/packages/lottie)
- [lottie: ^3.1.2](https://pub.dev/packages/lottie)

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

## flutter_gen

```dart
// 构建 loader
var fontLoader = FontLoader('FenPinYinTi2');
// 获取字体 (Future<ByteData>) 装载到 loader
fontLoader.addFont(fetchFontByteData());
// 加载字体
await fontLoader.load();

// 这里 DefaultAssetBundle.of(context) 也可以替换成 rootBundle
// 根据自身情况决定
Future<ByteData> fetchFontByteData() => DefaultAssetBundle.of(context).load('fonts/FenPinYinTi2.ttf');
```

```dart
// load font file
Future loadFontFile() async {
    var fontLoader = FontLoader('FenPinYinTi2');
    fontLoader.addFont(fetchFontByteData());
    await fontLoader.load().catchError((e) {
      loge("loadFontFile erro: $e");
    });
    setState(() {});
}

Future<ByteData> fetchFontByteData() => DefaultAssetBundle.of(context).load('fonts/FenPinYinTi2.ttf');
```

- [FontLoader] https://juejin.cn/post/6844904113168187405 加载自定义字体. `FontLoader#addFont` 目前仅支持 OpenType （OTF） 和 TrueType （TTF） 字体。

用于资产、字体、颜色等的 Flutter 代码生成器 — 摆脱所有基于字符串的 API。

- [flutter_gen: ^5.3.2](https://pub.dev/packages/flutter_gen)

## flutter_svg

使用 Flutter 绘制 SVG 文件。

https://github.com/dnfield/flutter_svg/tree/master/packages/flutter_svg

https://github.com/dnfield/vector_graphics

- [flutter_svg: ^2.0.9](https://pub.dev/packages/flutter_svg)
- [vector_graphics: ^1.1.9+1](https://pub.dev/packages/vector_graphics)
- [vector_graphics_codec: ^1.1.9+1](https://pub.dev/packages/vector_graphics_codec)
- [vector_graphics_compiler: ^1.1.9+1](https://pub.dev/packages/vector_graphics_compiler) 此包将 SVG 文件解析为 vector_graphics 运行时可以呈现的格式。
- [svg_path_parser: ^1.1.1](https://pub.dev/packages/svg_path_parser) 一个 Flutter/Dart 实用程序，用于将 SVG 路径解析为库中的 dart:ui 等效 Path 对象。
- [animated_svg: ^2.1.0](https://pub.dev/packages/animated_svg) 用于显示可缩放矢量图形 1.1 文件并为其设置动画的Flutter包。该包仅用Dart语言编写。

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
- [showcaseview: ^3.0.0](https://pub.dev/packages/showcaseview) Flutter 包允许您逐步展示/突出显示您的小部件。
- [flutter_intro: ^3.2.3](https://pub.dev/packages/flutter_intro) 为您的 Flutter 项目提供新功能介绍和分步用户指南的更好方法。
- [el_tooltip: ^2.0.0](https://pub.dev/packages/el_tooltip) 智能定位工具提示。
- [popover: ^0.3.0+1](https://pub.dev/packages/popover) Popover for Flutter Flutter 的弹出窗口
- [bot_toast: ^4.1.3](https://pub.dev/packages/bot_toast) 一个真正意义上的flutter Toast库!

## flutter_neumorphic

一个完整的、随时可用的、用于 Flutter 的 Neumorphic ui 套件

https://github.com/Idean/Flutter-Neumorphic

- [flutter_neumorphic: ^3.2.0](https://pub.dev/packages/flutter_neumorphic)

## flutter_colorpicker

HSV（HSB）/HSL/RGB/材质颜色选择器的灵感来自您令人惊叹的 FLUTTER 应用程序的所有优秀设计。
开箱即用的可爱颜色选择器，具有高度定制的小部件，可满足所有开发人员的需求。

- [flutter_colorpicker: ^1.0.3](https://pub.dev/packages/flutter_colorpicker)
- [flutter_material_color_picker: ^1.2.0](https://pub.dev/packages/flutter_material_color_picker)
  默认情况下，它是材质颜色，但您可以定义自己的颜色。
- [flutter_hsvcolor_picker: ^1.5.0](https://pub.dev/packages/flutter_hsvcolor_picker) 专为您的
  Flutter 应用程序设计的 HSV 颜色选择器。
- [iglu_color_picker_flutter: ^1.0.4](https://pub.dev/packages/iglu_color_picker_flutter)
- [flex_color_picker: ^3.3.0](https://pub.dev/packages/flex_color_picker) FlexColorPicker 是 Flutter
  的可自定义颜色选择器。 ColorPicker 可以显示六种不同类型的颜色选择器，其中三种用于标准的 Flutter
  Material Design 2 颜色及其阴影。用于拣选物品的尺寸和样式可以定制。
- [fast_color_picker: ^0.1.1](https://pub.dev/packages/fast_color_picker)
- [color: ^3.0.0](https://pub.dev/packages/color) 一个简单的 Dart 包，它公开了一个 Color
  类，可用于创建、转换和比较颜色。

## flutter_smart_dialog: ^4.9.5+1

一个优雅的 Flutter Dialog 解决方案。

- [flutter_smart_dialog: ^4.9.5+1](https://pub.dev/packages/flutter_smart_dialog) 一个优雅的 Flutter Dialog 解决方案。
- [awesome_dialog: ^3.1.0](https://pub.dev/packages/awesome_dialog) 一个新的 Flutter 包项目，用于简单而精彩的对话

## hive: ^2.2.3

- [hive: ^2.2.3](https://pub.dev/packages/hive) Hive 是一个用纯 Dart 编写的轻量级且快速的键值数据库。灵感来自Bitcask。
- [isar: ^3.1.0+1](https://pub.dev/packages/isar) 💙 专为 Flutter 而生。易于使用，无需配置，无需样板

## 动画

https://guoshuyu.cn/home/wx/Z1.html

- [animated_text_kit: ^4.2.2](https://pub.dev/packages/animated_text_kit) 一个 flutter 包，其中包含一些很酷和很棒的文本动画的集合。Codemagic 电子书“我们喜欢的 Flutter 库”中文本动画的推荐包。试用我们的实时示例应用程序。
- [pretty_animated_text: ^3.0.1](https://pub.dev/packages/pretty_animated_text) 一款文本动画 UI 插件，为您提供美观且可自定义的动画文本小部件，以便您在项目中轻松使用它们。 文本动画采用基于物理的动画技术，提供流畅愉悦的体验。
- [animate_do: ^3.1.2](https://pub.dev/packages/animate_do) 受 Animate.css 启发的动画包，仅使用 Flutter 动画构建，零依赖性。
- [auto_animated: ^3.2.0](https://pub.dev/packages/auto_animated) 一个 Flutter 包，用于创建动画列表。
- [simple_animations: ^5.0.2](https://pub.dev/packages/simple_animations) Simple Animations 简化了创建精美自定义动画的过程：
- [animations: ^2.0.8](https://pub.dev/packages/animations) 用于 Flutter 的高质量预构建动画
- [spring: ^2.0.2](https://pub.dev/packages/spring) 一个简单而强大的预构建动画套件。
- [animated_flip_counter: ^0.2.6](https://pub.dev/packages/animated_flip_counter) 一个隐式动画小部件，从一个数字翻转到另一个数字。
- [odometer: ^3.0.0](https://pub.dev/packages/odometer) 计数器动画
- [animated_digit: ^3.2.3](https://pub.dev/packages/animated_digit) 滚动动画数字小部件，任何需要动画效果的数字，易于使用。
- [flutter_animate: ^4.3.0](https://pub.dev/packages/flutter_animate) 一个高性能的库，可以简单地在 Flutter 中添加几乎任何类型的动画效果。
- [animated_size_and_fade: ^3.0.1](https://pub.dev/packages/animated_size_and_fade) 在两个小部件之间执行淡入淡出和大小过渡。[AnimatedSize]+[AnimatedSwitcher]
- [loading_animation_widget: ^1.2.1](https://pub.dev/packages/loading_animation_widget) 加载动画小部件

## 国际化

`arb`占位符、复数和选项:
https://flutter.cn/docs/ui/accessibility-and-internationalization/internationalization#placeholders-plurals-and-selects

配置 l10n.yaml 文件:
https://flutter.cn/docs/ui/accessibility-and-internationalization/internationalization#configuring-the-l10nyaml-file

- [easy_localization: ^3.0.3](https://pub.dev/packages/easy_localization) 轻松快速地实现 Flutter
  应用的国际化
- [intl: ^0.18.1](https://pub.dev/packages/intl)
  提供国际化和本地化功能，包括消息翻译、复数和性别、日期/数字格式和解析以及双向文本。 https://github.com/cfug/flutter.cn/tree/main/examples/internationalization/gen_l10n_example
- [intl_utils: ^2.8.5](https://pub.dev/packages/intl_utils) Dart 包，用于在 .arb 文件中的翻译和
  Flutter 应用之间创建绑定。它为官方 Dart Intl 库生成样板代码，并为 Dart 代码中的键添加自动完成功能。

## others

https://github.com/fluttercommunity/plus_plugins

- [logging: ^1.2.0](https://pub.dev/packages/logging) 日志消息处理程序, 并不输出日志。
- [quiver: ^3.2.1](https://pub.dev/packages/quiver) Quiver 是一组 Dart 的实用程序库，它使许多 Dart 库的使用更轻松、更方便，或者添加了额外的功能。
- [flutter_simple_treeview: ^3.0.2](https://pub.dev/packages/flutter_simple_treeview)此小部件可视化了树形结构，其中节点可以是任何小部件。
- [file: ^7.0.0](https://pub.dev/packages/file) Dart 的通用文件系统抽象。
- [json_serializable: ^6.7.1](https://pub.dev/packages/json_serializable) 为操作 JSON 提供 Dart构建系统构建器。
- [vector_math: ^2.1.4](https://pub.dev/packages/vector_math) 用于 2D 和 3D 应用程序的矢量数学库。
- [matrix4_transform: ^3.0.0](https://pub.dev/packages/matrix4_transform) 此包是一个辅助数学类，可以轻松创建 Matrix4 转换。
- [get_it: ^7.6.4](https://pub.dev/packages/get_it)
- [watch_it: ^1.1.0](https://pub.dev/packages/watch_it) 由 get_it 提供支持的简单状态管理解决方案。
- [rxdart: ^0.27.7](https://pub.dev/packages/rxdart) RxDart 扩展了 Dart Streams 和 StreamController 的功能。
- [flutter_blurhash: ^0.7.0](https://pub.dev/packages/flutter_blurhash) 图像占位符的紧凑表示形式。模糊图片占位
- [flutter_page_lifecycle: ^1.1.0](https://pub.dev/packages/flutter_page_lifecycle) Android 的 onResume/onPause 和 iOS 的 viewDidAppear/viewDidDisappear 用于 Flutter。
- [flutter_lifecycle_aware: ^0.0.3](https://pub.dev/packages/flutter_lifecycle_aware)flutter_lifecycle 借鉴原生平台 Android/iOS 的生命周期思想，实现了在 Flutter 上的一套生命周期系统。开发者可以在任何你需要的地方感知 StatefulWidget 的生命周期。
- [lifecycle_aware_state: ^0.0.4](https://pub.dev/packages/lifecycle_aware_state) 生命周期回调，用于了解 flutter 项目中路由导航和状态生命周期中的不同事件
- [lifecycle: ^0.8.0](https://pub.dev/packages/lifecycle) 对 Flutter widget 的生命周期支持。
- [flutter_responsive: ^1.1.0](https://pub.dev/packages/flutter_responsive)这个插件提供了一种简单而高效的方式来处理移动、桌面和 Web 中 Flutter 应用程序的响应式布局，允许你的布局适应和包装小部件（容器、行、列和 RichText）引用他的父元素的大小。
- [apivideo_live_stream: ^1.1.3](https://pub.dev/packages/apivideo_live_stream) api.video 是产品构建者的视频基础设施。闪电般快速的视频 API，用于集成、扩展和管理应用中的点播和低延迟直播功能。 https://api.video/
- [apivideo_player: ^1.2.0](https://pub.dev/packages/apivideo_player) api.video 是产品构建者的视频基础设施。闪电般快速的视频 API，用于集成、扩展和管理应用中的点播和低延迟直播功能。
- [flutter_slidable: ^3.0.1](https://pub.dev/packages/flutter_slidable) 一个 Flutter 小部件，用于实现滑动删除列表项，支持左滑和右滑两种操作。 可滑动列表项的 Flutter 实现，具有可以关闭的方向滑动操作。
- [flutter_staggered_grid_view: ^0.7.0](https://pub.dev/packages/flutter_staggered_grid_view)提供颤振网格布局的集合。瀑布流
- [waterfall_flow: ^3.0.3](https://pub.dev/packages/waterfall_flow)能够快速构建瀑布流布局的列表.
- [value_layout_builder: ^0.3.1](https://pub.dev/packages/value_layout_builder)布局过程中使用值来构建子项。这个小部件类似于 LayoutBuilder，但它允许您使用值来构建子项，而不是使用约束。
- [overflow_view: ^0.3.1](https://pub.dev/packages/overflow_view)如果没有足够的空间，则在一行中显示子项的小部件，末尾有一个溢出指示器。
- [flutter_sticky_header: ^0.6.5](https://pub.dev/packages/flutter_sticky_header) 带有条子的粘性标头的 Flutter 实现。
- [visual_effect: ^0.0.5](https://pub.dev/packages/visual_effect) VisualEffect API for Flutter 可以轻松地在小部件上添加绘画效果。
- [local_hero: ^0.2.0](https://pub.dev/packages/local_hero) 当英雄动画在同一路线内的位置发生变化时，隐式启动英雄动画的小部件。
- [auto_size_text: ^3.0.0](https://pub.dev/packages/auto_size_text) Flutter 小部件，可自动调整文本大小以使其完全适合其边界。
- [video_player: ^2.8.1](https://pub.dev/packages/video_player) 适用于 iOS、Android 和 Web 的 Flutter 插件，用于在 Widget 表面上播放视频。
- [showcaseview: ^2.0.3](https://pub.dev/packages/showcaseview) Flutter 包允许你一步一步地展示/突出显示你的小部件。
- [rich_readmore: ^1.1.1](https://pub.dev/packages/rich_readmore) 折叠和展开文本内容,支持span
- [retrofit: ^4.0.3](https://pub.dev/packages/retrofit) retrofit.dart 是一个使用 source_gen 并受 Chopper 和 Retrofit 启发的类型转换 dio 客户端生成器。
- [intl_phone_number_input: ^0.7.3+1](https://pub.dev/packages/intl_phone_number_input)  一个简单且可定制的 flutter 包，用于以国际/国际格式输入电话号码，使用 Google 的 libphonenumber
- [markdown: ^7.1.1](https://pub.dev/packages/markdown) 用 Dart 编写的可移植 Markdown 库。它可以在客户端和服务器上将 Markdown 解析为 HTML。
- [flutter_markdown: ^0.6.18+2](https://pub.dev/packages/flutter_markdown) Flutter 的 Markdown 渲染器。它支持原始格式，但不支持内联 HTML。
- [markdown_widget: ^2.3.2+2](https://pub.dev/packages/markdown_widget)支持TOC功能，可以通过Heading快速定位;支持代码高亮;支持夜间模式;
- [flutter_keyboard_visibility: ^5.4.1](https://pub.dev/packages/flutter_keyboard_visibility)对键盘可见性更改做出反应。
- [virtual_keypad: ^0.8.1](https://pub.dev/packages/virtual_keypad)适用于 Flutter 的可自定义虚拟键盘​​、屏幕键盘和数字键盘。 专为自助服务终端应用、触摸屏和桌面输入、PIN 码和密码输入、数字键盘和数字小键盘流程以及自定义文本字段集成而设计。
- [scroll_to_index: ^3.0.1](https://pub.dev/packages/scroll_to_index) 该软件包为 Flutter 可滚动小部件提供了固定/可变行高的滚动到索引机制。
- [scrollview_observer: ^1.21.0](https://pub.dev/packages/scrollview_observer) flutter_scrollview_observer 这是一个可用于监听滚动视图中正在显示的子部件的组件库。
- [indexed_list_view: ^3.0.1](https://pub.dev/packages/indexed_list_view) 按索引跳转到任何项目。
- [matrix_gesture_detector: ^0.1.0](https://pub.dev/packages/matrix_gesture_detector)MatrixGestureDetector 检测平移、缩放和旋转手势，并将它们组合成 Matrix4 可由 Transform 小部件或低级 CustomPainter 代码使用的对象。
- [matrix_gesture_detector_pro: ^1.0.0](https://pub.dev/packages/matrix_gesture_detector_pro) https://github.com/zhaolongs/matrix_gesture_detector_pro
- [flutter_slidable: ^3.0.1](https://pub.dev/packages/flutter_slidable) 滑动删除列表项，支持左滑和右滑两种操作。
- [connectivity_plus: ^5.0.2](https://pub.dev/packages/connectivity_plus) 监视网络连接状态（WiFi、移动数据、蜂窝）。
- [network_info_plus: ^5.0.3](https://pub.dev/packages/network_info_plus) 该插件允许 Flutter 应用程序发现网络信息并相应地进行自我配置。 获取wifi相关信息
- [highlight: ^0.7.0](https://pub.dev/packages/highlight) Dart 语法高亮库。
- [flutter_highlight: ^0.7.0](https://pub.dev/packages/flutter_highlight) 语法高亮, 代码高亮小部件，支持 170+ 语言和 80+ 风格。
- [substring_highlight: ^1.0.33](https://pub.dev/packages/substring_highlight) 在字符级别突出显示 Flutter 文本。
- [highlightable: ^1.0.5](https://pub.dev/packages/highlightable) 一个文本小部件替代方案，它突出显示了定义的字符（来自模式/纯字符串）
- [search_highlight_text: ^1.0.0+2](https://pub.dev/packages/search_highlight_text)用于突出显示搜索结果中的文本，具有自定义突出显示 Color 和突出显示 TextStyle。
- [particle_field: ^1.0.0](https://pub.dev/packages/particle_field) 用于向 UI 添加高性能的自定义粒子效果。
- [rnd: ^0.2.0](https://pub.dev/packages/rnd) 一个 Dart 包，用于生成伪随机数。
- [statsfl: ^2.3.0](https://pub.dev/packages/statsfl) 一个简单的 Flutter FPS 监视器，用于监视应用程序的帧速率。
- [screen_recorder: ^0.2.0](https://pub.dev/packages/screen_recorder) 这是一个用于创建 Flutter 小部件记录的包。录音可以导出为 GIF。
- [ffmpeg_kit_flutter: ^6.0.3](https://pub.dev/packages/ffmpeg_kit_flutter) 一个 Flutter 插件，用于在 Android 和 iOS 上使用 FFmpeg。
- [flutter_video_compress: ^0.3.7+8](https://pub.dev/packages/flutter_video_compress) 一个 Flutter 插件，用于压缩视频文件。
- [video_editor: ^3.0.0](https://pub.dev/packages/video_editor) 一个 Flutter 插件，用于编辑视频文件。
- [video_trimmer: ^3.0.1](https://pub.dev/packages/video_trimmer) 一个 Flutter 插件，用于裁剪视频文件。
- [video_compress: ^3.1.2](https://pub.dev/packages/video_compress) 通过这个轻量级高效的库压缩视频、删除音频、处理缩略图并使您的视频与所有平台兼容。
- [flutter_swipe_detector: ^2.0.0](https://pub.dev/packages/flutter_swipe_detector) 一个 Flutter 小部件，用于检测向左、向右、向上和向下的滑动手势。
- [flutterme_credit_card: ^1.0.2](https://pub.dev/packages/flutterme_credit_card) 这是 Flutterme 的信用卡可定制小部件和验证包。
- [new_image_crop: ^1.0.0+2](https://pub.dev/packages/new_image_crop) 用于裁剪图像。
- [custom_flutter_painter: ^1.0.1](https://pub.dev/packages/custom_flutter_painter) 用于绘画的纯 Flutter 包。
- [flutter_painter_v2: ^2.0.1](https://pub.dev/packages/flutter_painter_v2) 用于绘画的纯 Flutter 包。 https://github.com/omarhurani/flutter_painter
- [dropdown_button2: ^2.3.9](https://pub.dev/packages/dropdown_button2) Flutter 的核心下拉按钮小部件，带有稳定的下拉菜单和许多其他选项，您可以根据需要进行自定义。
- [pdf: ^3.10.7](https://pub.dev/packages/pdf) 用于创建 PDF 的 Dart 包。
- [pdfrx: ^0.3.1](https://pub.dev/packages/pdfrx) pdfrx 是建立在 pdfium 之上的 PDF 查看器实现。该插件目前支持 Android、iOS、Windows、macOS、Linux 和 Web。
- [syncfusion_flutter_pdf: ^24.1.43](https://pub.dev/packages/syncfusion_flutter_pdf) Flutter PDF 是一个功能丰富且高性能的非 UI PDF 库，用 Dart 原生编写。它允许您向 Flutter 应用程序添加强大的 PDF 功能。
- [syncfusion_flutter_pdfviewer: ^24.1.43](https://pub.dev/packages/syncfusion_flutter_pdfviewer)Flutter PDF Viewer 插件可让您在 Android、iOS、Web、Windows 和 macOS 平台上无缝高效地查看 PDF 文档。它具有高度交互和可定制的功能，例如放大、虚拟双向滚动、页面导航、文本选择、文本搜索、页面布局选项、文档链接导航、书签导航、表单填写和使用文本标记注释进行审阅。
- [barcode: ^2.2.5](https://pub.dev/packages/barcode) Dart 的条码生成库，可以为任何后端生成通用绘图操作。
- [barcode_widget: ^2.0.4](https://pub.dev/packages/barcode_widget) 生成条形码小部件。此小部件使用 pub：barcode 生成任何支持的条形码。
- [pubspec_extract: ^2.0.5](https://pub.dev/packages/pubspec_extract) 提取 Dart pubspec.yaml 文件并在构建时生成 pubspec.dart。
- [lpinyin: ^2.0.3](https://pub.dev/packages/lpinyin) lpinyin是一个汉字转拼音的Dart Package.
- [table_calendar: ^3.0.9](https://pub.dev/packages/table_calendar) 高度可定制、功能丰富的 Flutter 日历小部件。
- [ninepatch_image: ^0.0.3](https://pub.dev/packages/ninepatch_image) Flutter 的可调整大小的位图（九块图像）.9图片
- [flutter_popup: ^3.1.8](https://pub.dev/packages/flutter_popup) flutter_popup 包是一个方便的工具，使您能够在 Flutter 应用程序中显示一个简单且可自定义的弹出窗口。它提供了一个突出显示功能，可用于根据需要将用户的注意力引导到特定区域。
- [azlistview: ^2.0.0](https://pub.dev/packages/azlistview) Flutter 城市列表、联系人列表，索引&悬停。基于scrollable_positioned_list.
- [flutter_layout_grid: ^2.0.5](https://pub.dev/packages/flutter_layout_grid) 一个强大的 Flutter 网格布局系统，针对复杂的用户界面设计进行了优化。
- [flutter_constraintlayout: ^1.7.0-stable](https://pub.dev/packages/flutter_constraintlayout)一个超级强大的 Stack，使用约束构建极为灵活的布局，和 Android 下的 ConstraintLayout 和 iOS 下的 AutoLayout 类似。但代码实现却高效得多，它具有 O(n) 的布局时间复杂度，无需线性方程求解。
- [layout: ^1.0.5](https://pub.dev/packages/layout) 响应式布局的工具。
- [flutter_wall_layout: ^2.1.1](https://pub.dev/packages/flutter_wall_layout) 用于在墙上布置小部件。
- [network_to_file_image: ^6.0.0](https://pub.dev/packages/network_to_file_image)从网络加载/下载图像并将其保存到本地文件系统中。
- [device_frame: ^1.1.0](https://pub.dev/packages/device_frame) 常见设备的模型。
- [device_preview: ^1.1.0](https://pub.dev/packages/device_preview) 大致了解您的应用在其他设备上的外观和性能。
- [badges: ^3.1.2](https://pub.dev/packages/badges) Flutter 的徽章小部件。
- [dartx: ^1.2.0](https://pub.dev/packages/dartx) Dart 的扩展方法。
- [crimson: ^0.3.1](https://pub.dev/packages/crimson) 快速、高效且易于使用的 Dart JSON 解析器和序列化器。
- [auto_size_text: ^3.0.0](https://pub.dev/packages/auto_size_text) Flutter 小部件，可自动调整文本大小以使其完全适合其边界。
- [text_sizer_plus: ^1.0.5](https://pub.dev/packages/text_sizer_plus) Flutter 小部件可自动调整文本大小以完全适合其边界最新版本。
- [auto_size_text_field: ^2.2.2](https://pub.dev/packages/auto_size_text_field) ✍️ Flutter TextField 小部件，可自动调整文本字段的大小以使其完全适合其边界。
- [auto_size_widget: ^0.0.4](https://pub.dev/packages/auto_size_widget) 一个 Flutter 小部件，可以通过拖动小部件的角来调整子小部件的大小。
- [path_drawing: ^1.0.1](https://pub.dev/packages/path_drawing) 一个 Flutter 库，用于帮助创建和操作路径。
- [path_parsing: ^1.0.1](https://pub.dev/packages/path_parsing) 从 Flutter 路径绘制库中分离出来，创建一个纯 Dart 解析库，用于 SVG 路径和代码生成（不依赖 Flutter 运行时）。
- [equatable: ^2.0.5](https://pub.dev/packages/equatable) 能够比较对象 Dart 通常涉及必须覆盖 == 运算符以及 hashCode 。
- [regex_router: ^2.0.2](https://pub.dev/packages/regex_router) 支持正则表达式路径的材料路由器。路由参数解析。
- [primer_progress_bar: ^0.4.1](https://pub.dev/packages/primer_progress_bar) Primer 的进度条由 3 个组件组成：分段条、图例和图例项。进度条可以在水平条中显示多个彩色段，图例放置在条形下方，其中包含每个段的对齐说明。
- [flutter_adaptive_scaffold: ^0.1.8](https://pub.dev/packages/flutter_adaptive_scaffold) 自适应, AdaptiveScaffold 对来自用户、设备和屏幕元素的输入做出反应，并根据 Material 3 指南渲染你的 Flutter 应用程序。
- [palette_generator: ^0.3.3+3](https://pub.dev/packages/palette_generator) 一个 Flutter 包，用于从图像中提取突出的颜色，通常用于查找用户界面的颜色。
- [leak_tracker: ^10.0.4](https://pub.dev/packages/leak_tracker) 一个用于检测内存泄漏的 Flutter 插件。
- [modal_bottom_sheet: ^3.0.0](https://pub.dev/packages/modal_bottom_sheet) 创建令人敬畏且功能强大的模态底板。
- [shimmer: ^3.0.0](https://pub.dev/packages/shimmer) 一个 Flutter 包，用于创建闪烁效果。
- [flutter_rating_bar: ^4.0.1](https://pub.dev/packages/flutter_rating_bar)一个简单但完全可定制的颤振评级栏，其中还包括评级栏指示器，支持任何评级分数。
- [flutter_inappwebview: ^6.0.0](https://pub.dev/packages/flutter_inappwebview)一个 Flutter 插件，允许您添加内联 Web 视图、使用无头 Web 视图以及打开应用内浏览器窗口。
- [stack_trace: ^1.11.1](https://pub.dev/packages/stack_trace) 该库提供了解析、检查和操作底层 Dart 实现生成的堆栈跟踪的能力。它还提供了以比本机 StackTrace 实现更可读的格式生成堆栈跟踪的字符串表示形式的函数。
- [grpc: ^4.0.0](https://pub.dev/packages/grpc) gRPC 的 Dart 实现：一个高性能、开源、通用的 RPC 框架，将移动和 HTTP/2 放在首位。
- [json_rpc_2: ^3.0.2](https://pub.dev/packages/json_rpc_2) 实现 JSON-RPC 2.0 规范的库。
- [udp: ^5.0.3](https://pub.dev/packages/udp) Dart 的轻量级 UDP 库。
- [cronet_http: ^1.3.2](https://pub.dev/packages/cronet_http) 一个 Android Flutter 插件，提供对 Cronet HTTP 客户端的访问。
- [encrypt: ^5.0.3](https://pub.dev/packages/encrypt) 一组基于 PointyCastle 的高级 API，用于双向加密。 具有 PKCS1 和 OAEP 编码的 RSA SHA256 with RSA
- [jsonc: ^0.0.3](https://pub.dev/packages/jsonc) 带有注释和尾随逗号的 JSON。

## 平台特有

- [keep_screen_on: ^3.0.0](https://pub.dev/packages/keep_screen_on) 该插件禁用自动屏幕关闭并防止屏幕关闭。
- [vibration: ^1.8.4](https://pub.dev/packages/vibration) 一个 Flutter 插件，用于在 Android 和 iOS 上控制设备振动。
- [haptic_feedback: ^0.4.2](https://pub.dev/packages/haptic_feedback) 一个 Flutter 插件，用于在 Android 和 iOS 上触发触觉反馈。
- [camera: ^0.10.5+5](https://pub.dev/packages/camera) 适用于 iOS、Android 和 Web 的 Flutter 插件，允许访问设备摄像头。
- [quick_actions: ^1.0.6](https://pub.dev/packages/quick_actions) 这个 Flutter 插件允许您管理应用程序的主屏幕快速操作并与之交互。
- [awesome_notifications: ^0.8.2](https://pub.dev/packages/awesome_notifications) 在 Flutter 上使用自定义本地和推送通知吸引用户。获取实时事件，绝不会错过用户与 Awesome Notifications 的互动。
- [intent: ^1.4.0](https://pub.dev/packages/intent) 一个简单的 flutter 插件来处理 Android Intents。
- [android_intent_plus: ^4.0.3](https://pub.dev/packages/android_intent_plus) 该插件允许 Flutter 应用程序在平台为 Android 时启动任意意图。
- [device_info_plus: ^9.1.0](https://pub.dev/packages/device_info_plus) 从 Flutter 应用程序中获取当前设备信息。
- [package_info_plus: ^4.2.0](https://pub.dev/packages/package_info_plus) 这个 Flutter 插件提供了一个 API，用于查询有关应用程序包的信息。
- [share_plus: ^7.2.1](https://pub.dev/packages/share_plus) 一个 Flutter 插件，用于通过平台的共享对话框共享 Flutter 应用程序中的内容。
- [flutter_downloader: ^1.11.4](https://pub.dev/packages/flutter_downloader) 用于创建和管理下载任务的插件。支持 iOS 和 Android。
- [restart_app: ^1.2.1](https://pub.dev/packages/restart_app) 一个 Flutter 插件，可帮助您使用原生 API 通过单个函数调用重新启动整个 Flutter 应用。
- [open_filex: ^4.3.4](https://pub.dev/packages/open_filex)一个可以调用原生APP打开字符串导致颤动文件的插件，支持iOS（DocumentInteraction）/android（intent）/PC（ffi）/web（dart：html）
- [location: ^5.0.3](https://pub.dev/packages/location) 这个 Flutter 插件处理在 Android 和 iOS 上获取位置。它还在位置更改时提供回调。
- [video_compress: ^3.1.2](https://pub.dev/packages/video_compress)通过这个轻量级高效的库压缩视频、删除音频、处理缩略图并使您的视频与所有平台兼容。
- [mobile_scanner: ^3.5.2](https://pub.dev/packages/mobile_scanner) 基于 MLKit 的 Flutter 通用条码和二维码扫描仪。在 Android 上使用 CameraX，在 iOS 上使用 AVFoundation。
- [barcode_scanner: ^3.6.2](https://pub.dev/packages/barcode_scanner) Scanbot Flutter 条码扫描器插件使您能够轻松实现适用于 iOS 和 Android 的 Scanbot 条码扫描器 SDK。
- [flutter_barcode_scanner: ^2.0.0](https://pub.dev/packages/flutter_barcode_scanner) 一个用于 Flutter 应用程序的插件，可在 Android 和 iOS 上添加条形码扫描支持。
- [flutter_mrz_scanner: ^2.1.0](https://pub.dev/packages/flutter_mrz_scanner) 使用 iOS 和 Android 扫描身份证件（护照、身份证、签证）的 MRZ（机器可读区域）。被 QKMRZScanner 严重啃食。
- [file_picker: ^6.1.1](https://pub.dev/packages/file_picker) 一个包，允许您使用本机文件资源管理器来选取单个或多个文件，并具有扩展筛选支持。
- [file_selector: ^1.0.3](https://pub.dev/packages/file_selector) 一个 Flutter 插件，用于管理文件和与文件对话框的交互。
- [excel: ^3.0.0](https://pub.dev/packages/excel) Excel 是一个 flutter 和 dart 库，用于读取、创建和更新 XLSX 文件的 excel 工作表
- [uri_to_file: ^1.0.0](https://pub.dev/packages/uri_to_file) 一个 Flutter 插件，用于将支持的 uri 转换为文件。支持 Android 和 iOS。
- [flutter_file_downloader: ^1.1.4](https://pub.dev/packages/flutter_file_downloader) 一个简单的 flutter 插件，可将所有文件类型下载到所有 android 设备的下载目录。当 android 10 问世时，隐私限制发生了很大的变化，并且没有足够的 flutter 相关信息，所以我想出了一个简单的 ANDROID 插件来下载任何文件类型到下载目录 此外，它还具有回调和进度侦听器，安装非常简单 注意：此插件不是为 iOS 构建的， 它根本不会影响它。
- [app_settings: ^5.1.1](https://pub-web.flutter-io.cn/packages/app_settings) 一个 Flutter 插件，用于从应用程序打开 iOS 和 Android 手机设置。
- [flutter_local_notifications: ^16.3.0](https://pub.dev/packages/flutter_local_notifications)用于显示本地通知的跨平台插件。ANDROID IOS LINUX MACOS
- [flutter_app_badger: ^1.5.0](https://pub.dev/packages/flutter_app_badger) 在启动器中更改应用程序徽章的功能。
- [flutter_app_icon_badge: ^2.0.0](https://pub.dev/packages/flutter_app_icon_badge) 更改应用图标上的徽章。 ANDROID IOS MACOS
- [geolocator: ^10.1.0](https://pub.dev/packages/geolocator) 一个 Flutter 地理定位插件，它提供了对平台特定位置服务的轻松访问（FusedLocationProviderClient，或者如果不可用，Android 上的 LocationManager 和 iOS 上的 CLLocationManager）。
- [geocoding: ^2.1.1](https://pub.dev/packages/geocoding) 一个 Flutter Geocoding 插件，提供简单的地理编码和反向地理编码功能。
- [permission_handler: ^11.1.0](https://pub.dev/packages/permission_handler)该插件提供了一个跨平台（iOS、Android）API 来请求权限并检查其状态。您还可以打开设备的应用设置，以便用户可以授予权限。https://github.com/baseflow/flutter-permission-handler
- [image_picker: ^1.0.7](https://pub.dev/packages/image_picker) 适用于 iOS 和 Android 的 Flutter 插件，用于从图像库中挑选图像，并使用相机拍摄新照片。
- [image_gallery_saver: ^2.0.3](https://pub.dev/packages/image_gallery_saver) 我们使用插件 image_picker 从 Android 和 iOS 图像库中选择图像，但它无法将图像保存到图库中。这个插件可以提供这个功能。
- [flutter_contacts: ^1.1.7+1](https://pub.dev/packages/flutter_contacts) Flutter 插件，用于读取、创建、更新、删除和观察 Android 和 iOS 上的原生联系人，具有群组支持、vCard 支持和联系人权限处理。
- [upload_file_oss: ^1.0.0](https://pub.dev/packages/upload_file_oss) 一个简单上传文件到阿里云对象存储OSS的库。 仅支持小文件上传。
- [nsd: ^3.0.0](https://pub.dev/packages/nsd) 用于网络服务发现和注册的 Flutter 插件（又名 NSD / DNS-SD / Bonjour / mDNS）。
- [flutter_nsd: ^1.4.0](https://pub.dev/packages/flutter_nsd) 一个用于 Android、iOS、MacOS 和 Windows 上的网络服务发现 （mDNS） 的 Flutter 插件。该插件尽可能使用平台自己的 API。
- [bluetooth_low_energy: ^5.0.6](https://pub.dev/packages/bluetooth_low_energy) 一个 Flutter 插件，用于控制低功耗蓝牙。
- [flutter_blue: ^0.8.0](https://pub.dev/packages/flutter_blue) FlutterBlue 是 Flutter 的蓝牙插件，Flutter 是一个新的应用 SDK，可帮助开发者构建现代多平台应用。
- [flutter_blue_plus: ^1.31.15](https://pub.dev/packages/flutter_blue_plus) FlutterBluePlus 是 Flutter 的蓝牙低功耗插件。
- [media_kit: ^1.1.10+1](https://pub.dev/packages/media_kit) Flutter & Dart 的跨平台视频播放器和音频播放器。
- [shared_preferences: ^2.2.2](https://pub.dev/packages/shared_preferences) 为简单数据包装特定于平台的持久性存储（iOS 和 macOS 上的 NSUserDefaults、Android 上的 SharedPreferences 等）。数据可能会异步持久化到磁盘，并且不能保证返回后写入会持久化到磁盘，因此此插件不得用于存储关键数据。
- [file_preview: ^1.2.0](https://pub.dev/packages/file_preview) 使用file_preview可以像在使用Flutter weidget一样在andorid、ios页面中预览doc、docx、rtf、ppt、pptx、xls、xlsx、xlsm、csv、pdf、txt、epub、chm等文件。
- [flutter_native_splash: ^2.4.0](https://pub.dev/packages/flutter_native_splash) 一个 Flutter 插件，用于自动生成 Android 和 iOS 的启动屏幕。
- [home_widget: ^0.6.0](https://pub.dev/packages/home_widget)HomeWidget 是一个插件，可以更轻松地在 Android 和 iOS 上创建主屏幕小部件。 HomeWidget 不允许使用 Flutter 本身编写 Widget。它仍然需要使用本机代码编写小部件。然而，它提供了一个统一的接口来发送数据、检索数据和更新 Widgets
- [receive_sharing_intent: ^1.8.0](https://pub.dev/packages/receive_sharing_intent) 一个 Flutter 插件，使 Flutter 应用程序能够从其他应用程序接收共享照片、视频、文本、URL 或任何其他文件类型。
- [receive_sharing_intent_plus: ^1.0.1](https://pub.dev/packages/receive_sharing_intent_plus) Flutter 插件，可在您的应用程序中使用文本、照片和 URL 解锁无缝内容共享。
- [audioplayers: ^6.1.0](https://pub.dev/packages/audioplayers) 一个可同时播放多个音频文件的 Flutter 插件，适用于 Android、iOS、Linux、macOS、Windows 和 Web。

## pretty_diff_text: ^2.1.0 

https://pub.dev/packages/pretty_diff_text

PrettyDiffText 是 RichText 的一个封装函数，它以可视化的方式展示两个文本之间的差异。

默认情况下，它使用 Google 的 diff-match-patch 库，该库实现了 Myer 的 diff 算法 。它通常被认为是最好的通用 diff 工具。

- 🔥 纯 Dart 语言 ：完全用 Dart 语言编写。
- ⭐ 跨平台 ：可在 Android、iOS、macOS、Windows、Linux 和 Web 上运行。
- 💥 高度可定制 ：几乎所有内容都可以定制：
  - AddedText、DeletedText、EqualText 的文本样式。
  - 差异清理类型：语义、效率、无。
  - 差异算法调优：DiffTimeout、EditCost。
  - 自带差异：使用你自己的算法计算差异。
  - Flutter RichText 的所有自定义功能。

- [diff_match_patch: ^0.4.1](https://pub.dev/packages/diff_match_patch)

## diffutil_dart: ^4.0.1

https://pub.dev/packages/diffutil_dart

计算两个列表之间的差异。

该代码深受 Android 的 DiffUtil 类启发，并被移植到 Dart 平台。

内部使用迈尔斯差分算法。关于该算法的内部工作原理，我推荐阅读以下系列文章： https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/