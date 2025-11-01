# Error loading libdartcv.dylib

```
Error loading libdartcv.dylib, error: Invalid argument(s): Failed to load dynamic library 'libdartcv.dylib': 
dlopen(libdartcv.dylib, 0x0001): tried: 'libdartcv.dylib' (no such file), 
```

https://github.com/rainyl/opencv_dart/issues/390

```
@JILJEKLFI aha, it is expected, since we need 2 different loading methods on macos (for pure dart, load from a dylib, for flutter, load from process), so the package will try to load from a dylib first and will fallback to process if failed, but it is expected for flutter.
啊哈，这是预料之中的，因为我们在 macos 上需要 2 种不同的加载方法（对于纯 dart，从 dylib 加载，对于 flutter，从进程加载），所以包将首先尝试从 dylib 加载，如果失败则回退到进程，但对于 flutter 来说这是预料之中的。

Will change the error to warning in the future.
将来会将错误改为警告。
```

属于正常情况, 无视即可.

# fatal error LNK1120 / error LNK2001

TLDR: upgrade your [visual studio](https://visualstudio.microsoft.com/zh-hans/). 

https://github.com/rainyl/opencv_dart/issues/375

或者更新`MSVC`: https://aka.ms/vs/17/release/vc_redist.x64.exe

https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170