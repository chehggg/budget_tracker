import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

class CustomKeyboard extends StatefulWidget {
  const CustomKeyboard(
      {super.key,
      required this.controller,
      required this.onDone,
      required this.selectedDate,
      required this.onDateTapped});

  final TextEditingController controller;
  final void Function() onDone;
  final DateTime selectedDate;
  final void Function() onDateTapped;

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool _isCalculating = false;

  List<KeyboardButton> buttons(BuildContext context) => [
        KeyboardButton(type: "num", value: "7"),
        KeyboardButton(type: "num", value: "8"),
        KeyboardButton(type: "num", value: "9"),
        KeyboardButton(type: "date", value: Icons.date_range),
        KeyboardButton(type: "num", value: "4"),
        KeyboardButton(type: "num", value: "5"),
        KeyboardButton(type: "num", value: "6"),
        KeyboardButton(type: "num", value: "+"),
        KeyboardButton(type: "num", value: "1"),
        KeyboardButton(type: "num", value: "2"),
        KeyboardButton(type: "num", value: "3"),
        KeyboardButton(type: "num", value: "-"),
        KeyboardButton(type: "num", value: "."),
        KeyboardButton(type: "num", value: "0"),
        KeyboardButton(type: "delete", value: Icons.backspace_rounded),
        KeyboardButton(
            type: "done",
            value: _isCalculating ? Icons.calculate : Icons.check),
      ];

  Widget customTextButton(String text, BuildContext context) {
    return Text(
      text,
      style: context.customTt.numberFontSmall!,
    );
  }

  Flushbar<dynamic> saveErrorFlushbar(String message) {
    return Flushbar(
      title: "Cannot save current entry",
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      // isDismissible: true,
      duration: Duration(seconds: 4),
      animationDuration: Durations.long1,
      backgroundColor: Colors.orange.shade900,
    );
  }

  void updateText(String newText) {
    widget.controller.value = widget.controller.value
        .copyWith(text: '${widget.controller.text}$newText');
  }

  void deleteText() {
    if (widget.controller.text.isEmpty) return;
    final index = widget.controller.text.length;
    widget.controller.value = widget.controller.value.copyWith(
        text: widget.controller.text.replaceRange(index - 1, null, ""));
  }

  void calculateAmount() async {
    debugPrint("try to calculate");
    try {
      final Parser p = Parser();
      Expression expression = p.parse(widget.controller.text);
      double value = expression.evaluate(EvaluationType.REAL, ContextModel());

      widget.controller.value = widget.controller.value
          .copyWith(text: value.toStringAsFixed(value % 1 == 0 ? 0 : 2));
    } catch (e) {
      // using sign without value throw error, do not allow calculation
      widget.controller.value =
          widget.controller.value.copyWith(text: widget.controller.text);
      saveErrorFlushbar("Invalid operation, make sure the formula is correct")
          .show(context);
    }
  }

