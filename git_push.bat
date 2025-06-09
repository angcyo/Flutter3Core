@echo off
rem 设置当前控制台为UTF-8编码
chcp 65001 >> nul

git remote -v

git add .
git commit -a -m "* fix base"
git push origin
