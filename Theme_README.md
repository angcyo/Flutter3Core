# 2023-10-23

一些主题相关的数据收集

## Theme

`class Theme extends StatelessWidget`, `ThemeData`是最终数据结构.

```
/flutter/packages/flutter/lib/src/material/app.dart:914 //在此处创建ThemeData
```

通过`Theme.of(context)`获取`ThemeData`实例.

- ColorScheme

### AppBarTheme

```
/flutter/packages/flutter/lib/src/material/theme_data.dart:1349 //在`Theme`里面
```

### IconThemeData

```
/flutter/packages/flutter/lib/src/material/theme_data.dart:1325 //在`Theme`里面
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


