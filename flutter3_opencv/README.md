A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

# OpenCV – 4.11.0 `2025-02-18`

https://opencv.org/releases/

# dartcv4: ^1.1.4

https://pub.dev/packages/dartcv4
https://github.com/rainyl/dartcv

- 1.1.0
    - update to OpenCV 4.11.0

## 下载对应的链接库

https://github.com/rainyl/dartcv/releases

# 使用记录

## symbol not found

```shell
Unhandled exception:
Invalid argument(s): Failed to lookup symbol 'cv_Mat_create': dlsym(RTLD_DEFAULT, cv_Mat_create): symbol not found
#0      DynamicLibrary.lookup (dart:ffi-patch/ffi_dynamic_library_patch.dart:33:70)
#1      CvNativeCore._cv_Mat_createPtr (package:dartcv4/src/g/core.g.dart:292:84)
#2      CvNativeCore._cv_Mat_createPtr (package:dartcv4/src/g/core.g.dart)
#3      CvNativeCore._cv_Mat_create (package:dartcv4/src/g/core.g.dart:294:7)
#4      CvNativeCore._cv_Mat_create (package:dartcv4/src/g/core.g.dart)
#5      CvNativeCore.cv_Mat_create (package:dartcv4/src/g/core.g.dart:286:12)
#6      new Mat.empty.<anonymous closure> (package:dartcv4/src/core/mat.dart:135:23)
#7      cvRun (package:dartcv4/src/core/base.dart:83:76)
```

在 `Run/Debug Configurations` 中添加环境变量 

### MacOS

```
`DYLD_LIBRARY_PATH` -> `~/xxx/dart_study/.dartcv/lib`

`/Users/angcyo/project/flutter/dart_study/.dartcv/lib`
```

直接放在: `~/.dartcv` 这个目录会没有权限.

### Windows

打开官网 https://opencv.org/releases/ 下载 `Windows` `OpenCV – 4.12.0` 

- 配置环境变量 `DARTCV_CACHE_DIR` `opencv sdk`缓存自动下载的路径
- 配置环境变量 `DARTCV_DISABLE_DOWNLOAD_OPENCV` 为 `ON` 禁用下载缓存, 禁用后使用`OpenCV_DIR`指定手动下载的路径
- 配置环境变量 `OpenCV_DIR` 为包含 `OpenCVConfig.cmake`文件所在的目录. `E:\Downloads\libopencv-windows-x64\x64\vc17\staticlib`

# opencv_dart: ^1.4.1

https://pub.dev/packages/opencv_dart
https://github.com/rainyl/opencv_dart

# opencv_core: ^1.4.1

https://pub.dev/packages/opencv_core
https://github.com/rainyl/opencv_dart/tree/main/packages/opencv_core