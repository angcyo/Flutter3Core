
# QA

## Windows

```
Launching lib\main.dart on Windows in debug mode...
Building Windows application...
C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Microsoft\VC\v160\Microsoft.CppBuild.targets(382,5): error MSB3491: δ�����ļ���x64\Debug\flutter_inappwebview_windows_DEPENDENCIES_DOWNLOAD\flutter_.556B9A3A.tlog\flutter_inappwebview_windows_DEPENDENCIES_DOWNLOAD.lastbuildstate��д�������С�·��: x64\Debug\flutter_inappwebview_windows_DEPENDENCIES_DOWNLOAD\flutter_.556B9A3A.tlog\flutter_inappwebview_windows_DEPENDENCIES_DOWNLOAD.lastbuildstate ���� OS ���·�����ơ���ȫ�޶����ļ����������� 260 ���ַ��� [E:\projects\flutter\LaserABCTools\apps\LaserABCFactoryTools\build\windows\x64\plugins\flutter_inappwebview_windows\flutter_inappwebview_windows_DEPENDENCIES_DOWNLOAD.vcxproj]
Error: Build process failed.
```

打开注册表 `regedit` 修改:

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
"LongPathsEnabled"=dword:00000001
```

https://github.com/pichillilorenzo/flutter_inappwebview/issues/2329