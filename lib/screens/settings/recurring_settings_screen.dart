import 'dart:collection';

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum RecCostStartMonthType {weekNum, dateNum}
enum RecCostEndType {date, occurence}


extension DateTimeExtension on DateTime {
  int get numberOfWeek {
    var date = this;
    var firstOfMonthWeekday = DateTime(date.year, date.month, 1).weekday; 
    var weekday = this.weekday;
    var firstWeekdayDay = 1 + (weekday - firstOfMonthWeekday + 7)%7;
    return (date.day - firstWeekdayDay)~/7 + 1;
  }

}
  
class RecurringCostScreen extends StatefulWidget {
  const RecurringCostScreen({super.key});

  @override
  State<RecurringCostScreen> createState() => _RecurringCostScreenState();
}

class _RecurringCostScreenState extends State<RecurringCostScreen> {
  ListTile tile({title, leading, trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: title,
      leading: leading,
      trailing: trailing,
    );
  }

  void createRecurringCost() {
    setState(() {
     _recurringDates.clear();  
    });
    // DateTime date = selectedStartDate;

    int recCount = int.parse(recCountController.text);
    int occurence = int.parse(occurenceController.text);

    void addDate(DateTime startDate, {DateTime Function(DateTime)? updateDate}) {
      DateTime curDate = startDate;
      if (endType == RecCostEndType.date) {
        while (curDate.isBefore(selectedEndDate.add(Duration(hours: 12)))){ 
          debugPrint("added date: ${DateFormat('dd-MM-yyyy').format(curDate)}");
          _recurringDates.add(curDate);
          if (updateDate != null) {
            curDate = updateDate(curDate);
          }
        }
      } else {
        while (_recurringDates.length < occurence) {
          debugPrint("added date: ${DateFormat('dd-MM-yyyy').format(curDate)}");
          _recurringDates.add(curDate);
          if (updateDate != null) {
            curDate = updateDate(curDate);
          }
        }
      }
    }

    // stop when one of the conditions is true
    if (selectedRecPeriod == "day") {
      addDate(
        selectedStartDate,
        updateDate: (date){ return date.add(Duration(days: recCount));}
      );
    } else if (selectedRecPeriod == "week") {
      int selStartWeekday = selectedStartDate.weekday;
      int i = 0;
      int nextWeekday = selectedWeekdays.elementAt(i);
      DateTime startDate = selectedStartDate.add(
        Duration(days: (7 + nextWeekday - selStartWeekday)%7)
      );
      addDate(
        startDate, 
        updateDate: (date) {
          i = (i + 1)%selectedWeekdays.length;
          int nextWeekday = selectedWeekdays.elementAt(i);
          int curWeekday = date.weekday;
          int nextDayInterval = (nextWeekday == curWeekday ? 7 : (7 + nextWeekday - curWeekday)%7) + (i == 0 && recCount > 1? (recCount - 1) * 7 : 0);
          debugPrint('next weekday: $nextWeekday, interval: $nextDayInterval');
          return date.add(
            Duration(days: nextDayInterval)
          );
        });
    } else if (selectedRecPeriod == "month") {
      if (startMonthType == RecCostStartMonthType.dateNum) {
        addDate(
          DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDateNum
          ),
          updateDate: (date) => DateTime(date.year, date.month + recCount, date.day)
        );
      } else {
        // find first date to start
        int weekNum = startMonthWeekNum.indexOf(selectedStartWeekNum) + 1;
        int weekday = weekdays.indexOf(selectedStartWeekday) + 1;
        int startMonth = selectedStartDate.month;
        int day = 1;
        // if weeknum and weekday of current is larger then skip
        if (selectedStartDate.numberOfWeek > weekNum) {
          startMonth += 1;
        } else {
          int firstOfMonthWeekday = DateTime(selectedStartDate.year, selectedStartDate.month, 1).weekday;
          day = 1 + (7 + weekday - firstOfMonthWeekday)%7; 
        }
        addDate(
          DateTime(
            selectedStartDate.year,
            startMonth,
            day
          ),
          updateDate: (date) {
            startMonth += 1;
            int firstOfMonthWeekday = DateTime(selectedStartDate.year, startMonth, 1).weekday;
            int day = 1 + (7 + weekday - firstOfMonthWeekday)%7; 
            return DateTime(date.year, startMonth, day);
          }
        );
      }
    }

