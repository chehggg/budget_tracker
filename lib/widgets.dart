import 'dart:ui' as ui;

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/ui/list/main_list_viewmodel.dart';

class CustomKeyboard extends StatefulWidget {
  const CustomKeyboard({
    super.key,
    this.layout = KeyboardLayout.simple,
    this.customButton = ".",
    this.reversed = false,
    this.customButtonReversed = false,
    required this.controller,
    required this.selectedDate,
    this.onDone,
    this.onDateTapped,
    this.onTap,
  });

  final TextEditingController controller;
  final String customButton;
  final KeyboardLayout layout;
  final bool reversed;
  final bool customButtonReversed;
  final void Function()? onDone;
  final void Function(KeyboardButtonType type, String value)? onTap;
  final DateTime selectedDate;
  final void Function()? onDateTapped;

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool _isCalculating = false;

  List<KeyboardButton> get numColumn1 => [
    KeyboardButton(type: KeyboardButtonType.char, value: "1"),
    KeyboardButton(type: KeyboardButtonType.char, value: "4"),
    KeyboardButton(type: KeyboardButtonType.char, value: "7"),
  ];
  List<KeyboardButton> get numColumn2 => [
    KeyboardButton(type: KeyboardButtonType.char, value: "2"),
    KeyboardButton(type: KeyboardButtonType.char, value: "5"),
    KeyboardButton(type: KeyboardButtonType.char, value: "8"),
  ];
  List<KeyboardButton> get numColumn3 => [
    KeyboardButton(type: KeyboardButtonType.char, value: "3"),
    KeyboardButton(type: KeyboardButtonType.char, value: "6"),
    KeyboardButton(type: KeyboardButtonType.char, value: "9"),
  ];

  KeyboardButton get customButton =>
      KeyboardButton(type: KeyboardButtonType.char, value: widget.customButton);
  KeyboardButton get doubleZeroButton => KeyboardButton(type: KeyboardButtonType.char, value: "00");

  List<KeyboardButton> get simpleButtons => [
    ...widget.reversed ? numColumn1.reversed : numColumn1,
    customButton,
    ...widget.reversed ? numColumn2.reversed : numColumn2,
    KeyboardButton(type: KeyboardButtonType.char, value: "0"),
    ...widget.reversed ? numColumn3.reversed : numColumn3,
    KeyboardButton(type: KeyboardButtonType.delete, widget: Icon(Icons.backspace_rounded)),
    KeyboardButton(type: KeyboardButtonType.date, widget: FaIcon(FontAwesomeIcons.calendarDay)),
    KeyboardButton(type: KeyboardButtonType.char, value: "+"),
    KeyboardButton(type: KeyboardButtonType.char, value: "-"),
    KeyboardButton(
      type: KeyboardButtonType.done,
      widget: Icon(_isCalculating ? Symbols.equal : Icons.check),
    ),
  ];

