import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

class CustomKeyboard extends StatefulWidget {
  const CustomKeyboard({
    super.key,
    required this.controller,
    required this.onDone,
    required this.selectedDate,
    required this.onDateTapped,
  });

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
    KeyboardButton(type: "done", value: _isCalculating ? Icons.calculate : Icons.check),
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
    widget.controller.value = widget.controller.value.copyWith(
      text: '${widget.controller.text}$newText',
    );
  }

  void deleteText() {
    if (widget.controller.text.isEmpty) return;
    final index = widget.controller.text.length;
    widget.controller.value = widget.controller.value.copyWith(
      text: widget.controller.text.replaceRange(index - 1, null, ""),
    );
  }

  void calculateAmount() async {
    debugPrint("try to calculate");
    try {
      final Parser p = Parser();
      Expression expression = p.parse(widget.controller.text);
      double value = expression.evaluate(EvaluationType.REAL, ContextModel());

      widget.controller.value = widget.controller.value.copyWith(
        text: value.toStringAsFixed(value % 1 == 0 ? 0 : 2),
      );
    } catch (e) {
      // using sign without value throw error, do not allow calculation
      widget.controller.value = widget.controller.value.copyWith(text: widget.controller.text);
      saveErrorFlushbar("Invalid operation, make sure the formula is correct").show(context);
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
        children:
            buttons(context).map((KeyboardButton button) {
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
                        style: context.customTt.numberFontSmall!.copyWith(
                          color: context.cs.onPrimary,
                        ),
                      ),
                    ],
                  );
                default:
                  child = Icon(button.value as IconData);
              }
              return Container(
                height: 20,
                decoration: BoxDecoration(
                  color:
                      button.type == "date"
                          ? context.cs.primary
                          : button.type == "done"
                          ? context.cs.secondary
                          : context.cs.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            if (widget.controller.text == "0" || widget.controller.text == "") {
                              saveErrorFlushbar(
                                "Amount cannot be 0. Please input a number larger than 0!",
                              ).show(context);
                            } else if ((widget.controller.text).contains(RegExp(r'^\-\d+$'))) {
                              // one negative number
                              saveErrorFlushbar(
                                "Amount cannot be negative. Please input a number larger than 0",
                              ).show(context);
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
      ),
    );
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
  const HideableText(
    this.data, {
    super.key,
    this.overflowText,
    this.isCurrency = true,
    required this.textStyle,
    this.maxLine = 1,
  });

  final String data;
  final String? overflowText;
  final bool isCurrency;
  final TextStyle textStyle;
  final int maxLine;

  bool hasTextOverflow(
    String text,
    TextStyle style,
    TextScaler scaler, {
    double minWidth = 0,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
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
    final isBlurred = context.select((ListModel state) => state.isBlurred);
    // final currency = context.read<AppModel>().currencySymbol;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!hasTextOverflow(
          data,
          textStyle,
          MediaQuery.textScalerOf(context),
          maxWidth: constraints.maxWidth,
          maxLines: maxLine,
        )) {
          return Text(
            isBlurred ? data.replaceAll(RegExp(r'[0-9,.]+[kKMbB]?'), '***') : data,
            style: textStyle,
          );
          // } else if (overflowText == null) {
          //   return Text(
          //     isBlurred ? '${isCurrency == true ? '$currency ' : ''}***' : data,
          //     style: textStyle,
          //   );
        } else {
          return Text(
            isBlurred ? "***" : overflowText!,
            style: textStyle,
          );
        }
      },
    );
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
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = context.listMod.currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyOverview = context.listMod.monthlyOverview;
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.7,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDateTime = DateTime(
                              _selectedDateTime.year - 1,
                              _selectedDateTime.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _selectedDateTime.year.toString(),
                            style: context.customTt.dateLabel!.copyWith(fontSize: 30),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDateTime = DateTime(
                              _selectedDateTime.year + 1,
                              _selectedDateTime.month,
                            );
                          });
                        },
                        icon: Icon(Icons.chevron_right_rounded, size: 30),
                      ),
                    ],
                  ),
                ),
                GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.1,
                  ),
                  children: [
                    ...List.generate(12, (i) => i + 1).map((value) {
                      final date = DateTime(_selectedDateTime.year, value, 1);
                      final balance = monthlyOverview[date]?.balance ?? 0;
                      final displayText =
                          monthlyOverview.containsKey(date)
                              ? NumberFormat.compactCurrency(symbol: "RM").format(balance)
                              : "N/A";
                      return GestureDetector(
                        onTap: () {
                          context.listMod.changeYearMonth(date);
                          context.nav.pop();
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: date == _selectedDateTime ? context.customCs.fadeColor2 : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('MMM').format(date),
                                style: context.customTt.dateLabel!.copyWith(fontSize: 20),
                              ),
                              Text(
                                displayText,
                                style: context.tt.bodyMedium!.copyWith(
                                  fontSize: 12,
                                  color:
                                      balance < 0
                                          ? Colors.red
                                          : balance > 0
                                          ? Colors.green
                                          : context.customCs.fadeColor1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      ),
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
    final List<int> weekdayList =
        context.select((AppModel state) => state.selectedYearMonth).getFullMonthWeekdayList();

    return SizedBox(
      height: 500,
      child: Column(
        children: [
          calendarRow(weekdayName),
        ],
      ),
    );
  }

  Row calendarRow(List children) {
    return Row(
      children:
          children.map((child) {
            return Text(child);
          }).toList(),
    );
  }
}

class AffirmativeTextButton extends StatelessWidget {
  const AffirmativeTextButton({super.key, this.onTap, this.text = 'Confirm'});

  final GestureTapCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: context.customTt.numberFontSmall!.copyWith(color: context.cs.onSurface),
      ),
    );
  }
}

class PrimaryNegativeTextButton extends StatelessWidget {
  const PrimaryNegativeTextButton({super.key, this.onTap, this.text = 'Delete'});

  final GestureTapCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: context.customTt.numberFontSmall!.copyWith(color: context.cs.error),
      ),
    );
  }
}

class DismissTextButton extends StatelessWidget {
  const DismissTextButton({super.key, this.onTap, this.text = 'Back'});

  final GestureTapCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.nav.pop(false),
      child: Text(
        text,
        style: context.customTt.numberFontSmall!.copyWith(color: context.customCs.fadeColor2),
      ),
    );
  }
}
