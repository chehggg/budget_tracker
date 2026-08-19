import 'dart:ui' as ui;

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:math_expressions/math_expressions.dart' as mathexp;
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
      final mathexp.ShuntingYardParser p = mathexp.ShuntingYardParser();
      final text = widget.controller.text.replaceAll("×", "*").replaceAll("÷", "/");
      mathexp.Expression expression = p.parse(text);
      num value = mathexp.RealEvaluator().evaluate(expression);

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
            overflow: TextOverflow.ellipsis,
            maxLines: maxLine,
          );
        } else {
          return Text(
            isBlurred ? blurredText ?? "***" : overflowText,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLine,
          );
        }
      },
    );
  }
}

// Month select dialog for changing to another month quickly
// using the date selector top bar
class MonthSelectorSheet extends StatefulWidget {
  const MonthSelectorSheet({super.key});

  @override
  State<MonthSelectorSheet> createState() => _MonthSelectorSheetState();
}

class _MonthSelectorSheetState extends State<MonthSelectorSheet> {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 12,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Text(
                  "Month",
                  style: context.customTt.dateLabel,
                ),
              ),
              ActionChip(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                visualDensity: VisualDensity(vertical: 0),
                backgroundColor:
                    _yearMonth.useRange
                        ? context.customCs.fadeColor2
                        : context.cs.surfaceContainerHigh,
                onPressed: () {
                  final prevDate2 = _yearMonth.date2;
                  setState(
                    () => _yearMonth = _yearMonth.copyWith(useRange: !_yearMonth.useRange),
                  );
                  if (!_yearMonth.useRange) {
                    context.listMod.updateYearMonth(
                      YearMonth(useRange: false, date1: prevDate2 ?? _yearMonth.date1),
                    );
                    context.pop();
                  }
                },
                avatar: FaIcon(
                  FontAwesomeIcons.calendarWeek,
                  size: 14,
                ),
                label: Text("Range"),
              ),
            ],
          ),
          Divider(height: 20),
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
              // mainAxisSpacing: 2,
              crossAxisCount: 4,
              childAspectRatio: 1.3,
            ),
            children: [
              ...List.generate(12, (i) => i + 1).map((value) {
                final date = DateTime(_selectedDateTime.year, value, 1);
                final balance = monthlyOverview[date]?.balance ?? 0;
                final displayText =
                    monthlyOverview.containsKey(date)
                        ? context.listMod.currencyFormat(
                          balance,
                          abbreviated: true,
                          alwaysShowSign: true,
                          showSymbol: false,
                        )
                        : "N/A";
                final color = _yearMonth.isInYearMonth(date) ? context.customCs.fadeColor4 : null;
                final innerColor =
                    _yearMonth.isWithin(date) && !_yearMonth.isInYearMonth(date)
                        ? context.customCs.fadeColor3
                        : null;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!_yearMonth.useRange) {
                        _yearMonth = _yearMonth.copyWith(date1: date);
                        context.listMod.updateYearMonth(_yearMonth);
                        context.pop();
                      } else {
                        if (_yearMonth.date2 != null) {
                          _yearMonth = _yearMonth.copyWith(date1: date, date2: () => null);
                        } else if (date.isBefore(_yearMonth.date1)) {
                          _yearMonth = _yearMonth.copyWith(date1: date, date2: () => null);
                        } else {
                          _yearMonth = _yearMonth.copyWith(date2: () => date);
                          context.listMod.updateYearMonth(_yearMonth);
                          context.pop();
                        }
                      }
                    });
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
                              style: context.customTt.dateLabel!.copyWith(fontSize: 24),
                            ),
                            Text(
                              displayText,
                              style: context.customTt.numberFontSmall!.copyWith(
                                fontSize: 14,
                                color:
                                    balance == 0
                                        ? context.customCs.fadeColor1
                                        : context.listMod.accentColors.getColorByValue(balance),
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
          // Divider(
          //   height: 30,
          // ),
          Row(
            children: [
              Expanded(
                child: CustomTextButton(
                  icon: FontAwesomeIcons.rotateLeft,
                  text: "Reset",
                  onTap: () {
                    context.listMod.updateYearMonth(
                      YearMonth(useRange: false, date1: DateTime.now().startOfMonth),
                    );
                    context.pop();
                  },
                ),
              ),
            ],
          ),
          // BottomSheetButtons(
          //   popResult: YearMonth(useRange: false, date1: DateTime.now().startOfMonth),
          //   popResultFalse: YearMonth(useRange: false, date1: DateTime.now().startOfMonth),
          // ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
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
        visualDensity: VisualDensity(vertical: -3),
        constraints: BoxConstraints(maxHeight: 40),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        fillColor: context.customCs.fadeColor4,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
      menuStyle: MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.comfortable,
        backgroundColor: WidgetStatePropertyAll(
          context.customCs.dropdownColor,
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
    this.customStyle,
    this.enabled = true,
    this.dense = false,
  });

  final ValueChanged<bool>? onSelected;
  final bool value;
  final String title;
  final TextStyle? customStyle;
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
        textAlign: TextAlign.left,
        style: customStyle ?? context.tt.bodyMedium,
      ),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.7,
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
    this.resizeInset,
    this.customAppBar,
    this.bottomSheet,
  });

  final Widget child;
  final bool ready;
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final bool padHorizontal;
  final EdgeInsets? safeAreaPadding;
  final bool? resizeInset;
  final PreferredSizeWidget? customAppBar;
  final Widget? bottomSheet;

  @override
  Widget build(BuildContext context) {
    final pad =
        safeAreaPadding ??
        (padHorizontal
            ? const EdgeInsets.only(top: 12, left: 12, right: 12)
            : const EdgeInsets.only(top: 12));
    return Scaffold(
      resizeToAvoidBottomInset: resizeInset,
      appBar:
          customAppBar ??
          AppBar(
            actionsPadding: EdgeInsets.only(right: 8),
            title: appBarTitle,
            actions: actions,
            scrolledUnderElevation: 0,
            elevation: 0,
          ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: pad,
              child: child,
            ),
            if (ready != true) const LoadingOverlay(),
          ],
        ),
      ),
      bottomSheet: bottomSheet,
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: context.cs.surface.withAlpha(80)),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.cs.surface,
          ),
          width: 100,
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(),
          ),
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

