@echo off
rem 设置当前控制台为UTF-8编码
chcp 65001 >> nul

flutter run -d chrome --dart-define=use_simulated_environment=true