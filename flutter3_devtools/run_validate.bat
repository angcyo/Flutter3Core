@echo off
rem 设置当前控制台为UTF-8编码
chcp 65001 >> nul

:: https://docs.flutter.dev/tools/devtools/extensions
dart run devtools_extensions validate --package=.