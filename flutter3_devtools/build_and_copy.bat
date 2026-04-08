@echo off
rem 设置当前控制台为UTF-8编码
chcp 65001 >> nul

dart run devtools_extensions build_and_copy --source=. --dest=./extension/devtools