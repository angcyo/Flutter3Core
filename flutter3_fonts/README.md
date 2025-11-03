# flutter3_fonts

在`Flutter`中配置默认字体:

## `pubspec.yaml` 中配置字体资产

```yaml
flutter:
  fonts:
    - family: menlo
      fonts:
        - asset: assets/fonts/menlo/Menlo-Regular.ttf
          style: normal
        - asset: assets/fonts/menlo/Menlo-Italic.ttf
          style: italic
        - asset: assets/fonts/menlo/Menlo-Bold.ttf
          style: normal
          weight: 700
        - asset: assets/fonts/menlo/Menlo-BoldItalic.ttf
          style: italic
          weight: 700
```

可以在 https://fonts.google.com/ 下载免费字体:

名称含义与常见权重映射 常见命名与对应的数值 `weight`（Flutter / CSS 使用 100..900）通常映射为：

- Thin → 100
- ExtraLight（或 UltraLight）→ 200
- Light → 300
- Regular（或 Normal）→ 400
- Medium → 500
- SemiBold → 600
- Bold → 700
- ExtraBold（或 Heavy）→ 800
- Black（或 Heavy/Heavy）→ 900

- NotoSansSC-Thin ≈ w100
- NotoSansSC-ExtraLight ≈ w200
- NotoSansSC-Light ≈ w300
- NotoSansSC-Regular ≈ w400
- NotoSansSC-Medium ≈ w500
- NotoSansSC-SemiBold ≈ w600
- NotoSansSC-Bold ≈ w700
- NotoSansSC-ExtraBold ≈ w800
- NotoSansSC-Black ≈ w900

## 在`ThemeData`中使用

```dart
final themeData = ThemeData(
  ...
  fontFamily: "menlo", //指定默认字体
  package: "xxx", //如果字体在子`package`的资产中, 则需要指定包名.
  ...
);
```

## 注意

如果需要使用`DefaultTextStyle`小部件, 则尽量使用`DefaultTextStyle.merge`方法.

```dart
DefaultTextStyle.merge(
  style: const TextStyle(fontWeight: FontWeight.bold),
  child: xxx,
);
```