  void checkCalculating() {
    // regex check for a add or subtraction of two numbers
    if (widget.controller.text.contains(RegExp(r'\d+[\+\-]+\d?'))) {
      setState(() {
        _isCalculating = true;
      });
    } else {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.addListener(checkCalculating);
    return Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        // height: 230,
        width: context.mq.size.width,
        child: GridView(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 50,
            // childAspectRatio: 1.5
          ),
          children: buttons(context).map((KeyboardButton button) {
            final Widget child;
            switch (button.type) {
              case 'num':
                child = customTextButton(button.value as String, context);
              case 'date':
                child = Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(button.value, color: context.cs.onPrimary),
                    Text(
                      widget.selectedDate.displayFormat(),
                      style: context.customTt.numberFontSmall!.copyWith(color: context.cs.onPrimary),
                    ),
                  ],
                );
              default:
                child = Icon(button.value as IconData);
            }
            return Container(
              height: 20,
              decoration: BoxDecoration(
                  color: button.type == "date"
                      ? context.cs.primary
                      : button.type == "done"
                          ? context.cs.secondary
                          : context.cs.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    switch (button.type) {
                      case 'num':
                        updateText(button.value);
                      case 'date':
                        widget.onDateTapped();
                      case 'delete':
                        deleteText();
                      case 'done':
                        // if + and - is present, button switch to calculation mode
                        if (_isCalculating) {
                          calculateAmount();
                        } else {
                          // validate amount here
                          // cannot be empty / 0 / negative
                          if (widget.controller.text == "0" ||
                              widget.controller.text == "") {
                            saveErrorFlushbar(
                                    "Amount cannot be 0. Please input a number larger than 0!")
                                .show(context);
                          } else if ((widget.controller.text)
                              .contains(RegExp(r'^\-\d+$'))) {
                            // one negative number
                            saveErrorFlushbar(
                                    "Amount cannot be negative. Please input a number larger than 0")
                                .show(context);
                          } else {
                            widget.onDone();
                          }
                        }
                    }
                    HapticFeedback.lightImpact();
                  },
                  child: Center(child: child),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Future<DateTime?> datePickerDialog(BuildContext context) {
    final now = DateTime.now();
    return showDatePicker(
      initialDate: now,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(now.year - 50, 1, 1),
      lastDate: DateTime(now.year + 50, 12, 31),
      context: context,
      // builder: (context, child) {
      // },
    );
  }
}

class KeyboardButton {
  const KeyboardButton({required this.type, required this.value});

  final String type;
  final dynamic value;
}

class HideableText extends StatelessWidget {
  const HideableText(this.data,
      {super.key,
      this.overflowText,
      this.isCurrency,
      required this.textStyle,
      this.maxLine = 1});

  final String data;
  final String? overflowText;
  final bool? isCurrency;
  final TextStyle textStyle;
  final int maxLine;

  bool hasTextOverflow(String text, TextStyle style, TextScaler scaler,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 1}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
      textScaler: scaler,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final hide = context.read<ThemeModel>().isListBlurred;
    final currency = context.read<AppModel>().currencySymbol;
    return LayoutBuilder(builder: (context, constraints) {
      if (!hasTextOverflow(data, textStyle, MediaQuery.textScalerOf(context),
          maxWidth: constraints.maxWidth, maxLines: maxLine)) {
        return Text(
          hide ? '${isCurrency == true ? '$currency ' : ''}***' : data,
          style: textStyle,
        );
      } else if (overflowText == null) {
        return Text(
          hide ? '${isCurrency == true ? '$currency ' : ''}***' : data,
          style: textStyle,
        );
      } else {
        return Text(
          hide ? "***" : overflowText!,
          style: textStyle,
        );
      }
    });
  }
}

// Month select dialog for changing to another month quickly
// using the date selector top bar
class MonthSelectorDialog extends StatefulWidget {
  const MonthSelectorDialog({super.key});

  @override
  State<MonthSelectorDialog> createState() => _MonthSelectorDialogState();
}

class _MonthSelectorDialogState extends State<MonthSelectorDialog> {
  int _selectedYear = 2000;
  int _selectedMonth = 1;

  @override
  void initState() {
    super.initState();
    _selectedYear = context.read<AppModel>().selectedYearMonth.year;
    _selectedMonth = context.read<AppModel>().selectedYearMonth.month;
  }

  DateTime getDateTimeFromSelection() {
    return DateTime(_selectedYear, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    const firstMonthRow = [1, 2, 3, 4];
    const secondMonthRow = [5, 6, 7, 8];
    const thirdMonthRow = [9, 10, 11, 12];
    final List<int> availableYears = List.generate(100, (index) {
      return (DateTime.now().year - 50 + index);
    });
    return AlertDialog(
      title: Text(
          "Selected: ${DateFormat('MMM yyyy').format(getDateTimeFromSelection())}"),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.7,
        child: LayoutBuilder(builder: (context, constraints) {
          var textTheme2 = Theme.of(context).textTheme;
          return Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownMenu(
                menuHeight: 200,
                menuStyle:
                    MenuStyle(visualDensity: VisualDensity(vertical: -2)),
                width: constraints.maxWidth,
                textStyle: textTheme2.displayMedium,
                inputDecorationTheme:
                    InputDecorationTheme(border: UnderlineInputBorder()),
                dropdownMenuEntries: availableYears.map((year) {
                  return DropdownMenuEntry(
                      value: year,
                      label: year.toString(),
                      style: ElevatedButton.styleFrom(
                          textStyle: textTheme2.bodyLarge));
                }).toList(),
                initialSelection: _selectedYear,
                onSelected: (value) => setState(() {
                  _selectedYear = value ?? _selectedYear;
                }),
              ),
              monthRow(firstMonthRow),
              monthRow(secondMonthRow),
              monthRow(thirdMonthRow),
            ],
          );
        }),
      ),
      actions: [
        TextButton(
            onPressed: () {
              context.read<AppModel>().changeYearMonth(
                    false,
                    specificYearMonth: getDateTimeFromSelection(),
                  );
              Navigator.pop(context);
            },
            child: Text("Save"))
      ],
    );
  }

  Row monthRow(List<int> list) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: list.map((monthInt) => monthButton(monthInt)).toList());
  }

  Widget monthButton(int monthInt) {
    var appState = context.read<AppModel>();
    final monthName = DateFormat('MMM').format(DateTime(2000, monthInt));
    final yearMonthMapping =
        DateFormat('yyyy-MM').format(DateTime(_selectedYear, monthInt));
    final appColor = Theme.of(context).colorScheme;
    final appTextTheme = Theme.of(context).textTheme;
    final yearMonthData = appState.yearMonthOverview;

    Text subText(dynamic value) {
      String text;
      Color color = Theme.of(context).colorScheme.onSurface;
      if (value is String) {
        text = value;
      } else {
        text = (value as double).customCurrencyFormat(appState.currencySymbol,
            usePositiveSign: true, useSuffix: true);
        if (value >= 0) {
          color = Colors.greenAccent;
        } else {
          color = Colors.red;
        }
      }
      return Text(
        text,
        style: appTextTheme.bodyLarge!.copyWith(fontSize: 11, color: color),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100),
      child: TextButton(
          onPressed: () {
            setState(() => _selectedMonth = monthInt);
          },
          style: TextButton.styleFrom(
              minimumSize: Size(80, 50),
              backgroundColor: _selectedMonth == monthInt
                  ? appColor.primary.withAlpha(40)
                  : appColor.surfaceContainer,
              foregroundColor: _selectedMonth == monthInt
                  ? appColor.onPrimary
                  : appColor.onSurface),
          child: Column(
            children: [
              Text(
                monthName,
                style: appTextTheme.bodyMedium!.copyWith(fontSize: 20),
              ),
              subText((yearMonthData[yearMonthMapping]?.balance ?? "--"))
            ],
          )),
    );
  }
}

class ExpenseCalendarView extends StatelessWidget {
  const ExpenseCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> weekdayName = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];
    final List<int> weekdayList = context
        .select((AppModel state) => state.selectedYearMonth)
        .getFullMonthWeekdayList();

    return SizedBox(
      height: 500,
      child: Column(children: [
        calendarRow(weekdayName),
      ]),
    );
  }

  Row calendarRow(List children) {
    return Row(
      children: children.map((child) {
        return Text(child);
      }).toList(),
    );
  }
}
