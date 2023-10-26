# 2023-10-23

一些主题相关的数据收集

## Theme

`AnimatedTheme`中创建了`Theme`;
`WidgetsApp`中创建了`AnimatedTheme`;

- `_MaterialAppState._materialBuilder`
- `_MaterialAppState._themeBuilder`;

`class Theme extends StatelessWidget`, `ThemeData`是最终数据结构.

```
/flutter/packages/flutter/lib/src/material/app.dart:914 //在此处创建`ThemeData`
```

通过`Theme.of(context)`获取`ThemeData`实例.

- ColorScheme

常量声明`/flutter/packages/flutter/lib/src/material/constants.dart:24`

- `const double kToolbarHeight = 56.0;` 顶部导航栏高度
- `const double kBottomNavigationBarHeight = 56.0;` 底部导航栏高度

### AppBarTheme

- `AppBarTheme.backgroundColor` 顶部导航栏背景色
- `AppBarTheme.foregroundColor` 顶部导航栏前景色, 也影响`icon` `title` 的颜色
- `AppBarTheme.elevation` 顶部导航栏阴影高度
- `AppBarTheme.shadowColor` 顶部导航栏阴影颜色
- `AppBarTheme.systemOverlayStyle` 顶部导航栏系统覆盖样式

```
/flutter/packages/flutter/lib/src/material/theme_data.dart:1349 //在`Theme`里面
```

### IconThemeData

```
/flutter/packages/flutter/lib/src/material/theme_data.dart:1325 //在`Theme`里面
```

### ActionIconThemeData

可以用来创建`AppBar`的返回按钮的`Widget`.

- `ActionIconThemeData.backButtonIconBuilder`
- `ActionIconThemeData.closeButtonIconBuilder`
- `ActionIconThemeData.drawerButtonIconBuilder`
- `ActionIconThemeData.endDrawerButtonIconBuilder`

```
/flutter/packages/flutter/lib/src/material/theme_data.dart:1345 //在`Theme`里面
```

### IconButtonThemeData

```
/flutter/packages/flutter/lib/src/material/theme_data.dart:1425 //在`Theme`里面
```

# 子样式

## TextStyle

`const double _kDefaultFontSize = 14.0;`默认的字体大小

```
flutter/packages/flutter/lib/src/painting/text_style.dart:34
```

## DefaultTextStyle

## DefaultSelectionStyle

## Directionality

### TextDirection

## MediaQuery

```
MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first)
```
