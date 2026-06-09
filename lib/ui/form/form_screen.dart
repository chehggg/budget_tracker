import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/custom/saved_item_class.dart';
import 'package:budget_tracker/models/currency_model.dart';
import 'package:budget_tracker/ui/form/saved_item_screen.dart';
import 'package:budget_tracker/ui/form/form_viewmodel.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/custom/saved_item_option_enum.dart';
import 'package:budget_tracker/ui/form/saved_item_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker/custom/category_class.dart';

// screen for user to input a new cost item
// or edit a existing cost item
class CostItemFormScreen extends StatelessWidget {
  const CostItemFormScreen({
    super.key,
    required this.arg,
  });
  final FormArgument arg;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => FormModel(
            initCostItem: arg.selectedCostItem,
            costItemRepo: context.read(),
            savedItemRepo: context.read(),
            categoryRepo: context.read(),
          ),
      child: CostFormBody(arg: arg),
    );
  }
}

class CostFormBody extends StatelessWidget {
  const CostFormBody({
    super.key,
    required this.arg,
  });

  final FormArgument arg;

  @override
  Widget build(BuildContext context) {
    final ready = context.select((FormModel state) => state.ready);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(arg.selectedCostItem == null ? "NEW ITEM" : "EDIT ITEM"),
        leading: BackButton(
          onPressed: () => context.navMod.popFormToMain(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.formMod.reloadCategory();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      bottomSheet: const FormBottomSheet(),
      body: SafeArea(
        minimum: EdgeInsets.only(top: 12, left: 12, right: 12),
        bottom: false,
        child:
            ready
                ? const CostItemCategoryGrid()
                : Expanded(
                  child: Center(
                    child: const CircularProgressIndicator(),
                  ),
                ),
      ),
      // bottomNavigationBar: bottom,
    );
  }
}

class FormBottomSheet extends StatefulWidget {
  const FormBottomSheet({super.key});

  @override
  State<FormBottomSheet> createState() => _FormBottomSheetState();
}

class _FormBottomSheetState extends State<FormBottomSheet> {
  bool _isFormExpanded = false;
  bool _isFormOpened = false;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _amountController = TextEditingController();
    _descController = TextEditingController();

    if (context.formMod.selectedCategory != null) {
      _selectedDate = context.formMod.date;
      _amountController.value = _amountController.value.copyWith(
        text: context.formMod.amount.toStringAsFixed(context.formMod.amount % 1 == 0 ? 0 : 2),
      );
      _descController.value = _descController.value.copyWith(text: context.formMod.itemDesc);
    }

