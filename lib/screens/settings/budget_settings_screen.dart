import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/recurring_settings_screen.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

enum BudgetApplyMonth {all, specific}
enum BudgetAmount {percentage, fixed}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final contextRead = context.read<AppModel>();
    final budgets = context.watch<AppModel>().budgets;
    // final budgets = context.select((AppModel state) => state.budgets);
    debugPrint("list view rebuilt");
    return Scaffold(
      appBar: AppBar(
        title: Text("Budgets"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CustomSettingsTile(title:"Set Overall Budget"),
                ReorderableListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  onReorder: (oldIndex, newIndex) {
                    debugPrint("reordered!");
                  },
                  children: budgets.map((e) {
                    final String budgetAmountString = contextRead.customCurrencyFormat(e.amount ?? 0, true);
                    final String categoryString = e.categories!.isEmpty ? 
                      "All categories" : 
                      e.categories!.length == 1?
                        e.categories!.first :
                        "${e.categories!.length} categories";
                    return CustomSettingsTile(
                      // final String title = 
                      key: ValueKey(e.id!),
                      title:e.name?.toString(),
                      subtitle: Text('$budgetAmountString | ${e.appliedType == BudgetApplyMonth.all ? "Every month": "Specific month"} | $categoryString'),
                      trailingWidget: Switch(
                        value: e.enabled ?? false, 
                        onChanged: (value) {
                          // context.read<AppModel>().deleteBudget(e.id!);
                        }
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context) => BudgetEditScreen(curBudget: e,),));
                        // await showDialog(
                        //   context: context, 
                        //   builder: (context) => TotalBudgetDialog(budgetId: e.id,),
                        // );
                      },
                    );
                  }).toList(),
                ),
                // const TotalBudgetSettingsTile(),
                // CustomSettingsTile(title:"Set budget for category"),
                Divider(),
                CategoryBudgetSettingsTile(),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class CategoryBudgetSettingsTile extends StatelessWidget {
  const CategoryBudgetSettingsTile({
    super.key,
  });

  // final categories = context.read<AppModel>().categories;
  @override
  Widget build(BuildContext context) {
    final categories = context.read<AppModel>().categories;
    return CustomSettingsTile(
      title: "Add new budget", 
      leading: Icon(Icons.add), 
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder:(context) => const BudgetEditScreen(),));
      }, 
    );
  }
}

class TotalBudgetDialog extends StatefulWidget {
  const TotalBudgetDialog({
    super.key,
    this.budgetId
  });

  final String? budgetId;

  @override
  State<TotalBudgetDialog> createState() => _TotalBudgetDialogState();
}

class _TotalBudgetDialogState extends State<TotalBudgetDialog> {
  Budget? selectedBudget;
  @override
  void initState() {
    super.initState();
    if (widget.budgetId != null) {
      selectedBudget = context.read<AppModel>().budgets.firstWhere((e) => e.id == widget.budgetId);
    }
  }
  
  ListTile tile({String? title, Widget? trailing}) {
    return ListTile(
      title: Text(title ?? ""),
      trailing: trailing,
      contentPadding: EdgeInsets.all(0),
    );
  }