  List<KeyboardButton> get complexButtons => [
    KeyboardButton(type: KeyboardButtonType.char, value: "+"),
    KeyboardButton(type: KeyboardButtonType.char, value: "-"),
    KeyboardButton(type: KeyboardButtonType.char, value: "×", widget: Icon(Icons.close)),
    KeyboardButton(type: KeyboardButtonType.char, value: "÷"),
    ...widget.reversed ? numColumn1.reversed : numColumn1,
    widget.customButtonReversed ? doubleZeroButton : customButton,
    ...widget.reversed ? numColumn2.reversed : numColumn2,
    KeyboardButton(type: KeyboardButtonType.char, value: "0"),
    ...widget.reversed ? numColumn3.reversed : numColumn3,
    widget.customButtonReversed ? customButton : doubleZeroButton,
    KeyboardButton(type: KeyboardButtonType.date, widget: FaIcon(FontAwesomeIcons.calendarDay)),
    KeyboardButton(type: KeyboardButtonType.delete, widget: FaIcon(FontAwesomeIcons.deleteLeft)),
    KeyboardButton(
      type: KeyboardButtonType.done,
      widget: Icon(_isCalculating ? Symbols.equal : Icons.check),
    ),
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

  void updateText(String input) {
    // final newText = "${widget.controller.text}$input".replaceAll(r',', '');
    // if (input == "+" || input == "-") {
    //   widget.controller.value = widget.controller.value.copyWith(
    //     text: '${widget.controller.text}$input',
    //   );
    // }
    // final latestText = newText.split(RegExp(r'[\+-]')).last;
    // final formatted = [];
    // for (final subStr in subStrings) {
    //   RegExp(r'^\d+(\.\d+)?$').hasMatch(input);
    // }
    // if (newText.length > 4 && RegExp(r'\d{4}$').hasMatch(newText)) {}
    // // if (!validateText(newText)) return;
    widget.controller.value = widget.controller.value.copyWith(
      text: '${widget.controller.text}$input',
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(checkCalculating);
  }

  void deleteText() {
    if (widget.controller.text.isEmpty) return;
    final index = widget.controller.text.length;
    widget.controller.value = widget.controller.value.copyWith(
      text: widget.controller.text.replaceRange(index - 1, null, ""),
    );
  }

  void calculateAmount() async {
    try {
      final ShuntingYardParser p = ShuntingYardParser();
      final text = widget.controller.text.replaceAll("×", "*").replaceAll("÷", "/");
      Expression expression = p.parse(text);
      num value = RealEvaluator().evaluate(expression);

      widget.controller.value = widget.controller.value.copyWith(
        text: value.toStringAsFixed(value % 1 == 0 ? 0 : 2),
      );
    } catch (e) {
      // using sign without value throw error, do not allow calculation
      widget.controller.value = widget.controller.value.copyWith(text: widget.controller.text);
      context.showErrorNotification(
        message: "Error in performing operation, make sure the formula is correct.",
      );
    }
  }

  void checkCalculating() {
    // regex check for a add or subtraction of two numbers
    if (mounted && widget.controller.text.contains(RegExp(r'\d+[\+\-×÷]+\d?'))) {
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
    final isComplex = widget.layout == KeyboardLayout.complex;

    Widget buttonContent(KeyboardButton button) => InkWell(
      child: switch (button.type) {
        KeyboardButtonType.char => Text(
          button.value ?? "",
          style: context.customTt.numberFontSmall,
        ),
        KeyboardButtonType.date => Flex(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          direction: isComplex ? Axis.vertical : Axis.horizontal,
          children: [
            FaIcon(
              FontAwesomeIcons.solidCalendarDays,
              color: context.cs.surface,
              size: 18,
            ),
            Text(
              widget.selectedDate.formatShorter(),
              style: context.customTt.numberFontSmall!.copyWith(
                color: context.cs.surface,
              ),
            ),
          ],
        ),
        _ => button.display,
      },
    );

    Color buttonColor(KeyboardButton button) {
      switch (button.type) {
        case KeyboardButtonType.date:
          return Colors.white;
        case KeyboardButtonType.done:
          return context.cs.secondary;
        default:
          return context.customCs.fadeColor3 ?? Colors.transparent;
      }
    }

    void buttonOnTap(KeyboardButton button) {
      switch (button.type) {
        case KeyboardButtonType.char:
          updateText(button.value ?? "");
        case KeyboardButtonType.delete:
          deleteText();
        case KeyboardButtonType.date:
          widget.onDateTapped?.call();
        case KeyboardButtonType.done:
          if (_isCalculating) {
            calculateAmount();
          } else {
            widget.onDone?.call();
          }
      }
    }

    int flexSize(KeyboardButton button) {
      if (button.type == KeyboardButtonType.date && isComplex) {
        return 2;
      }
      return 1;
    }

    final layout = isComplex ? complexButtons.slices(4).toList() : simpleButtons.slices(4).toList();

    return Container(
      padding: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        // color: context.cs.surface,
        // border: BoxBorder.all(color: Colors.white),
      ),
      width: context.mq.size.width,
      child: Flex(
        spacing: 8,
        direction: Axis.horizontal,
        children: [
          ...layout.mapIndexed(
            (index, column) => Flexible(
              flex: (isComplex && index == 0) ? 2 : 3,
              fit: FlexFit.tight,
              child: Flex(
                spacing: 8,
                direction: Axis.vertical,
                children: [
                  ...column.map((button) {
                    return Flexible(
                      fit: FlexFit.tight,
                      flex: flexSize(button),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: buttonColor(button),
                        ),
                        height: 20,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            // radius: 10,
                            // overlayColor: WidgetStatePropertyAll(Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              buttonOnTap(button);
                              HapticFeedback.lightImpact();
                            },
                            child: Center(child: buttonContent(button)),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
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
  const KeyboardButton({required this.type, this.value, this.widget, this.textStyle});

  final KeyboardButtonType type;
  final Widget? widget;
  final String? value;
  final TextStyle? textStyle;

  Widget get display => widget ?? Text(value ?? "", style: textStyle);
}

class HideableText extends StatelessWidget {
  const HideableText(
    this.data, {
    super.key,
    this.overflowText = "",
    this.blurredText,
    this.asteriskCount = 3,
    this.isCurrency = true,
    required this.textStyle,
    this.maxLine = 1,
  });

  final String data;
  final String overflowText;
  final bool isCurrency;
  final int asteriskCount;
  final String? blurredText;
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
    final isBlurred = context.select((ListViewModel state) => state.isBlurred);
    // final currency = context.read<AppModel>().currencySymbol;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!hasTextOverflow(
          data,
          textStyle,
          MediaQuery.textScalerOf(context),
          maxWidth: constraints.maxWidth * 0.9,
          maxLines: maxLine,
        )) {
          return Text(
            isBlurred
                ? blurredText ??
                    data.replaceAll(
                      RegExp(r'[0-9,.]+[kKMbB]?'),
                      List.filled(asteriskCount, "*").join(""),
                    )
                : data,
            style: textStyle,
          );
        } else {
          return Text(
            isBlurred ? blurredText ?? "***" : overflowText,
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
  late YearMonth _yearMonth;

  @override
  void initState() {
    super.initState();
    _yearMonth = context.listMod.currentYearMonth;
    _selectedDateTime = _yearMonth.date1;
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
                            _selectedDateTime = _selectedDateTime.addYear(-1);
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
                            _selectedDateTime = _selectedDateTime.addYear(1);
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
                              ? context.listMod.currencyFormat(balance, abbreviated: true)
                              : "N/A";
                      final color =
                          _yearMonth.isInYearMonth(date) ? context.customCs.fadeColor4 : null;
                      final innerColor =
                          _yearMonth.isWithin(date) && !_yearMonth.isInYearMonth(date)
                              ? context.customCs.fadeColor3
                              : null;

                      return GestureDetector(
                        onTap: () {
                          if (!_yearMonth.useRange) {
                            setState(() {
                              _yearMonth = _yearMonth.copyWith(date1: date);
                            });
                            context.listMod.updateYearMonth(_yearMonth);
                            context.pop();
                          } else {
                            if (_yearMonth.date2 != null) {
                              setState(() {
                                _yearMonth = _yearMonth.copyWith(date1: date, date2: () => null);
                              });
                              debugPrint("end date is not null, select new date");
                              debugPrint("new year month: ${_yearMonth.date2}");
                            } else if (date.isBefore(_yearMonth.date1)) {
                              debugPrint("start date before select date, select new date");
                              setState(() {
                                _yearMonth = _yearMonth.copyWith(date1: date, date2: () => null);
                              });
                            } else {
                              setState(() {
                                _yearMonth = _yearMonth.copyWith(date2: () => date);
                              });
                              context.listMod.updateYearMonth(_yearMonth);
                              context.pop();
                            }
                          }

                          // setState(() {
                          //   _selectedDateTime = date;
                          // });
                          // if (_useRange && _selectedStart != null) {
                          //   if (_selectedEnd != null) {
                          //     setState(() {
                          //       _selectedStart = date;
                          //       _selectedEnd = null;
                          //     });
                          //   } else if (date.isBefore(_selectedStart!)) {
                          //     setState(() {
                          //       _selectedStart = date;
                          //       _selectedEnd = null;
                          //     });
                          //   } else {
                          //     context.listMod.updateDateRange(
                          //       DateTimeRange(start: _selectedStart!, end: date),
                          //     );
                          //     context.pop();
                          //   }
                          // } else {
                          //   context.listMod.updateYearMonth(date);
                          //   context.nav.pop();
                          // }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              decoration: BoxDecoration(color: innerColor),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('MMM').format(date),
                                    style: context.customTt.dateLabel!.copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    displayText,
                                    style: context.customTt.numberFontSmall!.copyWith(
                                      fontSize: 12,
                                      color:
                                          balance < 0
                                              ? context.listMod.accentColors.negative
                                              : balance > 0
                                              ? context.listMod.accentColors.positive
                                              : context.customCs.fadeColor1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                Divider(),
                Column(
                  spacing: 4,
                  children: [
                    CustomSwitchListTile(
                      dense: true,
                      title: "Use Range",
                      onSelected: (value) {
                        setState(
                          () => _yearMonth = _yearMonth.copyWith(useRange: !_yearMonth.useRange),
                        );
                        if (!_yearMonth.useRange) {
                          context.listMod.updateYearMonth(
                            YearMonth(useRange: false, date1: _yearMonth.date1),
                          );
                          context.pop();
                        }
                      },
                      value: _yearMonth.useRange,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        "Select Current Month",
                        style: context.tt.bodyMedium,
                      ),
                      onTap: () {
                        context.listMod.updateYearMonth(
                          YearMonth(useRange: false, date1: DateTime.now().startOfMonth),
                        );
                        context.pop();
                      },
                    ),
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

class AffirmativeTextButton extends StatelessWidget {
  const AffirmativeTextButton({super.key, this.onTap, this.text = 'Confirm'});

  final GestureTapCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: context.customTt.numberFontSmall!.copyWith(color: context.cs.onSurface),
        ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: context.customTt.numberFontSmall!.copyWith(color: Colors.red.shade600),
        ),
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
      onTap: onTap ?? () => context.nav.pop(false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: context.customTt.numberFontSmall!.copyWith(color: context.customCs.fadeColor1),
        ),
      ),
    );
  }
}

class ScreenWrapper extends StatelessWidget {
  const ScreenWrapper({super.key, required this.child, this.canPop, this.popAction});
  final Widget child;
  final bool? canPop;
  final void Function(bool, dynamic)? popAction;
  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: canPop ?? false, onPopInvokedWithResult: popAction, child: child);
  }
}

class CustomActionChip extends StatelessWidget {
  const CustomActionChip({super.key, this.onPressed, this.isActive, this.label, this.icon});

  final VoidCallback? onPressed;
  final bool? isActive;
  final Widget? label;

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon,
      backgroundColor: isActive == true ? context.customCs.fadeColor1 : null,
      label: label ?? SizedBox.shrink(),
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      labelPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class CustomDropDownMenu<T> extends StatelessWidget {
  const CustomDropDownMenu({
    super.key,
    required this.entries,
    this.onSelected,
    this.initSelection,
    this.border,
    this.textAlign,
  });

  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?>? onSelected;
  final T? initSelection;
  final InputBorder? border;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: initSelection,
      onSelected: onSelected,
      expandedInsets: EdgeInsets.zero,
      dropdownMenuEntries: entries,
      textStyle: context.tt.bodyMedium,
      textAlign: textAlign ?? TextAlign.start,
      inputDecorationTheme: InputDecorationThemeData(
        visualDensity: VisualDensity(vertical: -4),
        constraints: BoxConstraints(maxHeight: 40),
        filled: true,
        fillColor: context.customCs.fadeColor4,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
      menuStyle: MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.comfortable,
        backgroundColor: WidgetStatePropertyAll(
          context.cs.surfaceContainerHigh,
        ),
      ),
    );
  }
}

class CustomDropdownListTile<T> extends StatelessWidget {
  const CustomDropdownListTile({
    super.key,
    required this.entries,
    required this.title,
    this.onSelected,
    this.initSelection,
    this.width = 160,
  });

  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?>? onSelected;
  final T? initSelection;
  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        title,
        style: context.tt.bodyMedium,
      ),
      trailing: SizedBox(
        width: width,
        child: CustomDropDownMenu(
          entries: entries,
          initSelection: initSelection,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class CustomSwitchListTile extends StatelessWidget {
  const CustomSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    this.onSelected,
    this.enabled = true,
    this.dense = false,
  });

  final ValueChanged<bool>? onSelected;
  final bool value;
  final String title;
  final bool enabled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        enabled ? onSelected?.call(!value) : null;
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: dense ? 0 : 6),
      title: Text(
        title,
        style: context.tt.bodyMedium,
      ),
      trailing: Transform.scale(
        scale: 0.8,
        // width: width,
        child: Switch(
          padding: EdgeInsets.zero,
          value: value,
          onChanged: enabled ? onSelected : null,
        ),
      ),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.child,
    this.ready = true,
    this.appBarTitle,
    this.actions,
    this.padHorizontal = false,
    this.safeAreaPadding,
  });

  final Widget child;
  final bool ready;
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final bool padHorizontal;
  final EdgeInsets? safeAreaPadding;

  @override
  Widget build(BuildContext context) {
    final pad =
        safeAreaPadding ??
        (padHorizontal
            ? const EdgeInsets.only(top: 12, left: 12, right: 12)
            : const EdgeInsets.only(top: 12));
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 8),
        title: appBarTitle,
        actions: actions,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        minimum: pad,
        child:
            ready == true
                ? child
                : const Center(
                  child: CircularProgressIndicator(),
                ),
      ),
    );
  }
}

class CustomSpacedScrollView extends StatelessWidget {
  const CustomSpacedScrollView({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ...children.map((el) => SliverToBoxAdapter(child: el)),
        SliverToBoxAdapter(
          child: Container(
            height: 50,
          ),
        ),
      ],
    );
  }
}
