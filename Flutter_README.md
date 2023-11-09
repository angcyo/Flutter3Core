# 2023-11-9

直接打包`apk`体积大约`17MB`

- `lib\x86_64\libflutter.so` 4.7MB
- `lib\arm64-v8a\libflutter.so` 4.6MB
- `lib\armeabi-v7a\libflutter.so` 3.9MB
- `lib\x86_64\libapp.so` 965.6KB
- `lib\arm64-v8a\libapp.so` 958.8KB
- `lib\armeabi-v7a\libapp.so` 1.1MB

## `sizedByParent`

`sizedByParent`为`true`时表示：当前组件的大小只取决于父组件传递的约束，而不会依赖后代组件的大小。

https://book.flutterchina.club/chapter14/layout.html#_14-4-5-sizedbyparent

## `parentUsesSize`

`parentUseSize`为`false`时，子组件的布局边界会是它自身，子组件布局发生变化后不会影响当前组件

