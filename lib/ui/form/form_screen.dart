import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_screen.dart';
import 'package:budget_tracker/ui/form/form_viewmodel.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';

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
                ? const FormMainSelectionView()
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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _selectedDate = context.formMod.date;
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
    double? amount = context.select((FormModel state) => state.amount);
    TextEditingController descController = context.watch<FormModel>().descriptionController;
    TextEditingController amountController = context.watch<FormModel>().amountController;

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
                                (amount ?? 0).customCurrencyFormat(
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
                              // fontWeight: FontWeight(200),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...(context.formMod.selectedCategory != null)
                      ? [
                        IconButton(
                          onPressed: () async {
                            final bool? response = await context.nav.push(
                              MaterialPageRoute(
                                builder:
                                    (buildContext) => ChangeNotifierProvider(
                                      create:
                                          (_) => SavedItemModel(
                                            formData: context.formMod.formResult,
                                            category: selectedCategory,
                                            savedItemRepository: context.read(),
                                          ),
                                      child: const EditSavedItemScreen(),
                                    ),
                              ),
                            );
                            if (response == null) return;
                            if (response) {
                              context.formMod.updateFormGroup(FormGroup.favorite);
                              context.showSuccessNotification(message: "Saved item updated!");
                            }
                            context.formMod.refresh();
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red.shade500,
                            // color: context.cs.error,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final bool? deleteResponse = await showDialog<bool>(
                              context: context,
                              builder: (context) => const DeleteItemDialog(),
                            );
                            if (deleteResponse == true && context.mounted) {
                              await context.formMod.deleteItem();
                              context.navMod.popFormToMain();
                              context.showSuccessNotification(
                                message: "Item deleted successfully.",
                              );
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                            color: context.cs.surface,
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
                                amount == null
                                    ? Text(
                                      "0.00",
                                      textAlign: TextAlign.end,
                                      style: context.customTt.numberFontLarge!.copyWith(
                                        fontSize: 60,
                                        color: context.cs.primary.withAlpha(100),
                                      ),
                                    )
                                    : Text(
                                      amountController.text,
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
                      controller: descController,
                      textCapitalization: TextCapitalization.sentences,
                      style: context.tt.bodyMedium!,
                      minLines: 3,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled:  false,
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
                        controller: amountController,
                        onDone: () {
                          final error = context.formMod.validateFormResult();
                          if (error != null) {
                            context.showErrorNotification(
                              title: "Error: Cannot save item",
                              message: error,
                            );
                          } else {
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

class DeleteItemDialog extends StatelessWidget {
  const DeleteItemDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete item?"),
      content: const Text("Warning: You cannot undo this action."),
      actions: [
        const DismissTextButton(text: "Cancel"),
        PrimaryNegativeTextButton(
          text: "Delete",
          onTap: () => context.nav.pop(true),
        ),
      ],
    );
  }
}

class FormMainSelectionView extends StatelessWidget {
  const FormMainSelectionView({
    super.key,
  });

  static Map gridSettings = {
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
  Widget build(BuildContext context) {
    final selectedFormGroup = context.select((FormModel state) => state.formGroup);
    // final gridSize = context.select((ThemeModel state) => state.gridSize);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          spacing: 20,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton(
                  style: SegmentedButton.styleFrom(
                    // padding: EdgeInsets.symmetric(vertical: 12),
                    visualDensity: VisualDensity(vertical: 0),
                    selectedBackgroundColor: context.customCs.flipCardColor,
                    selectedForegroundColor: context.customCs.onFlipCard,
                    side: BorderSide(color: context.cs.primary.withAlpha(100)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                  ),
                  segments: [
                    ...[FormGroup.expense, FormGroup.income].map((formGroup) {
                      return ButtonSegment(
                        value: formGroup,
                        icon: Icon(Icons.attach_money_rounded),
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
            ),
            InkWell(
              onTap: () => context.formMod.updateFormGroup(FormGroup.favorite),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: Durations.short4,
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color:
                      selectedFormGroup == FormGroup.favorite
                          ? context.cs.primary
                          : context.cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: BoxBorder.all(width: 1, color: context.cs.primary.withAlpha(100)),
                ),
                width: 48,
                height: 48,
                child: Icon(
                  Icons.favorite,
                  size: 18,
                  color:
                      selectedFormGroup == FormGroup.favorite
                          ? context.cs.surface
                          : context.cs.primary,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (selectedFormGroup != FormGroup.favorite) const CategorySelectionView(),
              if (selectedFormGroup == FormGroup.favorite) const SavedItemSelectionView(),
            ],
          ),
        ),
      ],
    );
  }
}

class CategorySelectionView extends StatelessWidget {
  const CategorySelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = context.select(
      (FormModel state) => state.selectedCategory ?? CostItemCategory.error(),
    );
    final categories = context.select((FormModel state) => state.categories);
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 120),
      sliver: SliverGrid.list(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: 100,
          // childAspectRatio: 0.95,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        children: [
          ...categories.map((category) {
            final isSelected = category.id == selectedCategory.id;

            // final bgColor = context.cs.primary.withAlpha(isSelected ? 250 : 5);
            final bgColor = category.color?.withAlpha(isSelected ? 100 : 0);
            // final fgColor = isSelected ? context.cs.onPrimary : context.cs.primary;

            return GestureDetector(
              onTap: () {
                context.formMod.selectNewCategory(category);
                HapticFeedback.selectionClick();
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
    );
  }
}

class SavedItemSelectionView extends StatelessWidget {
  const SavedItemSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final savedItems = context.watch<FormModel>().savedItems;
    // ignore: unused_local_variable
    final refresh = context.select((FormModel state) => state.refreshed);

    if (savedItems.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 14.0, bottom: 120),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 0,
            crossAxisSpacing: 12,
            mainAxisExtent: 100,
          ),
          itemCount: savedItems.length,
          itemBuilder: (context, index) {
            final SavedItem item = savedItems.elementAt(index);
            final CostItemCategory cat = context.formMod.getCatById(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: context.customCs.fadeColor2 ?? Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.formMod.selectSavedItem(item),
                  child: Padding(
                    // filled: false,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4,
                      children: [
                        Row(
                          spacing: 12,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CategoryIconContainer(
                              category: cat,
                              size: 20,
                              inContainer: false,
                            ),
                            Expanded(
                              child: Text(
                                item.title ?? "Untitled",
                                style: context.customTt.dateLabel!.copyWith(fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final response = await context.nav.push(
                                  MaterialPageRoute(
                                    builder:
                                        (buildContext) => ChangeNotifierProvider(
                                          create:
                                              (_) => SavedItemModel(
                                                initItem: item,
                                                category: cat,
                                                formData: context.formMod.formResult,
                                                savedItemRepository: context.read(),
                                              ),
                                          child: const EditSavedItemScreen(),
                                        ),
                                  ),
                                );
                                if (response == null) return;
                                if (response) {
                                  context.showSuccessNotification(message: "Saved item updated!");
                                  context.formMod.updateFormGroup(FormGroup.favorite);
                                }
                                context.formMod.refresh();
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                          child: Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${item.description ?? "[Default Desc]"} | ${item.amount != null ? NumberFormat.currency(symbol: "RM").format(item.amount) : "[Default Amount]"} | ${item.date != null ? item.date!.formatShort() : "[Default Date]"}",
                                maxLines: 2,
                                style: context.tt.bodyMedium!.copyWith(
                                  color: context.customCs.fadeColor1,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child:
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: context.mq.size.height * 0.8,
          child: Center(child: const Text("You have no saved item.")),
        ),
      );
    }
  }
}