    _amountController.addListener(
      () => context.formMod.updateAmount(double.tryParse(_amountController.text) ?? 0),
    );
    _descController.addListener(() => context.formMod.updateDesc(_descController.text));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void selectDate() async {
    DateTime now = DateTime.now();
    final response = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      currentDate: _selectedDate,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5, now.month, 1),
      lastDate: DateTime(now.year + 5, now.month, 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: context.cs.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: context.cs.primary.withAlpha(50)),
                borderRadius: BorderRadiusGeometry.circular(30),
              ),
              dayStyle: context.customTt.numberFontSmall,
              weekdayStyle: context.customTt.numberFontSmall,
              yearStyle: context.customTt.numberFontSmall,
              toggleButtonTextStyle: context.customTt.numberFontSmall,
              headerHeadlineStyle: context.customTt.dateLabel!.copyWith(fontSize: 40),
            ),
          ),
          child: child!,
        );
      },
    );
    if (response == null) return;

    setState(() => _selectedDate = response);
    context.formMod.updateDate(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    CostItemCategory? selectedCategory = context.select((FormModel state) {
      if (state.selectedCategory != null) {
        Future.delayed(
          Duration(microseconds: 10),
          () => setState(() {
            if (!_isFormOpened) {
              _isFormOpened = true;
              _isFormExpanded = true;
            }
          }),
        );
      }
      return state.selectedCategory;
    });
    String itemDesc = context.select((FormModel state) => state.itemDesc);
    double amount = context.select((FormModel state) => state.amount);

    if (selectedCategory == null) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy > 10) {
          // swipe down
          setState(() => _isFormExpanded = false);
        }
        if (details.delta.dy < -10) {
          // swipe up
          setState(() => _isFormExpanded = true);
        }
      },
      child: AnimatedContainer(
        duration: Durations.medium1,
        curve: Curves.easeInOutExpo,
        width: context.mq.size.width,
        height:
            !_isFormOpened
                ? 0
                : _isFormExpanded
                ? 510
                : 120,
        decoration: BoxDecoration(
          color: context.cs.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: Durations.medium1,
              curve: Curves.easeInOutExpo,
              height: _isFormExpanded ? 64 : 120,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  AnimatedScale(
                    scale: _isFormExpanded ? 0.7 : 1,
                    duration: Durations.medium1,
                    child: CategoryIconContainer(
                      inContainer: false,
                      inverse: true,
                      size: 40,
                      category: selectedCategory,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            selectedCategory.name!.capitalize(),
                            ...[
                              if (!_isFormExpanded)
                                amount.customCurrencyFormat(
                                  "RM",
                                ),
                            ],
                          ].join(' • '),
                          style: context.customTt.dateLabel!.copyWith(
                            color: context.cs.surface,
                            fontSize: 30,
                            height: 1.2,
                          ),
                        ),
                        if (!_isFormExpanded)
                          Text(
                            [
                              _selectedDate.formatPretty(),
                              itemDesc.isEmpty ? "No Desc" : itemDesc,
                            ].join(' • '),
                            style: context.customTt.numberFontSmall!.copyWith(
                              color: context.cs.surface,
                              fontSize: 12,
                              fontWeight: FontWeight(200),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...(context.formMod.selectedCategory != null)
                      ? [
                        IconButton(
                          onPressed: () async {
                            // final formMod = context.formMod;
                            context.nav.push(
                              MaterialPageRoute(
                                builder:
                                    (buildContext) => ChangeNotifierProvider(
                                      create:
                                          (_) => SavedItemModel(
                                            formData:
                                                context.formMod.initCostItem == null
                                                    ? null
                                                    : context.formMod.formResult,
                                            category: selectedCategory,
                                            savedItemRepository: context.read(),
                                            categoryRepo: context.read(),
                                          ),
                                      // value: context.formMod,
                                      child: const CreateSavedItemScreen(),
                                    ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.favorite,
                            // color: context.cs.error,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final bool? deleteResponse = await showDialog<bool>(
                              context: context,
                              builder: (context) => const DeleteItemDialog(),
                            );
                            if (deleteResponse == true) {
                              context.formMod.deleteItem();
                              Flushbar(
                                duration: Duration(seconds: 2),
                                title: "Bye bye!",
                                message: "Item deleted successfully.",
                              ).show(context);

                              context.navMod.popFormToMain();
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                            color: context.cs.error,
                          ),
                        ),
                      ]
                      : [],
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: context.mq.size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(color: context.cs.surface),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RM",
                            style: context.customTt.numberFontLarge!.copyWith(
                              fontSize: 60,
                              color: context.cs.primary,
                            ),
                          ),
                          Expanded(
                            child:
                                _amountController.text.isEmpty
                                    ? Text(
                                      "0.00",
                                      textAlign: TextAlign.end,
                                      style: context.customTt.numberFontLarge!.copyWith(
                                        fontSize: 60,
                                        color: context.cs.primary.withAlpha(100),
                                      ),
                                    )
                                    : Text(
                                      _amountController.text,
                                      textAlign: TextAlign.end,
                                      style: context.customTt.numberFontLarge!.copyWith(
                                        fontSize: 60,
                                        color: context.cs.primary,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: context.cs.primary.withAlpha(50),
                    ),
                    TextFormField(
                      controller: _descController,
                      style: context.tt.bodyMedium!,
                      minLines: 3,
                      maxLines: 3,
                      decoration: InputDecoration(
                        visualDensity: VisualDensity(vertical: -4),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        hintText: "Write your description here...",
                        hintStyle: context.tt.bodyMedium!.copyWith(
                          color: context.cs.primary.withAlpha(100),
                        ),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                    ),
                    Expanded(
                      child: CustomKeyboard(
                        controller: _amountController,
                        onDone: () {
                          final result = context.formMod.formResult;
                          if (result != null) {
                            context.formMod.submitForm();
                            context.navMod.popFormToMain();
                          }
                        },
                        selectedDate: _selectedDate,
                        onDateTapped: selectDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedItemDialog extends StatefulWidget {
  const SavedItemDialog({
    super.key,
  });

  @override
  State<SavedItemDialog> createState() => _SavedItemDialogState();
}

class _SavedItemDialogState extends State<SavedItemDialog> {
  late final TextEditingController _controller;
  List _options = [];
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => context.formMod.updateSavedItemTitle);
    _options = context.formMod.saveOptions;
  }

  @override
  Widget build(BuildContext context) {
    // final options = context.select((FormModel state) => state.saveOptions);
    return AlertDialog(
      title: Text("Saved Item Name"),
      content: Column(
        children: [
          TextFormField(
            controller: _controller,
          ),
          Text("Preserve value for"),
          ...SavedItemOption.values.map(
            (option) => FilterChip(
              label: Text(option.name),
              selected: _options.contains(option),
              onSelected: (selected) => context.formMod.updateSaveOption(option, selected),
            ),
          ),
        ],
      ),
      actions: [
        const DismissTextButton(text: "Cancel"),
        const AffirmativeTextButton(text: "Save"),
      ],
    );
  }
}

class DeleteItemDialog extends StatelessWidget {
  const DeleteItemDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete this item?"),
      content: Text("Warning: You cannot undo this action."),
      actions: [
        const DismissTextButton(text: "Cancel"),
        const PrimaryNegativeTextButton(text: "Delete"),
      ],
    );
  }
}

class CostItemCategoryGrid extends StatefulWidget {
  const CostItemCategoryGrid({
    super.key,
  });

  @override
  State<CostItemCategoryGrid> createState() => _CostItemCategoryGridState();
}

class _CostItemCategoryGridState extends State<CostItemCategoryGrid> {
  String? _selectedCatId;
  List<CostItemCategory> _filteredCostItemCategories = [];

  FormGroup _selectedFormGroup = FormGroup.expense;
  CostType? _selectedCostType = CostType.expense;

  final gridSettings = {
    3: {
      "mainSpacing": 8.0,
      "crossSpacing": 12.0,
      "iconPadding": 20.0,
    },
    4: {
      "mainSpacing": 12.0,
      "crossSpacing": 12.0,
      "iconPadding": 20.0,
    },
    5: {
      "mainSpacing": 4.0,
      "crossSpacing": 4.0,
      "iconPadding": 16.0,
    },
  };

  @override
  void initState() {
    super.initState();

    if (context.formMod.selectedCategory != null) {
      _selectedCostType = context.formMod.type;
      _selectedCatId = context.formMod.selectedCategory!.id!;
    }

    _filteredCostItemCategories =
        defaultCostItemCategories
            .where((category) => category.costType == _selectedCostType)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = context.mq.size;
    final selectedThemeMode = context.themeMod.theme;
    final selectedFormGroup = context.select((FormModel state) => state.formGroup);
    final gridSize = context.select((ThemeModel state) => state.gridSize);

    // ignore: unused_local_variable
    int favoriteLength = context.select((FormModel state) => state.savedItems.length);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: screenSize.width,
          child: SegmentedButton(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: context.customCs.flipCardColor,
              selectedForegroundColor: context.customCs.onFlipCard,
              side: BorderSide(color: context.cs.primary.withAlpha(100)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
            ),
            segments: [
              ...FormGroup.values.map((formGroup) {
                return ButtonSegment(
                  value: formGroup,
                  icon: Icon(
                    formGroup == FormGroup.favorite
                        ? Icons.favorite_rounded
                        : Icons.attach_money_rounded,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      formGroup.name.capitalize(),
                      style: context.customTt.numberLabel!.copyWith(
                        color:
                            selectedFormGroup == formGroup
                                ? context.customCs.onFlipCard
                                : context.cs.primary,
                      ),
                    ),
                  ),
                );
              }),
            ],
            selected: {selectedFormGroup},
            onSelectionChanged: (newSelection) {
              context.formMod.updateFormGroup(newSelection.first);
            },
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (selectedFormGroup != FormGroup.favorite)
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 120),
                  sliver: SliverGrid.list(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    children: [
                      ...context.formMod.categories.map((category) {
                        final catId = category.id;
                        final isSelected = catId == _selectedCatId;

                        final bgColor = context.cs.primary.withAlpha(isSelected ? 100 : 5);
                        final fgColor = isSelected ? context.cs.onPrimary : context.cs.primary;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCatId = catId);
                            context.formMod.selectNewCategory(category);
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 1.05 : 1,
                            duration: Durations.short3,
                            curve: Curves.easeInOut,
                            child: Column(
                              spacing: 4,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: Durations.medium1,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(16),
                                    border: BoxBorder.all(color: context.cs.primary.withAlpha(50)),
                                    color: bgColor,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CategoryIconContainer(
                                      category: category,
                                      inContainer: false,
                                    ),
                                    // child: category.createIcon(30, selectedThemeMode, fgColor),
                                  ),
                                ),
                                Text(
                                  category.name!.capitalize(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.tt.bodyMedium!.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Column(
                        spacing: 4,
                        children: [
                          ReusableContainer(
                            padding: EdgeInsets.all(16),
                            highlight: true,
                            filled: true,
                            onTap: () => debugPrint("create new category"),
                            child: Icon(
                              Icons.add,
                              size: 30,
                            ),
                          ),
                          Text("Add New", style: context.tt.bodyMedium!.copyWith(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              if (selectedFormGroup == FormGroup.favorite)
                context.formMod.savedItems.isNotEmpty
                    ? SliverPadding(
                      padding: const EdgeInsets.only(top: 16.0),
                      sliver: SliverList.builder(
                        itemCount: context.formMod.savedItems.length,
                        itemBuilder: (context, index) {
                          final SavedItem item = context.formMod.savedItems.elementAt(index);
                          final CostItemCategory cat = context.formMod.getCatById(item);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ReusableContainer(
                              onTap: () => context.formMod.selectSavedItem(item),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                spacing: 12,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CategoryIconContainer(
                                    category: cat,
                                    inContainer: false,
                                  ),
                                  Expanded(child: Text(item.title!)),
                                  Icon(Icons.favorite),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    : SliverToBoxAdapter(
                      child: SizedBox(
                        height: context.mq.size.height * 0.8,
                        child: Center(child: const Text("You have no saved item.")),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
