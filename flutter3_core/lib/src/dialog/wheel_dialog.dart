part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// @return pop 返回选中的索引
class WheelDialog extends StatefulWidget with DialogMixin {
  /// title
  final String? title;
  final Widget? titleWidget;

  /// content
  final dynamic initValue;
  final List? values;
  final List<Widget>? valuesWidget;
  final TransformDataWidgetBuilder? transformValueWidget;

  /// wheel
  final bool enableWheelSelectedIndexColor;

  @override
  TranslationType get translationType => TranslationType.translation;

  const WheelDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.transformValueWidget,
    this.enableWheelSelectedIndexColor = true,
  });

  @override
  State<WheelDialog> createState() => _WheelDialogState();
}

class _WheelDialogState extends State<WheelDialog>
    with DialogMixin, TileMixin, ValueChangeMixin<WheelDialog, int> {
  final _wheelItemExtent = kMinItemInteractiveHeight;
  final _wheelHeight = 200.0;

  @override
  int getInitialValueMixin() {
    int index = widget.values?.indexOf(widget.initValue) ?? 0;
    index = max(index, 0);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    WidgetList? children = buildChildrenFromValues(
      context,
      values: widget.values ??
          (widget.valuesWidget == null ? [widget.initValue] : null),
      valuesWidget: widget.valuesWidget,
      transformValueWidget: widget.transformValueWidget,
    );

    return buildBottomChildrenDialog(
        context,
        [
          CoreDialogTitle(
            title: widget.title,
            titleWidget: widget.titleWidget,
            enableTrailing: currentValueMixin != initialValueMixin,
            onPop: () {
              return currentValueMixin;
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                  decoration: fillDecoration(
                color: Colors.black12,
                borderRadius: 0,
              )).wh(double.infinity, _wheelItemExtent),
              Wheel(
                looping: false,
                size: _wheelHeight,
                itemExtent: _wheelItemExtent,
                initialIndex: currentValueMixin,
                enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
                onIndexChanged: (index) {
                  currentValueMixin = index;
                  updateState();
                },
                children: [...?children, if (children == null) empty],
              ).wh(double.infinity, _wheelHeight),
            ],
          ),
          /*ListWheelScrollView(
            itemExtent: _itemExtent,
            children: [
              "1".text(),
              "1".text(),
              "1".text(),
              "1".text(),
              "1".text(),
              "1".text(),
            ],
          ).size(width: double.infinity, height: 200)*/
        ],
        clipTopRadius: kDefaultBorderRadiusXX);
  }
}

const sDateWheelType = [
  "年",
  "月",
  "日",
  null,
  null,
  null,
];

const sTimeWheelType = [
  null,
  null,
  null,
  "时",
  "分",
  "秒",
];

/// 日期选择对话框
/// @return [DateTime]
class WheelDateTimeDialog extends StatefulWidget with DialogMixin {
  /// title
  final String? title;
  final Widget? titleWidget;

  /// dateTime
  final DateTime initDateTime;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;

  /// 显示的日期类型, 对应的位置不为空时, 则显示
  final List dateTimeType;

  /// wheel
  final bool enableWheelSelectedIndexColor;

  @override
  TranslationType get translationType => TranslationType.translation;

  const WheelDateTimeDialog({
    super.key,
    //title
    this.title,
    this.titleWidget,
    //dateTime
    required this.initDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.dateTimeType = sDateWheelType,
    //wheel
    this.enableWheelSelectedIndexColor = true,
  });

  @override
  State<WheelDateTimeDialog> createState() => _WheelDateTimeDialogState();
}

