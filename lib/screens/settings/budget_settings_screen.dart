import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/recurring_settings_screen.dart';
import 'package:budget_tracker/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                CustomSettingsTile(title:"Set Overall Budget"),
                ReorderableListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  onReorder: (oldIndex, newIndex) {
                    debugPrint("reordered!");
                  },
                  children: budgets.map((e) {
                    return CustomSettingsTile(
                      // final String title = 
                      key: ValueKey(e.id!),
                      title:e.name?.toString(),
                      subtitle: Text('${e.amount ?? ""} | ${e.appliedType == BudgetApplyMonth.all ? "Every month": "Specific month"} | ${e.categories!.isEmpty ? "All categories" : "${e.categories!.length} categories"}'),
                      trailingWidget: Switch(
                        value: e.enabled ?? false, 
                        onChanged: (value) {
                          // context.read<AppModel>().updateBudget(e.id ?? "", (budget) => 
                          //   budget.enabled = value
                          // );
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
      title: "Add new category budget", 
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
        deleteButton(onPressed: () {
          context.read<AppModel>().deleteBudget(selectedBudget!.id!);
          Navigator.pop(context);
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

    if (widget.curBudget != null) {
      _nameController = TextEditingController(text: widget.curBudget!.name?? "");
      _fixedAmountController = TextEditingController(text: widget.curBudget!.amount.toString());
      _percentageAmountController = TextEditingController(text: widget.curBudget!.amount.toString());
      _budgetEnabled = widget.curBudget!.enabled ?? true;
      _selectedPriority = widget.curBudget!.priority ?? 1;
      _selectedCategory = context.read<AppModel>().categories.asMap().map((index, category) => MapEntry(
        category.name,
        false
      ));
      for (String category in widget.curBudget!.categories!) {
        _selectedCategory[category] = true;
      }
      if (widget.curBudget!.appliedType == BudgetApplyMonth.specific) {
        _selectedYear = widget.curBudget!.months!.first.year;
      }
    } else {
      _selectedCategory = context.read<AppModel>().categories.asMap().map((index, category) => MapEntry(
        category.name,
        true
      ));
      _nameController = TextEditingController(text: "New Budget 1");
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
      categories: selectedCatList
    );
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
          if (widget.curBudget == null) TextButton(
            onPressed: () {
              appModelRead.createBudget(generateBudget());
              Navigator.pop(context);
            }, 
            child: const Text("Create")
          ),
          if (widget.curBudget != null) CustomDeleteButton(
            onPressed: () {
              appModelRead.deleteBudget(widget.curBudget!.id!);
              Navigator.pop(context);
            }, 
          ),
          if (widget.curBudget != null) TextButton(
            onPressed: () {
              appModelRead.updateBudget(widget.curBudget!.id!,generateBudget());
              Navigator.pop(context);
            }, 
            child: const Text("Save")
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
                        dropdownMenuEntries: budgets.isEmpty ? [1] : List.generate(budgets.length + 1, (e) => e),
                        initialSelection: 1,
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
                leading: e.createIcon(24, context.read<ThemeModel>().theme),
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
                      setState(() => _selectedCategory[e.name] = value);
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
                  // debugPrint('selected Month count: ${_selectedMonths.length}');
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