  Widget deleteButton({void Function()? onPressed}) {
    if (widget.budgetId != null) {
      return TextButton(
        onPressed: onPressed, 
        child: Text('Delete', style: TextStyle(color: Colors.red),)
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: ListTile(
        contentPadding: EdgeInsets.all(0),
        // tileColor: Colors.red,
        title: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            labelText: "Budget Name", 
            visualDensity: VisualDensity.compact,
            border: OutlineInputBorder( borderSide: BorderSide.none, gapPadding: 0),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          initialValue: selectedBudget?.name?? "New Budget",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20),
        ),
        trailing: Switch(onChanged: (value) {}, value: true),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          // Text("Create a total budget, specify amount and details."),
          // SizedBox(height: 10,),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: selectedBudget?.amount.toString(),
            decoration: InputDecoration(
              labelText: "Amount", 
              hintText: '0.00',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 30),
          ),
          SizedBox(height: 10,),
          // TextFormField(
          //   decoration: InputDecoration(
          //     labelText: "Budget Name", 
          //     floatingLabelBehavior: FloatingLabelBehavior.always,
          //   ),
          //   initialValue: selectedBudget?.name?? "Budget 1",
          //   style: Theme.of(context).textTheme.bodyMedium,
          // ),
          SizedBox(height: 10,),
          // ListTile(title: Text("Enabled"), trailing: Switch(onChanged: (value) {}, value: true),contentPadding: EdgeInsets.only(top: 12, left: 0, right: 0),),
          // Divider(),
          RadioGroup(
            onChanged: (value) {
              // if (value == 
            }, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                tile(title: "Every month", trailing: Radio(value: 1,)),
                tile(
                  title: "Specific month", 
                  trailing: Radio(value: 2,)
                ),
              ],
            )
          ),
          // Divider(),
          // tile(title: "Fixed Amount", trailing: Radio(value: 2,)),
          // tile(title: "Percentage income", trailing: Radio(value: 1,),),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // context.read<AppModel>().createBudget(
            //   Budget(
            //     name: 'damn',
            //     amount: 1,
            //     enabled: true,
            //     type: 'every',
            //     month: 'all'
            //   )
            // );
            Navigator.pop(context);
          }, 
          child: Text('Save')),
        deleteButton(onPressed: () async {
          await showDialog(
            context: context, 
            builder:(context) => ConfirmDeleteDialog(
              title: "Delete budget",
              content: Text('Do you want to delete the budget. Warning: You cannot undo this action.'),
              onDeletePressed: () {
                context.read<AppModel>().deleteBudget(selectedBudget!.id!);
                Navigator.pop(context);
              },
            ),
          );
        })
      ],
    );
  }
}

class TotalBudgetSettingsTile extends StatelessWidget {
  const TotalBudgetSettingsTile({
    super.key,
  });

  ListTile tile({String? title, Widget? trailing}) {
    return ListTile(
      title: Text(title ?? ""),
      trailing: trailing,
      contentPadding: EdgeInsets.all(0),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomSettingsTile(
      title: "Add new total budget", 
      leading: Icon(Icons.add), 
      onTap: () => showDialog(
        context: context, 
        builder: (context) => const TotalBudgetDialog(),
      )
    );
  }
}

class BudgetEditScreen extends StatefulWidget {
  const BudgetEditScreen({
    super.key,
    this.curBudget
  });

  final Budget? curBudget;

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  BudgetAmount _calType = BudgetAmount.fixed;
  BudgetApplyMonth _budgetMonth = BudgetApplyMonth.all;
  Map<String, bool> _selectedCategory = {};
  int _selectedPriority = 1;
  bool _budgetEnabled = true;
  // int _selectedMonth = 1;
  int _selectedYear = 2025;

  late TextEditingController _nameController;
  late TextEditingController _fixedAmountController;
  late TextEditingController _percentageAmountController;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  String _selectedPeriod = "month";
  List<int> _selectedMonths = [];
  
  @override 
  void initState() {
    super.initState();

    final contextRead = context.read<AppModel>();
    final expenseCategories = contextRead.categories.where((e) => e.costType == CostType.expense).toList();
    if (widget.curBudget != null) {
      _nameController = TextEditingController(text: widget.curBudget!.name?? "");
      _fixedAmountController = TextEditingController(text: widget.curBudget!.amount.toString());
      _percentageAmountController = TextEditingController(text: widget.curBudget!.amount.toString());
      _budgetEnabled = widget.curBudget!.enabled ?? true;
      _selectedPriority = widget.curBudget!.priority ?? 1;
      if (widget.curBudget!.categories!.isEmpty) {
        _selectedCategory = expenseCategories.asMap().map((index, category) => MapEntry(
          category.name!,
          true
        ));
      } else {
        _selectedCategory = expenseCategories.asMap().map((index, category) => MapEntry(
          category.name!,
          false
        ));
        for (String category in widget.curBudget!.categories!) {
          _selectedCategory[category] = true;
        }
      }
      if (widget.curBudget!.appliedType == BudgetApplyMonth.specific) {
        _selectedYear = widget.curBudget!.months!.first.year;
        _selectedMonths = widget.curBudget!.months!.map((e)=> e.month).toList();
      } else {
        _selectedMonths.add(DateTime.now().month);
        _selectedYear = DateTime.now().year;
      }
    } else {
      _selectedCategory = expenseCategories.asMap().map((index, category) => MapEntry(
        category.name!,
        true
      ));
      _selectedPriority = contextRead.budgets.length + 1;
      _nameController = TextEditingController(text: "Budget ${contextRead.budgets.length + 1}");
      _fixedAmountController = TextEditingController(text: "0");
      _percentageAmountController = TextEditingController(text: "0");
      _selectedMonths.add(DateTime.now().month);
      _selectedYear = DateTime.now().year;
    }
  }