class _WheelDateTimeDialogState extends State<WheelDateTimeDialog>
    with ValueChangeMixin<WheelDateTimeDialog, DateTime> {
  final _wheelItemExtent = kMinItemInteractiveHeight;
  final _wheelHeight = 200.0;

  final UpdateValueNotifier _titleUpdateNotifier = createUpdateSignal();
  final UpdateValueNotifier _monthUpdateNotifier = createUpdateSignal();
  final UpdateValueNotifier _dayUpdateNotifier = createUpdateSignal();
  final UpdateValueNotifier _hourUpdateNotifier = createUpdateSignal();
  final UpdateValueNotifier _minuteUpdateNotifier = createUpdateSignal();
  final UpdateValueNotifier _secondUpdateNotifier = createUpdateSignal();

  @override
  DateTime getInitialValueMixin() => widget.initDateTime;

  @override
  Widget build(BuildContext context) {
    return widget.buildBottomChildrenDialog(
        context,
        [
          rebuild(
            _titleUpdateNotifier,
            (_, __) => CoreDialogTitle(
              title: widget.title,
              titleWidget: widget.titleWidget,
              enableTrailing: currentValueMixin != initialValueMixin,
              onPop: () {
                return currentValueMixin;
              },
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                  decoration: fillDecoration(
                color: Colors.black12,
                borderRadius: 0,
              )).wh(double.infinity, _wheelItemExtent),
              [
                if (widget.dateTimeType.getOrNull(0) != null)
                  buildYearWheel(context).expanded(),
                if (widget.dateTimeType.getOrNull(1) != null)
                  rebuild(_monthUpdateNotifier,
                      (_, __) => buildMonthWheel(context).expanded()),
                if (widget.dateTimeType.getOrNull(2) != null)
                  rebuild(_dayUpdateNotifier,
                      (_, __) => buildDayWheel(context).expanded()),
                if (widget.dateTimeType.getOrNull(3) != null)
                  rebuild(_hourUpdateNotifier,
                      (_, __) => buildHourWheel(context).expanded()),
                if (widget.dateTimeType.getOrNull(4) != null)
                  rebuild(_minuteUpdateNotifier,
                      (_, __) => buildMinuteWheel(context).expanded()),
                if (widget.dateTimeType.getOrNull(5) != null)
                  rebuild(_secondUpdateNotifier,
                      (_, __) => buildSecondWheel(context).expanded()),
              ].row(mainAxisSize: MainAxisSize.max)!,
            ],
          ),
        ],
        clipTopRadius: kDefaultBorderRadiusXX);
  }

  //--year

  int get minYear => widget.minDateTime?.year ?? 1970;

  int get maxYear => widget.maxDateTime?.year ?? 2100;

  int get currentYear => currentValueMixin.year;

  /// 构建年份选择
  Widget buildYearWheel(BuildContext context) {
    final yearList = List.generate(maxYear - minYear + 1, (index) {
      return minYear + index;
    });
    return Wheel(
      looping: false,
      size: _wheelHeight,
      itemExtent: _wheelItemExtent,
      initialIndex: yearList.indexOf(currentYear),
      enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
      onIndexChanged: (index) {
        currentValueMixin = currentValueMixin.copyWith(year: yearList[index]);
        _titleUpdateNotifier.notify();
        _monthUpdateNotifier.notify();
        _dayUpdateNotifier.notify();
        //currentValueMixin = index;
        //updateState();
      },
      children: [
        for (final year in yearList)
          widgetOf(
            context,
            year,
            tryTextWidget: true,
            textAlign: TextAlign.center,
          )!
              .center(),
      ],
    ).wh(double.infinity, _wheelHeight);
  }

  //--month

  int get minMonth {
    if (widget.minDateTime == null) {
      return 1;
    } else if (currentYear <= widget.minDateTime!.year) {
      return widget.minDateTime!.month;
    } else {
      return 1;
    }
  }

  int get maxMonth {
    if (widget.maxDateTime == null) {
      return 12;
    } else if (currentYear >= widget.maxDateTime!.year) {
      return widget.maxDateTime!.month;
    } else {
      return 12;
    }
  }

  int get currentMonth {
    //currentValueMixin.copyWith(year: currentYear)
    return currentValueMixin.month;
  }

  /// 构建月份选择
  Widget buildMonthWheel(BuildContext context) {
    final monthList = List.generate(maxMonth - minMonth + 1, (index) {
      return minMonth + index;
    });
    return Wheel(
      key: Key("$currentYear}"),
      looping: false,
      size: _wheelHeight,
      itemExtent: _wheelItemExtent,
      initialIndex: monthList.indexOfOrNull(currentMonth) ?? 0,
      enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
      onIndexChanged: (index) {
        currentValueMixin = currentValueMixin.copyWith(
          month: monthList[index],
          day: 1, //重置天数, 否则在3月31日切换到2月时, 会切到3月2日的情况
        );
        _titleUpdateNotifier.notify();
        _dayUpdateNotifier.notify();
        //currentValueMixin = index;
        //updateState();
      },
      children: [
        for (final month in monthList)
          widgetOf(
            context,
            month,
            tryTextWidget: true,
            textAlign: TextAlign.center,
          )!
              .center(),
      ],
    ).wh(double.infinity, _wheelHeight);
  }

  //--day

  int get minDay {
    if (widget.minDateTime == null) {
      return 1;
    } else if (currentValueMixin.isBefore(widget.minDateTime!)) {
      return widget.minDateTime!.day;
    } else {
      return 1;
    }
  }

  int get maxDay {
    if (widget.maxDateTime == null) {
      return currentValueMixin.daysInMonth;
    } else if (currentYear >= maxYear && currentMonth >= maxMonth) {
      return widget.maxDateTime!.day;
    } else {
      return currentValueMixin.daysInMonth;
    }
  }

  int get currentDay {
    //currentValueMixin.copyWith(year: currentYear)
    return currentValueMixin.day;
  }

  /// 构建天选择
  Widget buildDayWheel(BuildContext context) {
    final dayList = List.generate(maxDay - minDay + 1, (index) {
      return minDay + index;
    });
    return Wheel(
      key: Key("${currentYear}_$currentMonth"),
      looping: false,
      size: _wheelHeight,
      itemExtent: _wheelItemExtent,
      initialIndex: dayList.indexOfOrNull(currentDay) ?? 0,
      enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
      onIndexChanged: (index) {
        currentValueMixin = currentValueMixin.copyWith(day: dayList[index]);
        _titleUpdateNotifier.notify();
        //currentValueMixin = index;
        //updateState();
      },
      children: [
        for (final day in dayList)
          widgetOf(
            context,
            day,
            tryTextWidget: true,
            textAlign: TextAlign.center,
          )!
              .center(),
      ],
    ).wh(double.infinity, _wheelHeight);
  }

  //--hour

  int get minHour {
    if (widget.minDateTime == null) {
      return 00;
    } else if (currentValueMixin.isBefore(widget.minDateTime!)) {
      return widget.minDateTime!.hour;
    } else {
      return 00;
    }
  }

  int get maxHour {
    if (widget.maxDateTime == null) {
      return 23;
    } else if (currentYear >= maxYear &&
        currentMonth >= maxMonth &&
        currentDay >= maxDay) {
      return widget.maxDateTime!.hour;
    } else {
      return currentValueMixin.hour;
    }
  }

  int get currentHour {
    //currentValueMixin.copyWith(year: currentYear)
    return currentValueMixin.hour;
  }

  /// 构建小时选择
  Widget buildHourWheel(BuildContext context) {
    final hourList = List.generate(maxHour - minHour + 1, (index) {
      return minHour + index;
    });
    return Wheel(
      key: Key("${currentYear}_${currentMonth}_$currentDay"),
      looping: false,
      size: _wheelHeight,
      itemExtent: _wheelItemExtent,
      initialIndex: hourList.indexOfOrNull(currentHour) ?? 0,
      enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
      onIndexChanged: (index) {
        currentValueMixin = currentValueMixin.copyWith(hour: hourList[index]);
        _titleUpdateNotifier.notify();
        //currentValueMixin = index;
        //updateState();
      },
      children: [
        for (final hour in hourList)
          widgetOf(
            context,
            hour,
            tryTextWidget: true,
            textAlign: TextAlign.center,
          )!
              .center(),
      ],
    ).wh(double.infinity, _wheelHeight);
  }

  //--minute

  int get minMinute {
    if (widget.minDateTime == null) {
      return 00;
    } else if (currentValueMixin.isBefore(widget.minDateTime!)) {
      return widget.minDateTime!.minute;
    } else {
      return 59;
    }
  }

  int get maxMinute {
    if (widget.maxDateTime == null) {
      return 59;
    } else if (currentYear >= maxYear &&
        currentMonth >= maxMonth &&
        currentDay >= maxDay &&
        currentHour >= maxHour) {
      return widget.maxDateTime!.minute;
    } else {
      return currentValueMixin.minute;
    }
  }

  int get currentMinute {
    //currentValueMixin.copyWith(year: currentYear)
    return currentValueMixin.minute;
  }

  /// 构建分选择
  Widget buildMinuteWheel(BuildContext context) {
    final minuteList = List.generate(maxMinute - minMinute + 1, (index) {
      return minMinute + index;
    });
    return Wheel(
      key: Key("${currentYear}_${currentMonth}_${currentDay}_$currentHour"),
      looping: false,
      size: _wheelHeight,
      itemExtent: _wheelItemExtent,
      initialIndex: minuteList.indexOfOrNull(currentMinute) ?? 0,
      enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
      onIndexChanged: (index) {
        currentValueMixin =
            currentValueMixin.copyWith(minute: minuteList[index]);
        _titleUpdateNotifier.notify();
        //currentValueMixin = index;
        //updateState();
      },
      children: [
        for (final minute in minuteList)
          widgetOf(
            context,
            minute,
            tryTextWidget: true,
            textAlign: TextAlign.center,
          )!
              .center(),
      ],
    ).wh(double.infinity, _wheelHeight);
  }

  //--second

  int get minSecond {
    if (widget.minDateTime == null) {
      return 00;
    } else if (currentValueMixin.isBefore(widget.minDateTime!)) {
      return widget.minDateTime!.second;
    } else {
      return 59;
    }
  }

  int get maxSecond {
    if (widget.maxDateTime == null) {
      return 59;
    } else if (currentYear >= maxYear &&
        currentMonth >= maxMonth &&
        currentDay >= maxDay &&
        currentHour >= maxHour &&
        currentMinute >= maxMinute) {
      return widget.maxDateTime!.second;
    } else {
      return currentValueMixin.second;
    }
  }

  int get currentSecond {
    //currentValueMixin.copyWith(year: currentYear)
    return currentValueMixin.second;
  }

  /// 构建秒选择
  Widget buildSecondWheel(BuildContext context) {
    final secondList = List.generate(maxSecond - minSecond + 1, (index) {
      return minSecond + index;
    });
    return Wheel(
      key: Key(
          "${currentYear}_${currentMonth}_${currentDay}_${currentHour}_$currentMinute"),
      looping: false,
      size: _wheelHeight,
      itemExtent: _wheelItemExtent,
      initialIndex: secondList.indexOfOrNull(currentSecond) ?? 0,
      enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
      onIndexChanged: (index) {
        currentValueMixin =
            currentValueMixin.copyWith(second: secondList[index]);
        _titleUpdateNotifier.notify();
        //currentValueMixin = index;
        //updateState();
      },
      children: [
        for (final second in secondList)
          widgetOf(
            context,
            second,
            tryTextWidget: true,
            textAlign: TextAlign.center,
          )!
              .center(),
      ],
    ).wh(double.infinity, _wheelHeight);
  }
}
