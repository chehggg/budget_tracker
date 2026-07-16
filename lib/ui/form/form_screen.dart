import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/ui/form/form_viewmodel.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';

// screen for user to input a new cost item
// or edit a existing cost item
// class CostFormScreenWrapper extends StatelessWidget {
//   const CostFormScreenWrapper({
//     super.key,
//     required this.arg,
//   });
//   final FormArgument? arg;

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create:
//           (context) => FormViewModel(
//             sharedElRepo: context.read(),
//             initCostItem: arg?.selectedCostItem,
//             costItemRepo: context.read(),
//             savedItemRepo: context.read(),
//             categoryRepo: context.read(),
//             currencyRepo: context.read(),
//           ),
//       child: CostFormScreen(arg: arg),
//     );
//   }
// }

class CostFormScreen extends StatelessWidget {
  const CostFormScreen({
    super.key,
    required this.arg,
  });

  final FormArgument? arg;

  @override
  Widget build(BuildContext context) {
    final ready = context.select((FormViewModel state) => state.ready);
    final editMode = context.select((FormViewModel state) => state.editCategory);
    final selectedCategory = context.select((FormViewModel state) => state.selectedCategory);
    final formGroup = context.select((FormViewModel state) => state.formGroup);

    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 8),
        title: Text(editMode ? "Edit Item" : "New Item"),
        actions: [
          if (formGroup != FormGroup.favorite)
            IconButton(
              onPressed: () async {
                final response = await context.push('/form/edit-category');
              },
              icon: FaIcon(
                FontAwesomeIcons.folderPlus,
                size: 20,
              ),
            ),
          if (formGroup != FormGroup.favorite)
            IconButton(
              onPressed: () async {
                if (selectedCategory != null) {
                  final response = await context.push(
                    '/form/edit-category',
                    extra: selectedCategory,
                  );
                  // context.formMod.toggleEditCategory(false);
                } else if (selectedCategory == null) {
                  context.formMod.toggleEditCategory();
                }
              },
              icon: FaIcon(
                editMode ? FontAwesomeIcons.xmark : FontAwesomeIcons.solidPenToSquare,
                size: 20,
              ),
            ),
        ],
      ),
      bottomSheet: FormBottomSheet(
        initRoute: arg?.oriRoute,
      ),
      body: SafeArea(
        minimum: EdgeInsets.only(left: 12, right: 12, top: 12),
        bottom: false,
        child:
            ready
                ? const FormMainSelectionView()
                : const Center(
                  child: CircularProgressIndicator(),
                ),
      ),
      // bottomNavigationBar: bottom,
    );
  }
}

class FormBottomSheet extends StatefulWidget {
  const FormBottomSheet({super.key, this.initRoute});

