part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/04
///
/// 输入框[TextField]的装饰器混入
///
/// - [SingleInputWidget]
mixin InputDecorationMixin<T extends StatefulWidget> on State<T> {
  InputBorderType? get inputBorderTypeMixin {
    try {
      return (widget as dynamic).inputBorderType;
    } catch (e) {
      return null;
    }
  }

  String? get debugLabelMixin {
    try {
      return (widget as dynamic).debugLabel;
    } catch (e) {
      return null;
    }
  }

  bool? get enabledMixin {
    try {
      return (widget as dynamic).enabled;
    } catch (e) {
      return null;
    }
  }

  //--

  Color? get borderColorMixin {
    try {
      return (widget as dynamic).borderColor;
    } catch (e) {
      return null;
    }
  }

  Color? get fillColorMixin {
    try {
      return (widget as dynamic).fillColor;
    } catch (e) {
      return null;
    }
  }

  Color? get disabledFillColorMixin {
    try {
      return (widget as dynamic).disabledFillColor;
    } catch (e) {
      return null;
    }
  }

  Color? get focusBorderColorMixin {
    try {
      return (widget as dynamic).focusBorderColor;
    } catch (e) {
      return null;
    }
  }

  Color? get disableBorderColorMixin {
    try {
      return (widget as dynamic).disableBorderColor;
    } catch (e) {
      return null;
    }
  }

  //--

  double? get borderWidthMixin {
    try {
      return (widget as dynamic).borderWidth;
    } catch (e) {
      return null;
    }
  }

  double? get focusBorderWidthMixin {
    try {
      return (widget as dynamic).focusBorderWidth;
    } catch (e) {
      return null;
    }
  }

  double? get disableBorderWidthMixin {
    try {
      return (widget as dynamic).disableBorderWidth;
    } catch (e) {
      return null;
    }
  }

  double? get borderRadiusMixin {
    try {
      return (widget as dynamic).borderRadius;
    } catch (e) {
      return null;
    }
  }

  double? get underlineBorderRadiusMixin {
    try {
      return (widget as dynamic).underlineBorderRadius;
    } catch (e) {
      return null;
    }
  }

  /// 构建输入框装饰器
  /// 可以使用 [InputDecoration.copyWith]再次修改
  @api
  InputDecoration buildInputDecoration(
    BuildContext context, {
    InputBorderType? inputBorderType,
    //--
    InputBorder? normalBorder,
    InputBorder? focusedBorder,
    InputBorder? disabledBorder,
    //--
    double? gapPadding /*边框距离的间隙*/,
    EdgeInsetsGeometry? contentPadding,
    bool? isDense,
    bool? isCollapsed,
    String? counterText,
    Widget? label,
    String? labelText,
    TextStyle? labelStyle,
    TextStyle? floatingLabelStyle,
    Widget? hint,
    String? hintText,
    TextStyle? hintStyle,
    Widget? helper,
    String? helperText,
    TextStyle? helperStyle,
    Widget? error,
    String? errorText,
    TextStyle? errorStyle,
    //--
    BoxConstraints? prefixIconConstraints,
    BoxConstraints? suffixIconConstraints,
    //--
    bool? hasFocus /*是否具有焦点*/,
  }) {
    //debugger();
    inputBorderType ??= inputBorderTypeMixin ?? InputBorderType.outline;
    final globalTheme = GlobalTheme.of(context);
    final borderWidth = borderWidthMixin ?? 1;
    final borderRadius = borderRadiusMixin ?? kDefaultBorderRadiusX;
    final underlineBorderRadius = underlineBorderRadiusMixin ?? 0;
    final enabled = enabledMixin ?? true;
    gapPadding ??= 0;
    isDense ??= true;
    isCollapsed ??= inputBorderType.isOutline;
    contentPadding ??= inputBorderType.isOutline
        ? kInputPadding
        : kInputPaddingMin;

    /*switch (inputBorderType) {
      InputBorderType.outline || InputBorderType.fillOutline => null,
      InputBorderType.underline => const EdgeInsets.all(12),
      _ => const EdgeInsets.all(4),
    }*/

    //normal正常状态
    final normalBorderSide =
        borderColorMixin == Colors.transparent || borderWidth <= 0
        ? BorderSide.none
        : BorderSide(
            color: borderColorMixin ?? globalTheme.borderColor,
            width: borderWidth,
          );
    normalBorder ??= switch (inputBorderType) {
      InputBorderType.outline ||
      InputBorderType.fillOutline => OutlineInputBorder(
        gapPadding: gapPadding,
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: normalBorderSide,
      ),
      InputBorderType.underline => UnderlineInputBorder(
        borderSide: normalBorderSide,
        borderRadius: BorderRadius.circular(underlineBorderRadius),
      ),
      _ => InputBorder.none,
    };

    //focused聚焦状态
    final focusedBorderSide =
        focusBorderColorMixin == Colors.transparent ||
            (focusBorderWidthMixin ?? borderWidth) <= 0
        ? BorderSide.none
        : BorderSide(
            color: focusBorderColorMixin ?? globalTheme.accentColor,
            width: (focusBorderWidthMixin ?? borderWidth),
          );
    focusedBorder ??= switch (inputBorderType) {
      InputBorderType.outline ||
      InputBorderType.fillOutline => OutlineInputBorder(
        gapPadding: gapPadding,
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: focusedBorderSide,
      ),
      InputBorderType.underline => UnderlineInputBorder(
        borderSide: focusedBorderSide,
        borderRadius: BorderRadius.circular(underlineBorderRadius),
      ),
      _ => InputBorder.none,
    };

    //disabled禁用状态
    final disableBorderSide =
        disableBorderColorMixin == Colors.transparent ||
            (disableBorderWidthMixin ?? borderWidth) <= 0
        ? BorderSide.none
        : BorderSide(
            color: disableBorderColorMixin ?? globalTheme.disableColor,
            width: (disableBorderWidthMixin ?? borderWidth),
          );
    disabledBorder ??= switch (inputBorderType) {
      InputBorderType.outline ||
      InputBorderType.fillOutline => OutlineInputBorder(
        gapPadding: gapPadding,
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: disableBorderSide,
      ),
      InputBorderType.underline => UnderlineInputBorder(
        borderSide: disableBorderSide,
        borderRadius: BorderRadius.circular(underlineBorderRadius),
      ),
      _ => InputBorder.none,
    };

    // InputBorderType.fillOutline
    final fillColor =
        fillColorMixin ??
        (inputBorderType == InputBorderType.fillOutline
            ? globalTheme.itemWhiteSubBgColor
            : null);

    final floatingLabelStyleInner =
        floatingLabelStyle ?? labelStyle ?? globalTheme.textLabelStyle;

    debugger(when: debugLabelMixin != null);
    //debugger(when: hasFocus == true);
    final decoration = InputDecoration(
      filled: fillColor != null || (!enabled && disabledFillColorMixin != null),
      fillColor: enabled
          ? fillColor
          : disabledFillColorMixin ?? fillColor?.disabledColor,
      isDense: isDense,
      isCollapsed: isCollapsed,
      /*isDense: false,
      isCollapsed: false,*/
      counterText: counterText,
      contentPadding: contentPadding,
      //contentPadding: const EdgeInsets.only(top: 60),
      //contentPadding: const EdgeInsets.all(0),
      //contentPadding: EdgeInsets.symmetric(horizontal: globalTheme.xh),
      border: normalBorder,
      //2025-07-02
      enabledBorder: normalBorder,
      focusedBorder: focusedBorder,
      disabledBorder: disabledBorder,
      enabled: enabled,
      //控制label的行为
      label: label,
      labelText: labelText,
      labelStyle: labelStyle ?? globalTheme.textLabelStyle,
      helper: helper,
      helperText: helperText,
      helperStyle: helperStyle ?? globalTheme.textBodyStyle,
      hint: hint,
      hintText: hintText,
      hintStyle: hintStyle ?? globalTheme.textPlaceStyle,
      error: error,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIconConstraints: prefixIconConstraints,
      suffixIconConstraints: suffixIconConstraints,
      //--style
      floatingLabelStyle: hasFocus == true
          ? floatingLabelStyleInner.copyWith(
              color: focusBorderColorMixin ?? globalTheme.accentColor,
            )
          : floatingLabelStyleInner,
    );
    return decoration;
  }
}