class CustomMenuAnchor extends StatelessWidget {
  const CustomMenuAnchor({super.key, this.animated = false, required this.items});

  final bool animated;
  final List<MenuChild> items;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      animated: animated,
      builder: (context, controller, child) {
        return IconButton(
          iconSize: 20,
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          icon: FaIcon(
            FontAwesomeIcons.ellipsisVertical,
            size: 18,
          ),
        );
      },
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.all(4)),
        visualDensity: VisualDensity(vertical: -4),
        backgroundColor: WidgetStatePropertyAll(context.cs.surfaceContainerHighest),
      ),
      menuChildren:
          items.map((el) {
            return ListTile(
              onTap: el.onTap,
              title: Row(
                spacing: 12,
                children: [
                  FaIcon(
                    el.icon,
                    size: 16,
                    color: el.color,
                  ),
                  Text(
                    el.name,
                    style: context.tt.bodyMedium!.copyWith(color: el.color),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    this.borderColor,
    this.bgColor,
    this.fgColor,
    this.inverse = false,
    this.icon,
    this.iconSize = 14,
    this.text = "",
    this.onTap,
  });

  final Color? borderColor;
  final Color? bgColor;
  final Color? fgColor;
  final bool inverse;
  final FaIconData? icon;
  final double iconSize;
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: bgColor ?? context.customCs.fadeColor3,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor ?? context.customCs.fadeColor2!),
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        visualDensity: VisualDensity(vertical: -3),
        padding: EdgeInsets.all(24),
        foregroundColor: fgColor ?? (inverse ? context.cs.surface : context.cs.primary),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          FaIcon(
            icon ?? FontAwesomeIcons.elementor,
            size: iconSize,
          ),
          Text(
            text,
            style: context.customTt.numberFontMedium!.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class BottomSheetButtons extends StatelessWidget {
  const BottomSheetButtons({super.key, this.popResult, this.popResultFalse});

  final dynamic popResult;
  final dynamic popResultFalse;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: CustomTextButton(
            text: "Reset",
            icon: FontAwesomeIcons.rotateLeft,
            onTap: () => context.pop(popResultFalse),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 2,
          child: CustomTextButton(
            text: "Save",
            icon: FontAwesomeIcons.solidFloppyDisk,
            bgColor: context.cs.secondary,
            borderColor: Colors.transparent,
            inverse: true,
            iconSize: 16,
            onTap: () => context.pop(popResult),
          ),
        ),
      ],
    );
  }
}
