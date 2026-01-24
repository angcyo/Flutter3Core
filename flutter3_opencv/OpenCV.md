# OpenCV

https://docs.opencv.org/4.x/index.html

- [OpenCV Python Tutorials](https://opencv-python-tutorials.readthedocs.io/zh/latest/)
- [OpenCV 教程](https://www.runoob.com/opencv/opencv-tutorial.html)

- [flutter_opencv_demo](https://github.com/angcyo/flutter_opencv_demo)

核心模块 (Main Modules)
- `core`: 核心基础库，定义了所有基本的数据结构（如 Mat）和运算。
- `imgproc`: 图像处理模块（平滑、形态学、直方图、变换等）。
- `imgcodecs`: 图像读写。
- `videoio`: 视频读写。
- `highgui`: 图形界面与交互（窗口、滑动条、鼠标事件）。
- `video`: 视频分析（光流、背景分割、运动跟踪）。
- `calib3d`: 摄像机标定与 3D 重建。
- `features2d`: 特征提取与匹配。
- `objdetect`: 物体检测（Haar 级联、HOG、二维码检测）。
- `dnn`: 深度学习推理引擎。
- `ml`: 机器学习算法库（SVM、K-Means、决策树等）。
- `photo`: 计算摄影学（去噪、HDR、修复）。
- `stitching`: 图像拼接。
- `gapi`: 高性能图计算。

## dartcv

Dart 语言的 OpenCV 绑定。

`dartcv4` 仅适用于纯 `dart`，对于 Flutter，请使用 `opencv_core` （如果不需要 `videoio` 模块）或 `opencv_dart` （如果需要 `videoio` 模块）。

https://pub.dev/packages/dartcv4
https://github.com/rainyl/dartcv

## opencv_dart

Flutter 的 OpenCV，包含所有模块。如果不需要 `videoio` 和 `highgui` ，请使用 `opencv_core`

https://pub.dev/packages/opencv_dart
https://github.com/rainyl/opencv_dart

## opencv_core

Flutter 的 OpenCV，如果需要 `highgui` 或 `videoio` ，请使用 `opencv_dart`

https://github.com/rainyl/dartcv
https://pub.dev/packages/opencv_core


## awesome-opencv_dart 示例

https://github.com/rainyl/awesome-opencv_dart

## OpenCV 调用onnx模型

https://www.zywvvd.com/notes/study/image-processing/opencv/opencv-onnx/opencv-onnx/

支持模型种类：

- Caffe
- Onnx
- Tensorflow
- Pytorch
- DarkNet
- TFLite
- ModelOptimizer

### onnx 模型可视化

https://github.com/lutzroeder/netron
https://netron.app/