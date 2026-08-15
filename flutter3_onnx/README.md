# ONNX Runtime

https://onnxruntime.ai/

## Get started with ONNX Runtime for Windows

https://onnxruntime.ai/docs/get-started/with-windows.html

## Get started with ONNX Runtime Mobile

https://onnxruntime.ai/docs/get-started/with-mobile.html

# NCHW

```
//[1, 3, 1024, 1024]
//N = Batch
//C = Channel
//H = Height
//W = Width

1       → 一次处理 1 张图片
3       → RGB 三个通道
1024    → 高
1024    → 宽

R R R R | G G G G | B B B B
RRRR GGGG BBBB
```

| Layout | 含义           | 例子                |
| ------ | ------------ | ----------------- |
| HWC    | 高×宽×通道       | `[1024,1024,3]`   |
| CHW    | 通道×高×宽       | `[3,1024,1024]`   |
| NHWC   | Batch×高×宽×通道 | `[1,1024,1024,3]` |
| NCHW   | Batch×通道×高×宽 | `[1,3,1024,1024]` |

## BiRefNet

https://huggingface.co/onnx-community/BiRefNet_lite-ONNX

https://huggingface.co/ZhengPeng7/BiRefNet_lite

```
    BiRefNet
       │
       ▼
[1, 3, 1024, 1024]
│  │    │    │
│  │    │    └─ W
│  │    └────── H
│  └─────────── C
└────────────── N
```

## RMBG-1.4

https://huggingface.co/briaai/RMBG-1.4

https://huggingface.co/mujibanget/rmbg-onnx

# macOS 

https://pub.dev/packages/flutter_onnxruntime#macos

最低需要系统版本`platform :osx, '14.0'`

还需要`use_frameworks! :linkage => :static` 或者 

```
# 禁用 CocoaPods 的静态传递依赖校验
pre_install do |installer|
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
```