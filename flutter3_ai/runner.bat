@echo off
rem 设置当前控制台为UTF-8编码
chcp 65001 >> nul

dart run build_runner build --delete-conflicting-outputs
