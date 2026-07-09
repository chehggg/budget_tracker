import 'dart:ui' as ui;

import 'package:another_flushbar/flushbar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    required this.controller,
    required this.selectedDate,
    this.onDone,
    this.onDateTapped,
    this.onTap,
  });

  final TextEditingController controller;
  final String customButton;
  final KeyboardLayout layout;
  final void Function()? onDone;
  final void Function(KeyboardButtonType type, String value)? onTap;
  final DateTime selectedDate;
  final void Function()? onDateTapped;

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool _isCalculating = false;

  List<KeyboardButton> get simpleButtons => [
    KeyboardButton(type: KeyboardButtonType.char, value: "1"),
    KeyboardButton(type: KeyboardButtonType.char, value: "4"),
    KeyboardButton(type: KeyboardButtonType.char, value: "7"),
    KeyboardButton(type: KeyboardButtonType.char, value: widget.customButton),
    KeyboardButton(type: KeyboardButtonType.char, value: "2"),
    KeyboardButton(type: KeyboardButtonType.char, value: "5"),
    KeyboardButton(type: KeyboardButtonType.char, value: "8"),
    KeyboardButton(type: KeyboardButtonType.char, value: "0"),
    KeyboardButton(type: KeyboardButtonType.char, value: "3"),
    KeyboardButton(type: KeyboardButtonType.char, value: "6"),
    KeyboardButton(type: KeyboardButtonType.char, value: "9"),
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
    KeyboardButton(type: KeyboardButtonType.char, value: "1"),
    KeyboardButton(type: KeyboardButtonType.char, value: "4"),
    KeyboardButton(type: KeyboardButtonType.char, value: "7"),
    KeyboardButton(type: KeyboardButtonType.char, value: widget.customButton),
    KeyboardButton(type: KeyboardButtonType.char, value: "2"),
    KeyboardButton(type: KeyboardButtonType.char, value: "5"),
    KeyboardButton(type: KeyboardButtonType.char, value: "8"),
    KeyboardButton(type: KeyboardButtonType.char, value: "0"),
    KeyboardButton(type: KeyboardButtonType.char, value: "3"),
    KeyboardButton(type: KeyboardButtonType.char, value: "6"),
    KeyboardButton(type: KeyboardButtonType.char, value: "9"),
    KeyboardButton(type: KeyboardButtonType.char, value: "00"),
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
      // child: GridView(
      //   physics: NeverScrollableScrollPhysics(),
      //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 4,
      //     mainAxisSpacing: 8,
      //     crossAxisSpacing: 8,
      //     mainAxisExtent: 50,
      //     // childAspectRatio: 1.5
      //   ),
      //   children:
      //       buttons.map((KeyboardButton button) {
      //         final Widget child;
      //         switch (button.type) {
      //           case KeyboardButtonType.char:
      //             // child = button.display;
      //             child = customTextButton(button.value as String, context);
      //           case KeyboardButtonType.date:
      //             child = Row(
      //               mainAxisSize: MainAxisSize.min,
      //               spacing: 4,
      //               children: [
      //                 Icon(
      //                   Icons.date_range,
      //                   color: context.cs.surface,
      //                   size: 18,
      //                 ),
      //                 Text(
      //                   widget.selectedDate.displayFormat(),
      //                   style: context.customTt.numberFontSmall!.copyWith(
      //                     color: context.cs.surface,
      //                   ),
      //                 ),
      //               ],
      //             );
      //           default:
      //             child = button.display;
      //             // child = Icon(button.value as IconData);
      //         }
      //         return Container(
      //           height: 20,
      //           decoration: BoxDecoration(
      //             color:
      //                 button.type == KeyboardButtonType.date
      //                     ? context.cs.primary
      //                     : button.type == KeyboardButtonType.done
      //                     ? context.cs.secondary
      //                     : context.cs.primary.withAlpha(10),
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //           child: Material(
      //             color: Colors.transparent,
      //             child: InkWell(
      //               customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //               onTap: () {
      //                 // widget.onTap?.call(button.type, button.value);
      //                 switch (button.type) {
      //                   case KeyboardButtonType.char:
      //                     updateText(button.value ?? "");
      //                   case KeyboardButtonType.date:
      //                     widget.onDateTapped();
      //                   case KeyboardButtonType.delete:
      //                     deleteText();
      //                   case KeyboardButtonType.done:
      //                     // if + and - is present, button switch to calculation mode
      //                     if (_isCalculating) {
      //                       calculateAmount();
      //                     } else {
      //                       widget.onDone();
      //                     }
      //                 }
      //                 HapticFeedback.lightImpact();
      //               },
      //               child: Center(child: child),
      //             ),
      //           ),
      //         );
      //       }).toList(),
      // ),
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
      backgroundColor: isActive == true ? context.cs.primary.withAlpha(20) : null,
      label: label ?? SizedBox.shrink(),
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
  });

  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?>? onSelected;
  final T? initSelection;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: initSelection,
      onSelected: onSelected,
      expandedInsets: EdgeInsets.zero,
      dropdownMenuEntries: entries,
      textStyle: context.tt.bodyMedium,
      inputDecorationTheme: InputDecorationThemeData(
        visualDensity: VisualDensity(vertical: -4),
        constraints: BoxConstraints(maxHeight: 40),
      ),
      menuStyle: MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.comfortable,
        backgroundColor: WidgetStatePropertyAll(
          context.cs.surfaceContainer,
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
  });

  final ValueChanged<bool>? onSelected;
  final bool value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onSelected?.call(!value);
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          onChanged: onSelected,
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
    this.safeAreaPadding = const EdgeInsets.only(top: 12, left: 12, right: 12),
  });

  final Widget child;
  final bool ready;
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final bool padHorizontal;
  final EdgeInsets safeAreaPadding;

  @override
  Widget build(BuildContext context) {
    final pad =
        padHorizontal
            ? const EdgeInsets.only(top: 12, left: 12, right: 12)
            : const EdgeInsets.only(top: 12);
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