  final String? initRoute;
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
    _selectedDate = context.formMod.draft.date ?? DateTime.now().standard;
    if (context.formMod.inEditMode) {
      _isFormOpened = true;
      _isFormExpanded = true;
    }
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
              backgroundColor: context.cs.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: context.cs.primary.withAlpha(50)),
                borderRadius: BorderRadiusGeometry.circular(30),
              ),
              dayStyle: context.tt.bodyMedium,
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
    // ignore: unused_local_variable
    CostItemCategory? selectedCategory = context.select((FormViewModel state) {
      return state.selectedCategory;
    });

    debugPrint("rebuild, formOpen = ${_isFormOpened}, selected: ${selectedCategory?.name}");
    // animate bottom sheet moving up/down
    if (selectedCategory != null && !_isFormOpened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isFormOpened = true;
          _isFormExpanded = true;
        });
        debugPrint("called show postframe, formOpen = ${_isFormOpened}");
      });
    }

    String itemDesc = context.select((FormViewModel state) => state.draft.name ?? "");
    double? amount = context.select((FormViewModel state) => state.draft.amount);
    TextEditingController descController = context.watch<FormViewModel>().descriptionController;
    TextEditingController amountController = context.watch<FormViewModel>().amountController;

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
        curve: Curves.easeOutCubic,
        width: context.mq.size.width,
        height:
            !_isFormOpened
                ? 0
                : _isFormExpanded
                ? 480
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 0,
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
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            selectedCategory.capName,
                            ...[
                              if (!_isFormExpanded)
                                context.formMod.currencyFormat(amount ?? 0, compact: true),
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
                            final response = await context.push<bool?>(
                              '/form/edit-saved-item',
                              extra: {'initSavedItem': null, 'initCostItem': context.formMod.draft},
                            );
                            if (response == null) return;
                            if (context.mounted) {
                              if (response) {
                                context.formMod.updateFormGroup(FormGroup.favorite);
                                context.showSuccessNotification(message: "Saved item updated!");
                              }
                              context.formMod.refresh();
                            }
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.heart,
                            size: 20,
                            color: context.cs.surface,
                            // color: context.cs.error,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final response = await context.push<double?>(
                              '/form/currencies',
                              // arguments: context.formMod.draft.amount,
                            );
                            if (response == null) return;
                            if (context.mounted) {
                              context.formMod.applyExchangedValue(response);
                            }
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.moneyBillTransfer,
                            color: context.cs.surface,
                            size: 20,
                          ),
                        ),
                        if (context.formMod.inEditMode)
                          IconButton(
                            onPressed: () async {
                              final bool? deleteResponse = await showDialog<bool>(
                                context: context,
                                builder: (context) => const DeleteItemDialog(),
                              );
                              if (deleteResponse == true && context.mounted) {
                                await context.formMod.deleteItem();

                                if (context.mounted) {
                                  if (widget.initRoute != null) {
                                    context.pop();
                                  } else {
                                    context.go('/');
                                  }
                                }
                              }
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.trash,
                              color: context.cs.surface,
                              size: 18,
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
                          if (context.formMod.symbolOnLeft)
                            Text(
                              context.formMod.currencySymbol,
                              style: context.customTt.numberFontLarge!.copyWith(
                                fontSize: 60,
                                color: context.cs.primary,
                              ),
                            ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                // textDirection: !context.formMod.symbolOnLeft ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                amountController.text.isEmpty ? "0.00" : amountController.text,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                textAlign:
                                    !context.formMod.symbolOnLeft ? TextAlign.end : TextAlign.start,
                                style: context.customTt.numberFontLarge!.copyWith(
                                  fontSize: 60,
                                  color:
                                      amountController.text.isEmpty
                                          ? context.customCs.fadeColor2
                                          : context.cs.primary,
                                ),
                              ),
                            ),
                          ),
                          if (!context.formMod.symbolOnLeft)
                            Text(
                              context.formMod.currencySymbol,
                              style: context.customTt.numberFontLarge!.copyWith(
                                fontSize: 60,
                                color: context.cs.primary,
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
                        filled: false,
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
                        onDone: () async {
                          final error = context.formMod.validateFormResult();
                          if (error != null) {
                            context.showErrorNotification(
                              title: "Error: Cannot save item",
                              message: error,
                            );
                          } else {
                            await context.formMod.submitForm();
                            if (context.mounted) {
                              if (widget.initRoute != null) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            }
                          }
                        },
                        customButton: context.formMod.customButtonText,
                        layout: context.formMod.settings.layout,
                        reversed: context.formMod.settings.rowReversed,
                        customButtonReversed: context.formMod.settings.customButtonReversed,
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
    final selectedFormGroup = context.select((FormViewModel state) => state.formGroup);

    // final gridSize = context.select((ThemeModel state) => state.gridSize);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: SegmentedButton(
                  style: SegmentedButton.styleFrom(
                    // padding: EdgeInsets.symmetric(vertical: 12),
                    visualDensity: VisualDensity(vertical: 1),
                    textStyle: context.customTt.dateLabel?.copyWith(fontSize: 20),

                    selectedBackgroundColor: context.customCs.flipCardColor,
                    selectedForegroundColor: context.customCs.onFlipCard,
                    side: BorderSide(color: context.customCs.fadeColor1!.withAlpha(120)),
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
                            // style: context.customTt.numberLabel!.copyWith(
                            //   color:
                            //       selectedFormGroup == formGroup
                            //           ? context.customCs.onFlipCard
                            //           : context.cs.primary,
                            // ),
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
                  color: selectedFormGroup == FormGroup.favorite ? context.cs.primary : null,
                  borderRadius: BorderRadius.circular(12),
                  border: BoxBorder.all(
                    width: 1,
                    color: context.customCs.fadeColor1!.withAlpha(120),
                  ),
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
      (FormViewModel state) => state.draft.categoryId,
    );
    final categories = context.select((FormViewModel state) => state.categories);
    final editMode = context.select((FormViewModel state) => state.editCategory);
    // ignore: unused_local_variable
    final contextWatch = context.watch<FormViewModel>();
    debugPrint('from grid triggered and rebuilt');
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
            final isSelected = category.id == selectedCategory;

            // final bgColor = context.cs.primary.withAlpha(isSelected ? 250 : 5);
            final bgColor = category.color?.withAlpha(isSelected ? 100 : 0);
            // final fgColor = isSelected ? context.cs.onPrimary : context.cs.primary;

            return GestureDetector(
              onTap: () {
                if (editMode) {
                  context.push('/form/edit-category', extra: category);
                } else {
                  context.formMod.updateCategory(category);
                }
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
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                        border: BoxBorder.all(color: context.cs.primary.withAlpha(50)),
                        color: bgColor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CategoryIconContainer(
                          size: 30,
                          category: category,
                          inContainer: false,
                        ),
                        // child: category.createIcon(30, selectedThemeMode, fgColor),
                      ),
                    ),
                    Text(
                      category.capName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.tt.bodyMedium!.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (editMode)
            Column(
              spacing: 4,
              children: [
                ReusableContainer(
                  padding: EdgeInsets.all(16),
                  // highlight: true,
                  customColor: context.customCs.fadeColor2,
                  filled: true,
                  onTap: () => context.push('/form/edit-category'),
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
    final savedItems = context.watch<FormViewModel>().savedItems;
    // ignore: unused_local_variable
    final refresh = context.select((FormViewModel state) => state.refreshed);

    if (savedItems.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 14.0, bottom: 120),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 0,
            crossAxisSpacing: 12,
            mainAxisExtent: 92,
          ),
          itemCount: savedItems.length,
          itemBuilder: (context, index) {
            final SavedItem item = savedItems.elementAt(index);
            final CostItemCategory cat = context.formMod.getSavedItemCatById(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ReusableContainer(
                onTap: () => context.formMod.selectSavedItem(item),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    Row(
                      spacing: 20,
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
                            final response = await context.push<bool?>(
                              '/form/edit-saved-item',
                              extra: {'initSavedItem': item, 'initCostItem': null},
                              // arguments: item,
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
                      padding: const EdgeInsets.only(bottom: 8.0, top: 0),
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
