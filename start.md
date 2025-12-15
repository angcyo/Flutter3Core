# 修改应用程序图标

## 使用`flutter_launcher_icons`工具

https://pub.dev/packages/flutter_launcher_icons

**添加工具:**

```yaml
dev_dependencies:
  # https://pub.dev/packages/flutter_launcher_icons
  flutter_launcher_icons: "^0.14.3"
```

**执行程序:**

```shell
dart run flutter_launcher_icons -f Flutter3Core/flutter_launcher_icons.yaml
flutter clean # 清除之后生效
```

# 修改产品名称

## macOS

修改文件:`macos/Runner/Configs/AppInfo.xcconfig`

```
PRODUCT_NAME = xxx xxx
PRODUCT_BUNDLE_IDENTIFIER = xxx.xxx
PRODUCT_COPYRIGHT = Copyright © 2025 xxx.xxx. All rights reserved.
```

上述修改同时会影响`macOS`上程序标题, `菜单bar`, 关于界面的名称.

## windows

修改文件:`windows/CMakeLists.txt`

```cmake
set(BINARY_NAME "xxx") #名称不能包含空格
```

修改窗口标题名称:`windows/runner/main.cpp`

```c++
if (!window.Create(L"xxx xxx", origin, size)) {
  return EXIT_FAILURE;
}
```

修改产物描述:`windows/runner/Runner.rc`

```
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904e4"
        BEGIN
            VALUE "CompanyName", "xxx.xxx" "\0"
            VALUE "FileDescription", "xxx" "\0"
            VALUE "FileVersion", VERSION_AS_STRING "\0"
            VALUE "InternalName", "xxx" "\0"
            VALUE "LegalCopyright", "Copyright (C) 2025 xxx.xxx. All rights reserved." "\0"
            VALUE "OriginalFilename", "xxx.exe" "\0"
            VALUE "ProductName", "xxx" "\0"
            VALUE "ProductVersion", VERSION_AS_STRING "\0"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1252
    END
END
```