    debugPrint("total item to add: ${_recurringDates.length}");
    debugPrint("controller text: ${recCountController.text}");
  }


  DropdownMenu customDropDown(
    List<dynamic> dropdownMenuEntries, 
    {
      String? labelPrefix, 
      String? labelSuffix, 
      void Function(dynamic)? onSelected, 
      bool enabled = true, 
      dynamic initialSelection
    }) {
    return DropdownMenu(
      enabled: enabled,
      initialSelection: initialSelection,
      menuHeight: MediaQuery.of(context).size.height * 0.5,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(),
        constraints: BoxConstraints(maxHeight: 44),
        visualDensity: VisualDensity(vertical: -4, horizontal: 0),
        isDense: true
      ),
      onSelected: onSelected,
      dropdownMenuEntries: dropdownMenuEntries.map((e) => DropdownMenuEntry(
        value: e,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity(vertical: -3), 
          textStyle: Theme.of(context).textTheme.bodyMedium
        ), 
        label: '${labelPrefix?? ""}${e.toString()}${labelSuffix ?? ""}'
      )).toList()
    );
  }

  TextFormField customTextField({
    TextAlign textAlign = TextAlign.start, 
    TextEditingController? controller,
    String? initialValue, 
    void Function()? onTap, 
    void Function(String)? onChanged, 
    bool readOnly = false, 
    bool enabled = true, 
    TextInputType? keyboardType, 
    Widget? suffixIcon,
    String? hintText
  }) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      initialValue: initialValue,
      style: Theme.of(context).textTheme.bodyMedium,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        suffixIcon: suffixIcon,
        constraints: BoxConstraints(maxHeight: 50),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white.withAlpha(100)),
      ),
      textAlign: textAlign,
    );
  }

  List<DateTime> _recurringDates = [];
  int selectedRecCount = 1;
  String selectedRecPeriod = "day";
  String selectedStartWeekNum = "First";
  int selectedStartDateNum = 1;
  String selectedStartWeekday = "Monday";
  Set<int> selectedWeekdays = SplayTreeSet();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate =  DateTime.now().add(Duration(days: 5));
  int selectedEndOccurance = 5;
  RecCostStartMonthType startMonthType = RecCostStartMonthType.dateNum;
  RecCostEndType endType = RecCostEndType.date;
  
  TextEditingController recCountController = TextEditingController(text: "1");
  TextEditingController occurenceController = TextEditingController(text: "5");
  late TextEditingController _startController;
  late TextEditingController _endController;
  CostItem? _selectedCostItem;

  final List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final List<String> recurringPeriod = ["day", "week", "month"];
  final List<String> startMonthWeekNum = ["1st", "2nd", "3rd", "4th", "5th", "Last"];

  @override
  void initState() {
    super.initState();
    selectedStartWeekday = weekdays[DateTime.now().weekday - 1];
    selectedStartDateNum = DateTime.now().day;
    selectedStartWeekNum = startMonthWeekNum[DateTime.now().numberOfWeek - 1];

    _startController = TextEditingController(text:selectedStartDate.formatFull());
    _endController = TextEditingController(text:selectedEndDate.formatFull());
    _selectedCostItem = context.read<AppModel>().tempRecCostItem;
    // debugPrint('weekNum value: ${selectedStartWeekNum.toString()}');
  }
  @override
  Widget build(BuildContext context) {
    var bodyMedium2 = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Cost"),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AppModel>().removeTempCostItem();
            // context.read<NavigationModel>().popFormToMain();
            // if (arg.oriRoute != null) {
            //   Navigator.of(context).pushNamed("/recurring");
            // }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,0),
          child: ListView(
            children: [
              CustomSettingsTile(
                title: "Cost item",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  spacing: 10,
                  children: [
                    Flexible(
                      flex: 1, 
                      child: customTextField(
                        hintText: "Cost Type...", 
                        enabled: false,
                        initialValue: _selectedCostItem?.category
                      ),
                    ),
                    Flexible(
                      flex: 1, 
                      child: customTextField(
                        hintText: "Amount...",
                        enabled: false,
                        initialValue: _selectedCostItem?.amount != null ? context.read<AppModel>().customCurrencyFormat(_selectedCostItem!.amount, false) : ""
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Flex(
                  direction: Axis.horizontal, 
                  children: [
                    Flexible(
                      flex: 1, 
                      child: customTextField(
                        hintText: "Description...",
                        enabled: false,
                        initialValue: _selectedCostItem?.name
                      ),
                    )
                  ]
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [TextButton(onPressed: () {
                  context.read<NavigationModel>().openForm(FormArgument(oriRoute: "/recurring"));
                }, child: Text("Select"),)],
              ),
              Divider(),
              tile(
                title: Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 48,
                      child: const Text("Every")
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.12,
                      // fit: FlexFit.tight,
                      // flex: 1,
                      child: customTextField(
                        controller: recCountController,
                        textAlign: TextAlign.center,
                        // initialValue: selectedRecCount.toString(),
                        keyboardType: TextInputType.number,
                      )
                    ),
                    Expanded(
                      flex: 5,
                      child: customDropDown(
                        recurringPeriod,
                        initialSelection: selectedRecPeriod,
                        onSelected: (value) {
                          setState(() => selectedRecPeriod = value ?? 'day');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedRecPeriod == "week") tile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // spacing: 20,
                  children: weekdays.asMap().map((index, e) {
                    final bool selected = selectedWeekdays.contains(index + 1);
                    return MapEntry(index + 1,
                      ActionChip(
                        shape: CircleBorder(),
                        label: Text(
                          e[0],
                          style: TextStyle(color: selected? Colors.black: Colors.white),
                        ),
                        backgroundColor: Colors.white.withAlpha(selected? 160: 10),
                        side: BorderSide(color: Colors.grey),
                        onPressed: () {
                          debugPrint('selected: ${index+1}');
                          setState(() {
                            if (selected) {
                              selectedWeekdays.remove(index + 1);
                            } else {
                              selectedWeekdays.add(index + 1);
                            }
                          });
                        },
                      )
                    );
                  }).values.toList(),
                )
              ), 
              if (selectedRecPeriod == "month") RadioGroup(
                onChanged: (value) { if (value != null) setState(() => startMonthType = value);} ,
                groupValue: startMonthType,
                child: Column(
                  children: [
                    tile(
                      leading: Radio(value: RecCostStartMonthType.dateNum, visualDensity: VisualDensity(horizontal: -4),),
                      title: Row(
                        spacing: 10,
                        children: [
                          const SizedBox( width: 4,),
                          customDropDown(
                            List.generate(31, (i) => i + 1),
                            initialSelection: selectedStartDateNum,
                            labelPrefix: "Day ",
                            onSelected: (value) => {setState(() {
                              selectedStartDateNum = value;
                            })},
                            enabled: startMonthType == RecCostStartMonthType.dateNum
                          ),
                        ]
                      )
                    ),
                    tile(
                      leading: Radio(value: RecCostStartMonthType.weekNum, visualDensity: VisualDensity(horizontal: -4),),
                      title: Row(
                        spacing: 10,
                        children: [
                          const SizedBox( width: 4,),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: customDropDown(
                              startMonthWeekNum,
                              initialSelection: selectedStartWeekNum,
                              // labelSuffix: ,
                              onSelected: (value) {},
                              enabled: startMonthType == RecCostStartMonthType.weekNum
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 2,
                            child: customDropDown(
                              initialSelection: selectedStartWeekday,
                              weekdays,
                              onSelected: (value) {},
                              enabled: startMonthType == RecCostStartMonthType.weekNum
                            ),
                          )
                        ]
                      )
                    ), 
                  ],
                ),
              ), 
              // Divider(),
              tile(
                title: Row(
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: 48,
                      child: const Text("From")
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 5,
                      child: customTextField(
                        controller: _startController,
                        readOnly: true,
                        suffixIcon: Icon(Icons.date_range),
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context, 
                            currentDate: selectedStartDate,
                            firstDate: DateTime(2010), 
                            lastDate: DateTime(2030),
                          );
                          if (newDate != null) {
                            setState(() => selectedStartDate = newDate); 
                            _startController.value = _startController.value.copyWith(text: selectedStartDate.formatFull());
                          }
                        },
                      )
                    ),
                  ],
                ),
              ),
              // Divider(),
              tile(
                title: const Text('Until:'),
              ),
              RadioGroup(
                onChanged: (value) {
                  if (value != null) setState(() => endType = value);
                },
                groupValue: endType,
                child: Column(
                  children: [
                    tile(
                      leading: Radio(value: RecCostEndType.date, visualDensity: VisualDensity(horizontal: -4),),
                      title: Row(
                        spacing: 10,
                        children: [
                          const SizedBox(width: 4),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 5,
                            child: customTextField(
                              controller: _endController,
                              readOnly: true,
                              suffixIcon: Icon(Icons.date_range),
                              onTap: () async {
                                DateTime? newDate = await showDatePicker(
                                  context: context, 
                                  currentDate: selectedEndDate,
                                  firstDate: selectedStartDate, 
                                  lastDate: DateTime(2030),
                                );
                                if (newDate != null) {
                                  setState(() => selectedEndDate = newDate); 
                                  _endController.value = _endController.value.copyWith(text: selectedEndDate.formatFull());
                                }
                              },
                            )
                          ),
                        ],
                      ),
                    ),
                    tile(
                      leading: Radio(value: RecCostEndType.occurence, visualDensity: VisualDensity(horizontal: -4)),
                      title: Row(
                        spacing: 10,
                        children: [
                          const SizedBox(width: 4),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.08,
                            child: const Text("After")
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            child: customTextField(
                              controller: occurenceController,
                              keyboardType: TextInputType.number,
                              enabled: endType == RecCostEndType.occurence,
                              readOnly: endType != RecCostEndType.occurence,
                              textAlign: TextAlign.center,
                            )
                          ),
                          SizedBox(
                            child: const Text("occurences")
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: () { 
                      Navigator.of(context).pop();
                      context.read<AppModel>().removeTempCostItem();
                    }, 
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey
                    ),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      List<String> errorMsg = [];
                      Flushbar customBar({String? msg}) {
                        return Flushbar(
                          animationDuration: Duration(milliseconds: 500),
                          flushbarPosition: FlushbarPosition.TOP,
                          flushbarStyle: FlushbarStyle.GROUNDED,
                          title: "Error creating recurring cost",
                          message: msg,
                          duration: Duration(seconds: 3),
                        );
                      }
                      if (_selectedCostItem == null) {
                        errorMsg.add("No cost item is selected.");
                      }
                      if (recCountController.text == "0") {
                        errorMsg.add("Cannot create a 0 day interval with an end date. Please select occurence if you wish to create multiple copies within the same day.");
                      } else if (recCountController.text == "") {
                        errorMsg.add("Please enter a value for recurring amount.");
                      } 
                      if (occurenceController.text == "" && endType == RecCostEndType.occurence) {
                        errorMsg.add("Please enter a value for occurence amount.");
                      } 

                      if (errorMsg.isNotEmpty) {
                        await customBar(msg: errorMsg.join("\n")).show(context);
                      } else {
                        createRecurringCost();
                        showDialog(
                          context: context, 
                          builder:(context) {
                            return AlertDialog(
                              title: Text("Create recurring cost"),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('This action will create ${_recurringDates.length} copies of the cost item on the follwoing date:\n'),
                                    ..._recurringDates.map((e) => Text(e.formatFull())),
                                    Text('\nNote that once the copies are created, you can only delete them one by one. Batch delete is not possible.'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                                TextButton(onPressed: () {
                                  // context.read<AppModel>().saveCostItemFromTemp(_recurringDates);
                                  context.read<AppModel>().removeTempCostItem();
                                  Navigator.pop(context);
                                  context.read<NavigationModel>().navigateMainScreen(0);
                                }, child: const Text("Save"))
                              ],
                            );
                          },
                        ); 
                      }
                    }, 
                    child: const Text("Save")
                  ),
                ],
              )
              // CustomSettingsTile(title: "Every", leading: Text("Until"),),
            ],
          ),
        )
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.textAlign = TextAlign.start, 
    this.controller,
    this.initialValue, 
    this.onTap, 
    this.onChanged, 
    this.prefix, 
    this.readOnly = false, 
    this.enabled = true, 
    this.keyboardType, 
    this.suffixIcon,
    this.hintText
  });

  final TextAlign textAlign; 
  final TextEditingController? controller;
  final String? initialValue; 
  final void Function()? onTap; 
  final void Function(String)? onChanged; 
  final bool readOnly; 
  final Widget? prefix; 
  final bool enabled; 
  final TextInputType? keyboardType; 
  final Widget? suffixIcon;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      initialValue: initialValue,
      style: Theme.of(context).textTheme.bodyMedium,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefix: prefix,
        border: OutlineInputBorder(),
        isDense: true,
        suffixIcon: suffixIcon,
        constraints: BoxConstraints(maxHeight: 50),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white.withAlpha(100)),
      ),
      textAlign: textAlign,
    );
  }
}

