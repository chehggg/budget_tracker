import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/group/group_add_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupAddScreen extends StatelessWidget {
  const GroupAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();
    OverlayEntry? _overlayEntry;

    void showOverlay() {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return LoadingOverlay();
        },
      );
      Overlay.of(context).insert(_overlayEntry!);
    }

    void discardOverlay() {
      _overlayEntry?.dispose();
      _overlayEntry = null;
    }

    return CustomScaffold(
      ready: ctxWatch.isInit,
      appBarTitle: Text("Add item to main"),
      bottomSheet: CustomActionBottomSheet(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        "Performing Action",
                        style: context.customTt.numberFontSmall,
                      ),
                    ],
                  ),
                  Text(
                    "Adding ${ctxWatch.selectedCostItems.length} items from ${ctxWatch.group.name}",
                    style: context.customTt.paragraphTextSmall,
                  ),
                  Text(
                    "Remove after complete",
                    style: context.customTt.paragraphTextSmall,
                  ),
                ],
              ),
            ),
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ctxWatch.currencyFormat(
                    ctxWatch.metric.balance,
                    customIso: ctxWatch.group.currency,
                  ),
                  style: context.customTt.numberFontSmall,
                ),
                Text(
                  "≈ ${ctxWatch.currencyFormat(ctxWatch.convertedBalance, customIso: ctxWatch.targetCurrency.isoCode)}",
                  style: context.customTt.paragraphTextSmall,
                ),
              ],
            ),
          ],
        ),
        showNegativeButton: true,
        negativeButtonText: "Back",
        onNegativeButtonPressed: () => context.pop(),
        negativeButtonColor: Colors.grey.shade700,
        negativeButtonIcon: FontAwesomeIcons.leftLong,
        primaryButtonText: "Add to main",
        onPrimaryButtonPressed: () async {
          final response = ctxWatch.validateForm();
          if (response != null) {
            context.showErrorNotification(message: response);
          } else {
            showOverlay();
            await ctxWatch.submitForm();
            if (context.mounted) {
              discardOverlay();
              context.pop();
            }
          }
        },
        primaryButtonIcon: FontAwesomeIcons.solidSquarePlus,
      ),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              HorizontalPadding(
                child: Text(
                  "You can add items from this cost group into the main list.",
                  style: context.customTt.paragraphTextSmall,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              RadioGroup<AddGroupType>(
                groupValue: ctxWatch.addGroupType,
                onChanged: (value) async {
                  final selected = [...ctxWatch.selectedCostItems];
                  
                  if (value != null) ctxWatch.updateAddGroupType(value);

                  if (value == AddGroupType.partial) {
                    final List<CostItem>? response = await context.push(
                      'settings/group-item-filter',
                      extra: {
                        "items": ctxWatch.initCostItem,
                        "selected": selected,
                      },
                    );
                    if (response != null) {
                      debugPrint("update");
                      ctxWatch.updateCostItems(response);
                    }
                  }
                },
                child: Column(
                  children: [
                    CustomRadioListTile<AddGroupType>(
                      title: "Add all item(s) into main",
                      groupValue: ctxWatch.addGroupType,
                      value: AddGroupType.all,
                    ),
                    CustomRadioListTile<AddGroupType>(
                      title: "Add certain item(s) into main",
                      value: AddGroupType.partial,
                      groupValue: ctxWatch.addGroupType,
                      trailing: Text(
                        'Select item...',
                        style: context.tt.bodyMedium!.copyWith(color: context.cs.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
              ),
              HorizontalPadding(
                child: Row(
                  spacing: 12,
                  children: [
                    Text(
                      "Add item(s) as",
                      style: context.customTt.numberFontSmall,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: FaIcon(FontAwesomeIcons.circleQuestion),
                      iconSize: 16,
                    ),
                  ],
                ),
              ),
              RadioGroup<AddGroupItemAs>(
                groupValue: ctxWatch.addGroupItemAs,
                onChanged: (value) {
                  if (value != null) ctxWatch.updateAddGroupItemAs(value);
                },
                child: Column(
                  children: [
                    CustomRadioListTile<AddGroupItemAs>(
                      title: "Individual item(s)",
                      value: AddGroupItemAs.individual,
                      groupValue: ctxWatch.addGroupItemAs,
                    ),
                    CustomRadioListTile<AddGroupItemAs>(
                      title: "Daily group",
                      value: AddGroupItemAs.daily,
                      groupValue: ctxWatch.addGroupItemAs,
                    ),
                    CustomRadioListTile<AddGroupItemAs>(
                      title: "Overall group",
                      value: AddGroupItemAs.overall,
                      groupValue: ctxWatch.addGroupItemAs,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
              ),
              if (ctxWatch.addGroupItemAs == AddGroupItemAs.individual) AddGroupRenameItemSection(),
              if (ctxWatch.addGroupItemAs != AddGroupItemAs.individual)
                AddGroupRenameGroupSection(),
              Divider(
                height: 20,
              ),
              if (ctxWatch.addGroupItemAs == AddGroupItemAs.individual) ItemCategorySection(),
              if (ctxWatch.addGroupItemAs != AddGroupItemAs.individual) GroupCategorySection(),
              if (ctxWatch.addGroupItemAs == AddGroupItemAs.overall) OverallGroupDateSection(),
              if (ctxWatch.exRateRequired) ExchangeRateSection(),
              Divider(
                height: 20,
              ),
              CustomSwitchListTile(
                title: "Delete item in group afterwards",
                onSelected: (value) => ctxWatch.toggleDeleteItem(value),
                // dense: true,
                value: ctxWatch.deleteItemAfter,
              ),
              CustomSwitchListTile(
                title: "Delete group afterwards",
                enabled: ctxWatch.addGroupType == AddGroupType.all,
                onSelected: (value) => ctxWatch.toggleDeleteGroup(value),
                // dense: true,
                value: ctxWatch.deleteGroupAfter,
              ),
              SizedBox(
                height: 160,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class ExchangeRateSection extends StatefulWidget {
  const ExchangeRateSection({
    super.key,
  });

  @override
  State<ExchangeRateSection> createState() => _ExchangeRateSectionState();
}

class _ExchangeRateSectionState extends State<ExchangeRateSection> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<GroupAddViewmodel>().useExRate.toStringAsFixed(4),
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.value = _controller.value.copyWith(
      text: context.read<GroupAddViewmodel>().useExRate.toStringAsFixed(4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 20,
        ),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 6),
          child: Text("Exchange rate", style: context.customTt.numberFontSmall),
        ),
        SizedBox(
          height: 8,
        ),
        RadioGroup<bool>(
          groupValue: ctxWatch.useCustomRate,
          onChanged: (value) {
            if (value != null) ctxWatch.toggleCustomExRate(value);

            if (value == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.requestFocus();
              });
            }
          },
          child: Column(
            children: [
              CustomRadioListTile<bool>(
                title: "Current",
                groupValue: ctxWatch.useCustomRate,
                value: false,
                trailing: Text(
                  "1 ${ctxWatch.group.currency} = ${ctxWatch.exchangeRate.toStringAsFixed(4)} ${ctxWatch.targetCurrency.isoCode}",
                  style: context.customTt.paragraphText,
                ),
              ),
              CustomRadioListTile<bool>(
                title: "Custom",
                groupValue: ctxWatch.useCustomRate,
                value: true,
                trailing: Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Row(
                    spacing: 8,
                    children: [
                      Text(
                        "1 ${ctxWatch.group.currency} = ",
                        style: context.customTt.paragraphText,
                      ),
                      Expanded(
                        child: CustomTextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          showFieldLabel: false,
                          keyboardType: TextInputType.number,
                          enabled: ctxWatch.useCustomRate,
                          onChanged:
                              (value) => ctxWatch.updateCustomRate(double.tryParse(value) ?? 1),
                        ),
                      ),
                      Text(
                        "${ctxWatch.targetCurrency.isoCode}",
                        style: context.customTt.paragraphText,
                      ),
                      SizedBox.square(
                        dimension: 18,
                        child: IconButton(
                          onPressed: () {},
                          icon: FaIcon(FontAwesomeIcons.rotate),
                          iconSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddGroupRenameItemSection extends StatefulWidget {
  const AddGroupRenameItemSection({
    super.key,
  });

  @override
  State<AddGroupRenameItemSection> createState() => _AddGroupRenameItemSectionState();
}

class _AddGroupRenameItemSectionState extends State<AddGroupRenameItemSection> {
  late FocusNode _focusPrefix, _focusSuffix;

  @override
  void initState() {
    super.initState();
    _focusPrefix = FocusNode();
    _focusSuffix = FocusNode();
  }

  @override
  void dispose() {
    _focusPrefix.dispose();
    _focusSuffix.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();
    return Column(
      children: [
        HorizontalPadding(
          child: Row(
            spacing: 12,
            children: [
              Text("Rename item(s)", style: context.customTt.numberFontSmall),
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.circleQuestion),
                iconSize: 16,
              ),
            ],
          ),
        ),
        RadioGroup<AddGroupRename>(
          groupValue: ctxWatch.addGroupRename,
          onChanged: (value) {
            if (value != null) ctxWatch.updateAddGroupRename(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (value == AddGroupRename.prefix) FocusScope.of(context).requestFocus(_focusPrefix);
              if (value == AddGroupRename.suffix) FocusScope.of(context).requestFocus(_focusSuffix);
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRadioListTile<AddGroupRename>(
                title: "No change",
                value: AddGroupRename.none,
              ),
              CustomRadioListTile<AddGroupRename>(
                title: "Add prefix",
                groupValue: ctxWatch.addGroupRename,
                value: AddGroupRename.prefix,
                trailing: Expanded(
                  child: CustomTextField(
                    focusNode: _focusPrefix,
                    showFieldLabel: false,
                    enabled: ctxWatch.addGroupRename == AddGroupRename.prefix,
                    onChanged: ctxWatch.updatePrefix,
                  ),
                ),
              ),
              CustomRadioListTile<AddGroupRename>(
                title: "Add suffix",
                groupValue: ctxWatch.addGroupRename,
                value: AddGroupRename.suffix,
                trailing: Expanded(
                  child: CustomTextField(
                    focusNode: _focusSuffix,
                    showFieldLabel: false,
                    enabled: ctxWatch.addGroupRename == AddGroupRename.suffix,
                    onChanged: ctxWatch.updateSuffix,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  ctxWatch.sampleText,
                  style: context.customTt.paragraphTextSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddGroupRenameGroupSection extends StatefulWidget {
  const AddGroupRenameGroupSection({
    super.key,
  });

  @override
  State<AddGroupRenameGroupSection> createState() => _AddGroupRenameGroupSectionState();
}

class _AddGroupRenameGroupSectionState extends State<AddGroupRenameGroupSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<GroupAddViewmodel>().groupName);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.value = _controller.value.copyWith(
      text: context.read<GroupAddViewmodel>().groupName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Group Name"),
          CustomTextField(
            controller: _controller,
            showFieldLabel: false,
            initialValue: ctxWatch.group.name,
            onChanged: (value) => ctxWatch.updateGroupName(value),
          ),
        ],
      ),
    );
  }
}

class ItemCategorySection extends StatelessWidget {
  const ItemCategorySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();

    void redirectToCategorySelection() async {
      final CostItemCategory? response = await context.push(
        'settings/group-category',
        extra: ctxWatch.singleItemCategory != null ? [ctxWatch.singleItemCategory!] : null,
      );

      if (response != null) {
        ctxWatch.updateCategory(response);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 6),
          child: Text("Item Category", style: context.customTt.numberFontSmall),
        ),
        RadioGroup<bool>(
          groupValue: ctxWatch.useSingleCategory,
          onChanged: (value) async {
            if (value != null) ctxWatch.toggleUseSingleCategory(value);
            if (value == true && ctxWatch.singleItemCategory == null) {
              redirectToCategorySelection();
            }
          },
          child: Column(
            children: [
              CustomRadioListTile<bool>(
                title: "No change",
                groupValue: ctxWatch.useSingleCategory,
                value: false,
              ),
              CustomRadioListTile<bool>(
                title: "Use same category",
                groupValue: ctxWatch.useSingleCategory,
                value: true,
                trailing:
                    ctxWatch.singleItemCategory == null
                        ? Text(
                          'Select category',
                          style: context.tt.bodyMedium!.copyWith(color: context.cs.secondary),
                        )
                        : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: redirectToCategorySelection,
                          child: Row(
                            spacing: 10,
                            children: [
                              CategoryIconContainer(
                                category: ctxWatch.singleItemCategory!,
                                size: 18,
                              ),
                              Text(
                                "Change",
                                style: context.customTt.paragraphText,
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GroupCategorySection extends StatelessWidget {
  const GroupCategorySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();

    void redirectToCategorySelection() async {
      final CostItemCategory? response = await context.push(
        'settings/group-category',
        extra: ctxWatch.singleItemCategory != null ? [ctxWatch.singleItemCategory!] : null,
      );

      if (response != null) {
        ctxWatch.updateCategory(response);
      }
    }

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(child: Text("Group Category")),
          ctxWatch.singleItemCategory == null
              ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: redirectToCategorySelection,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Select category',
                    style: context.tt.bodyMedium!.copyWith(color: context.cs.secondary),
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: redirectToCategorySelection,
                  child: Row(
                    spacing: 10,
                    children: [
                      CategoryIconContainer(
                        category: ctxWatch.singleItemCategory!,
                        size: 18,
                      ),
                      Text(
                        "Change",
                        style: context.customTt.paragraphText,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class OverallGroupDateSection extends StatelessWidget {
  const OverallGroupDateSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ctxWatch = context.watch<GroupAddViewmodel>();

    void selectDate() async {
      DateTime now = DateTime.now();
      final response = await showDatePicker(
        context: context,
        initialDatePickerMode: DatePickerMode.day,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        // currentDate: _selectedDate,
        // initialDate: _selectedDate,
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

      // setState(() => _selectedDate = response);
      // context.formMod.updateDate(_selectedDate);
    }

    // void redirectToCategorySelection() async {
    //   final CostItemCategory? response = await context.push(
    //     'settings/group-category',
    //     extra: ctxWatch.singleItemCategory != null ? [ctxWatch.singleItemCategory!] : null,
    //   );

    //   if (response != null) {
    //     ctxWatch.updateCategory(response);
    //   }
    // }

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text("Group Date")),
          Expanded(
            child: CustomTextField(
              readOnly: true,
              showFieldLabel: false,
              onTap: () async {
                selectDate();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GroupAddItemFilterScreen extends StatefulWidget {
  const GroupAddItemFilterScreen({super.key, required this.items, this.selectedItems});

  final List<CostItem> items;
  final List<CostItem>? selectedItems;

  @override
  State<GroupAddItemFilterScreen> createState() => _GroupAddItemFilterScreenState();
}

class _GroupAddItemFilterScreenState extends State<GroupAddItemFilterScreen> {
  List<CostItem> _selected = [];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedItems ?? [];
  }


  void addItem(CostItem item) {
    setState(() {
      _selected.add(item);
    });
  }

  void removeItem(CostItem item) {
    setState(() {
      _selected.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBarTitle: Text("Select Cost Items"),
      child: Column(
        children: [
          RadioGroup<bool>(
            onChanged: (value) {},
            child: Column(
              children: [
                CustomRadioListTile(title: "Manual select", value: false),
                CustomRadioListTile(title: "Use custom filter query", value: false),
              ],
            ),
          ),
          Divider(
            height: 40,
          ),
          HorizontalPadding(
            child: CustomTextField(
              showFieldLabel: false,
              hintText: "Search for item...",
            ),
          ),
          Divider(
            height: 40,
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items.elementAt(index);
                    return CheckboxListTile(
                      title: Text(item.name ?? ""),
                      value:
                          widget.selectedItems?.firstWhereOrNull(
                            (selectedItem) => selectedItem.uuid == item.uuid,
                          ) !=
                          null,
                      onChanged: (value) {
                        if (value == null) return;
                        return value ? addItem(item) : removeItem(item);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
