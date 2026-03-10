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

ONNX Runtime 是一个跨平台的机器学习模型加速器，具有灵活的接口以集成硬件特定库。ONNX Runtime 可与来自
PyTorch、Tensorflow/Keras、TFLite、scikit-learn 和其他框架的模型配合使用。

https://runtime.onnx.org.cn/docs/ - 中文
https://onnxruntime.ai/docs/

# onnxruntime: ^1.4.1

https://pub.dev/packages/onnxruntime

![](https://github.com/microsoft/onnxruntime/raw/main/docs/images/ONNX_Runtime_logo_dark.png)

Flutter 插件 onnxRuntime 通过 dart:ffi 提供了一个简单、灵活、快速的 Dart API，用于在移动和桌面平台上将
Onnx 模型集成到 Flutter 应用程序中。

 平台	  | Android	     | iOS	 | Linux	 | macOS	 | Windows 
------|--------------|------|--------|--------|---------
 兼容性	 | API 级别	 21+  | *	   | *	     | *	     | *       
 建筑学	 | arm32/arm64	 | *	   | *	     | *	     | *       

## 主要特点

- 支持 Android、iOS、Linux、macOS、Windows 和 Web（即将推出）等多平台。
- 可灵活使用任何 `Onnx` 模型。
- 利用多线程加速。
- 与 OnnxRuntime Java 和 C# API 结构类似。
- 推理速度不比使用 Java/Objective-C API 构建的原生 Android/iOS 应用慢。
- 在不同的隔离环境中运行推理，以防止 UI 线程出现卡顿。

# onnxruntime_v2: ^1.23.2+2

https://pub.dev/packages/onnxruntime_v2

这是 `onnxruntime` Flutter 插件的一个分支 ，该插件似乎已停止维护。 此分支增加了对 16KB 内存页大小的支持，并完全支持
GPU 和硬件加速。

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

# langchain: ^0.8.1

https://pub.dev/packages/langchain

LangChain.dart 是由 Harrison Chase 创建的流行的 LangChain Python 框架的非官方 Dart 移植版。

LangChain 提供了一套用于处理语言模型的即用型组件，以及一个标准接口，可以将这些组件链接在一起，以构建更高级的用例（例如聊天机器人、带
RAG 的问答、代理、摘要、翻译、提取、推荐系统等）。

# openai_dart: ^0.6.2

https://pub.dev/packages/openai_dart

用于 OpenAI API 的非官方 Dart 客户端。

# openai_realtime_dart: ^0.1.0+1

https://pub.dev/packages/openai_realtime_dart

OpenAI Realtime API 的非官方强类型 Dart 客户端，OpenAI Realtime API 是一个有状态、基于事件的 API，通过
WebSocket 进行通信。

# dart_openai: ^6.1.1

https://pub.dev/packages/dart_openai

Dart OpenAI 是一个非官方但功能全面的客户端软件包，它允许开发者轻松地将 OpenAI 的先进 AI 模型集成到他们的
Dart/Flutter 应用程序中。该软件包提供了简单直观的方法来请求 OpenAI 的各种 API，包括 GPT 模型、DALL-E
图像生成、Whisper 音频处理等等。

# flutter_llama: ^1.1.2

https://pub.dev/packages/flutter_llama

用于在 Android、iOS 和 macOS 上使用 llama.cpp 和 GGUF 模型运行 LLM 推理的 Flutter 插件。

# llama_cpp_dart: ^0.2.2

https://pub.dev/packages/llama_cpp_dart

llama.cpp 的高性能 Dart 绑定，可在 Dart 和 Flutter 应用程序中实现高级文本生成功能，并提供灵活的集成选项。

# flutter_gemma: ^0.12.5

https://pub.dev/packages/flutter_gemma

LiteRT 是 Google 的设备端框架，用于在边缘平台上部署高性能 ML 和 GenAI。

https://ai.google.dev/edge/litert?hl=zh-cn

---

# 主流模型格式与引擎对照表

| 模型格式         | 核心引擎                                | 适用场景                      | 特点                                                          |
|--------------|-------------------------------------|---------------------------|-------------------------------------------------------------|
 GGUF         | "llama.cpp,  Ollama , LM Studio"    | CPU 强力推理 / 消费级显卡          | 目前最通用的端侧格式，单文件包含权重与元数据，支持 CPU/GPU 混合负载。                     
 .bin / .task | MediaPipe (Google AI Edge)          | "Android, iOS, Web"       | Google 官方格式，对移动端 GPU (Vulkan/Metal) 适配极好，适合 Flutter/KMP 开发。 
 EXL2         | ExLlamaV2                           | NVIDIA GPU (PC/服务器)       | 比 GPTQ 拥有更精细的位宽（如 3.5bpw），在 NVIDIA 卡上推理速度极快。                
 AWQ / GPTQ   | "vLLM, TensorRT-LLM , AutoAWQ"      | 云端服务器 / 高端 GPU            | 工业级部署标准。AWQ 在保护权重精度方面优于 GPTQ，适合逻辑推理模型。                      
 MLC (.mlc)   | MLC LLM (TVM)                       | 跨平台极致性能 (含 iPhone)        | 通过编译技术将模型转为原生着色器代码，在苹果 M 系列芯片上表现优异。                         
 ONNX         | ONNX Runtime (GenAI)                | "Windows 原生 ,跨平台集成"       | 微软主推，适合在 Windows 应用中通过 DirectML 调用 GPU 资源。                  
 FP4 / FP8    | TensorRT-LLM (最新硬件)                 | NVIDIA Blackwell (B200) 等 | 2025-2026 年兴起的新硬件原生格式，利用最新 Tensor Core 实现极高吞吐。              