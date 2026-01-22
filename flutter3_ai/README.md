
# ONNX

开放神经网络交换

https://onnx.ai/

## 导出为 ONNX 格式

https://onnx.ai/get-started.html
https://github.com/onnx/tutorials#converting-to-onnx-format

# ONNX Runtime

![](https://runtime.onnx.org.cn/docs/api/python/static/ONNX_Runtime_icon.png)

https://runtime.onnx.org.cn/ - 中文
https://onnxruntime.ai/

https://github.com/microsoft/onnxruntime

## 欢迎使用 ONNX Runtime

ONNX Runtime 是一个跨平台的机器学习模型加速器，具有灵活的接口以集成硬件特定库。ONNX Runtime 可与来自 PyTorch、Tensorflow/Keras、TFLite、scikit-learn 和其他框架的模型配合使用。

https://runtime.onnx.org.cn/docs/ - 中文
https://onnxruntime.ai/docs/

# onnxruntime: ^1.4.1

https://pub.dev/packages/onnxruntime

![](https://github.com/microsoft/onnxruntime/raw/main/docs/images/ONNX_Runtime_logo_dark.png)

Flutter 插件 onnxRuntime 通过 dart:ffi 提供了一个简单、灵活、快速的 Dart API，用于在移动和桌面平台上将 Onnx 模型集成到 Flutter 应用程序中。

平台	  | Android	        | iOS	  | Linux	  | macOS	  | Windows
------|-----------------|-------|---------|---------|-----
兼容性	| API 级别	 21+     | *	    | *	      | *	      |  *
建筑学	| arm32/arm64	    | *	    | *	      | *	      |  *

## 主要特点

- 支持 Android、iOS、Linux、macOS、Windows 和 Web（即将推出）等多平台。
- 可灵活使用任何 `Onnx` 模型。
- 利用多线程加速。
- 与 OnnxRuntime Java 和 C# API 结构类似。
- 推理速度不比使用 Java/Objective-C API 构建的原生 Android/iOS 应用慢。
- 在不同的隔离环境中运行推理，以防止 UI 线程出现卡顿。

# onnxruntime_v2: ^1.23.2+2

https://pub.dev/packages/onnxruntime_v2

这是 `onnxruntime` Flutter 插件的一个分支 ，该插件似乎已停止维护。 此分支增加了对 16KB 内存页大小的支持，并完全支持 GPU 和硬件加速。

# flutter_onnxruntime: ^1.6.1

https://pub.dev/packages/flutter_onnxruntime

ONNX 运行时的原生封装 Flutter 插件

当前支持的 ONNX 运行时版本： 1.22.0

# ort: ^0.0.3

Drt ONNX 运行时 (ort)

https://pub.dev/packages/ort

ort 是一个用于 ONNX Runtime 的开源 Rust 绑定。

https://ort.pyke.io/

# A2UI

https://a2ui.org/

A2UI 使 AI 代理能够生成丰富的交互式用户界面，这些界面可以在 Web、移动设备和桌面设备上原生渲染，而无需执行任意代码。