  void updateApplyMonth(BudgetApplyMonth monthValue) {
    setState(() => _budgetMonth = monthValue);
  }

  Budget generateBudget() {
    List<String> selectedCatList = [];
    if (_selectedCategory.containsValue(false)) {
      selectedCatList = Map.fromEntries(_selectedCategory.entries.where((e) => e.value)).keys.toList(); 
    }
    return Budget(
      name: _nameController.text,
      enabled: _budgetEnabled,
      amountCalType: _calType,
      appliedType: _budgetMonth,
      amount: _calType == BudgetAmount.fixed ? double.parse(_fixedAmountController.text): double.parse(_percentageAmountController.text),
      priority: _selectedPriority,
      months: _budgetMonth == BudgetApplyMonth.specific ? _selectedMonths.map((month) => DateFormat('yyyy-M').parse('$_selectedYear-$month')).toList() : [],
      categories: selectedCatList
    );
  }

  Future<bool> validateBudget(bool isUpdate) async {
    List<String> msg = [];
    bool isValid = true;
    if (!_selectedCategory.containsValue(true)) {
      msg.add('CATEGORY: Please select at least one category.');
      isValid = false;
    }
    if (_budgetMonth == BudgetApplyMonth.specific && _selectedMonths.isEmpty) {
      msg.add('SPECIFIC MONTH: Please select at least one month.');
      isValid = false;
    }
    if (_calType == BudgetAmount.fixed && (double.tryParse(_fixedAmountController.text) == 0 || double.tryParse(_fixedAmountController.text) == null || _fixedAmountController.text == "")) {
      msg.add('FIXED: Please select a number larger than 0.');
      isValid = false;
    } else if (_calType == BudgetAmount.percentage && (double.tryParse(_percentageAmountController.text) == 0 || double.tryParse(_percentageAmountController.text) == null || _percentageAmountController.text == "")) {
      msg.add('PERCENTAGE: Please select a number larger than 0.');
      isValid = false;
    }
    if (!isValid) {
      await Flushbar(
        animationDuration: Duration(milliseconds: 300),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.GROUNDED,
        duration: Duration(seconds: 4),
        title: "Error ${isUpdate? "updating": "creating"} budget!",
        message: msg.join("\n"),
      ).show(context);
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final appModelRead = context.read<AppModel>();
    final budgets = appModelRead.budgets;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Budgets"),
        actions: [
          if (widget.curBudget != null) CustomDeleteButton(
            onPressed: () async {
              await showDialog(
                context: context, 
                builder:(context) => ConfirmDeleteDialog(
                  title: "Delete budget",
                  content: Text('Do you want to delete the budget?\nWarning: You cannot undo this action.'),
                  onDeletePressed: () {
                    context.read<AppModel>().deleteBudget(widget.curBudget!.id!);
                    Navigator.pop(context);
                  },
                ),
              );
            }, 
          ),
          TextButton(
            onPressed: () async {
              final bool isValid = await validateBudget(widget.curBudget != null);
              if (isValid) {
                if (widget.curBudget == null) {
                  appModelRead.createBudget(generateBudget());
                } else {
                  appModelRead.updateBudget(widget.curBudget!.id!, generateBudget());
                }
                Navigator.pop(context);
              }  
            }, 
            child: Text(widget.curBudget == null ? "Create" : "Save")
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,0),
          child: ListView(
            children: [
              // CustomSettingsTile(
              //   title:"Enabled",
              //   trailingWidget: Switch(
              //     value: true, 
              //     onChanged: (value) {}
              //     ),
              //   ),
              CustomSettingsTile(
                title:"Budget Overview",
                verticalPadding: 4,
                // trailingWidget: Transform.scale(
                //   scale: 0.9,
                //   alignment: Alignment.centerRight,
                //   child: Switch(
                //     value: true, 
                //     onChanged: (value) {}
                //   ),
                // ),
              ),
              CustomSettingsTile(
                // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                titleWidget: Flex(
                  direction: Axis.horizontal,
                  spacing: 10,
                  children: [
                    Text("Name"),
                    Flexible(
                      child: CustomTextFormField(
                        controller: _nameController,
                      ),
                    ),
                  ],
                ),
              ),
              // CustomSettingsTile(
              //   titleWidget: Text("Enabled"),
              //   trailingWidget: Transform.scale(
              //     scale: 0.9,
              //     alignment: Alignment.centerRight,
              //     child: Switch(
              //       value: true, 
              //       onChanged: (value) {}
              //     ),
              //   ),
              // ),
              CustomSettingsTile(
                titleWidget: Flex(
                  spacing: 10,
                  direction: Axis.horizontal,
                  children: [
                    Text("Enabled"),
                    Transform.scale(
                      scale: 0.9,
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: _budgetEnabled, 
                        onChanged: (value) {
                          setState(() => _budgetEnabled = value);
                        }
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text("Priority"),
                    Flexible(
                      fit: FlexFit.tight,
                      child: CustomDropDownMenu(
                        dropdownMenuEntries: budgets.isEmpty ? 
                          [1] : 
                          List.generate(budgets.length + (widget.curBudget == null? 1 : 0), (e) => e + 1),
                        initialSelection: _selectedPriority,
                        onSelected: (value) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                      ),
                    )
                  ],
                )
              ),
              Divider(),
              CustomSettingsTile(title: "Amount"),
              RadioGroup(
                onChanged: (value) { 
                  if (value != null)  {
                    setState(() => _calType = value);
                  } 
                }, 
                groupValue: _calType,
                child: Column(
                  children: [
                    CustomSettingsTile(
                      // title: , 
                      leading: Radio(value: BudgetAmount.fixed),
                      titleWidget: Flex(
                        spacing: 10,
                        direction: Axis.horizontal,
                        children: [
                          Text("Fixed"),
                          Flexible(
                            child: CustomTextFormField(
                              prefix: Text(appModelRead.currencySymbol),
                              textAlign: TextAlign.end,
                              controller: _fixedAmountController,
                              keyboardType: TextInputType.number,
                              enabled: _calType == BudgetAmount.fixed,
                            ),
                          )
                          ],
                      ),
                    ),
                    CustomSettingsTile(
                      // title: "% income", 
                      leading: Radio(value: BudgetAmount.percentage),
                      titleWidget: Flex(
                        direction: Axis.horizontal,
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Percentage"),
                          Flexible(
                            flex: 1,
                            child: CustomTextFormField(
                              controller: _percentageAmountController,
                              keyboardType: TextInputType.number,
                              enabled: _calType == BudgetAmount.percentage,
                            ),
                          ),
                          Text("%"),
                          Flexible(
                            flex: 4,
                            child: CustomDropDownMenu(
                              enabled: _calType == BudgetAmount.percentage,
                              initialSelection: CostType.income,
                              dropdownMenuEntriesOverride: CostType.values.map((e) => DropdownMenuEntry(
                                value: e, 
                                label: e.name
                              )).toList()
                            )
                          )
                        ]
                      ),
                    ),
                  ],
                )
              ),
              
              Divider(),
              CustomSettingsTile(title: "Apply to",),
              RadioGroup(
                onChanged: (value) { 
                  if (value != null)  {
                    updateApplyMonth(value);
                  }
                }, 
                groupValue: _budgetMonth,
                child: Column(
                  children: [
                    CustomSettingsTile(
                      onTap: () => updateApplyMonth(BudgetApplyMonth.all),
                      leading: Radio(value: BudgetApplyMonth.all),
                      titleWidget: Flex(
                        direction: Axis.vertical,
                        children: [
                          Flex(
                            spacing: 10,
                            direction: Axis.horizontal,
                            children: [
                              Text("Every"),
                              Flexible(
                                child: CustomDropDownMenu(
                                  dropdownMenuEntries: ["month", "year"],
                                  enabled: _budgetMonth == BudgetApplyMonth.all,
                                  initialSelection: _selectedPeriod,
                                  onSelected: (value) {
                                    setState(() => _selectedPeriod = value);
                                  },
                                )
                              )
                            ],
                          ),
                        ]
                      )
                    ),
                    if (_selectedPeriod == "year" && _budgetMonth == BudgetApplyMonth.all) monthSelectWrap(context),
                    CustomSettingsTile(
                      onTap: () => updateApplyMonth(BudgetApplyMonth.specific),
                      leading: Radio(value: BudgetApplyMonth.specific),
                      titleWidget: Text("Specific month(s)"),
                    ),
                    if (_budgetMonth == BudgetApplyMonth.specific) CustomSettingsTile(
                      // horizontalPadding: 30,
                      titleWidget: Flex(
                        spacing: 20,
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("Year"),
                          ),
                          Flexible(
                            child: CustomDropDownMenu(
                              dropdownMenuEntries: [2022,2023,2024, 2025],
                              initialSelection: _selectedYear,
                            )),
                        ],
                      ),
                    ),
                    if (_budgetMonth == BudgetApplyMonth.specific) monthSelectWrap(context),
                    // if (_budgetMonth == BudgetApplyMonth.specific) CustomSettingsTile(
                    //   leading: Icon(Icons.add),
                    //   title: "Add Month",
                    // )
                  ],
                )
              ),
              Divider(),
              // Tooltip(
              //   message: "Specify which category is included in the budget",
              // ),
              CustomSettingsTile(
                title: "Category",
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Specify which category to be included in the budget."),
                ),
              ),
              CustomSettingsTile(
                title: "All",
                trailingWidget: Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: !_selectedCategory.values.contains(false), 
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory.updateAll((k,v) => v = value!));
                      }
                    }
                  ),
                ),
              ),
              ...appModelRead.categories.where((e) => e.costType == CostType.expense).map((e) => CustomSettingsTile(
                verticalPadding: 2,
                title: e.name,
                // leading: e.createIcon(24, context.read<ThemeModel>().theme),
                // trailingWidget: Transform.scale(
                //   scale: 0.9,
                //   child: Switch(
                //     value: _selectedCategory[e.name] ?? false, 
                //     onChanged: (value) {
                //       setState(() {
                //         _selectedCategory[e.name] = value;
                //       });
                //     }
                //   ),
                // ),
                trailingWidget: Checkbox(
                  value:  _selectedCategory[e.name] ?? false, 
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory[e.name!] = value);
                    }
                  }
                ),
              ))
            ],
          ),
        )
      ),
    );
  }

  Padding monthSelectWrap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8),
      child: SizedBox(
        width: double.maxFinite,
        child: Wrap(
          runAlignment: WrapAlignment.spaceBetween,
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 4,
          children: _months.asMap().map((index, e) {
            final selected = _selectedMonths.contains(index + 1);
            return MapEntry(
              index, 
              ActionChip(
                shape: CircleBorder(),
                label: Text(
                  e.substring(0,3),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: selected? Colors.black: Colors.grey, fontSize: 14),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(selected? 255: 0),
                side: BorderSide(color: selected? Colors.transparent: Colors.grey),
                onPressed: () {
                  setState(() {
                    selected ? _selectedMonths.remove(index + 1) : _selectedMonths.add(index + 1);
                  });
                  debugPrint('selected months count: ${_selectedMonths.length}');
                },
              )
            );
          }).values.toList(),
        ),
      ),
    );
  }
}

class CustomCancelButton extends StatelessWidget {
  const CustomCancelButton({
    super.key,
    this.buttonText = "Cancel",
    this.onPressed
  });

  final String buttonText;
  final void Function()? onPressed;
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey
      ),
      child: Text(buttonText),
    );
  }
}

class CustomDeleteButton extends StatelessWidget {
  const CustomDeleteButton({
    super.key,
    this.buttonText = "Delete",
    this.onPressed
  });

  final String buttonText;
  final void Function()? onPressed;
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.red
      ),
      child: Text(buttonText),
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({
    super.key,
    this.content,
    this.title,
    this.onDeletePressed,
  });

  final String? title;
  final Widget? content;
  final void Function()? onDeletePressed;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? ""),
      content: content,
      actions: [
        CustomCancelButton(
          onPressed: () => Navigator.pop(context),
        ),
        CustomDeleteButton(
          onPressed: onDeletePressed,
        )
      ],
    );
  }
}