class CustomDropDownMenu extends StatelessWidget {
  const CustomDropDownMenu({
    super.key,
    this.dropdownMenuEntries, 
    this.dropdownMenuEntriesOverride, 
    this.labelPrefix, 
    this.labelSuffix, 
    this.onSelected, 
    this.enabled = true, 
    this.initialSelection,
  });

  final List<dynamic>? dropdownMenuEntries; 
  final List<DropdownMenuEntry>? dropdownMenuEntriesOverride; 
  final String? labelPrefix; 
  final String? labelSuffix; 
  final void Function(dynamic)? onSelected; 
  final bool enabled; 
  final dynamic initialSelection;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry> entries;
    if (dropdownMenuEntriesOverride != null) {
      entries = dropdownMenuEntriesOverride!;
    } else {
      entries = (dropdownMenuEntries ?? []).map((e) => DropdownMenuEntry(
        value: e,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity(vertical: -3), 
          textStyle: Theme.of(context).textTheme.bodyMedium
        ), 
        label: '${labelPrefix?? ""}${e.toString()}${labelSuffix ?? ""}'
      )).toList();
    }
    return DropdownMenu(
      // width: ,
      expandedInsets: EdgeInsets.zero, 
      enabled: enabled,
      // menuStyle: MenuStyle(),
      initialSelection: initialSelection,
      menuHeight: MediaQuery.of(context).size.height * 0.5,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(),
        constraints: BoxConstraints(maxHeight: 44),
        visualDensity: VisualDensity(vertical: -4, horizontal: 0),
        isDense: true
      ),
      onSelected: onSelected,
      dropdownMenuEntries: entries
    );
  }
}