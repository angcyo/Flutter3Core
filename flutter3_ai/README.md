
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

# A2UI

https://a2ui.org/

A2UI 使 AI 代理能够生成丰富的交互式用户界面，这些界面可以在 Web、移动设备和桌面设备上原生渲染，而无需执行任意代码。