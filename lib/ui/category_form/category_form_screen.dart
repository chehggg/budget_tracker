// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/category_form/category_form_viewmodel.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/widgets.dart';

class CategoryFormScreen extends StatelessWidget {
  const CategoryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final editMode = context.catFormMod.inEditMode;
    final defaultCat = context.catFormMod.defaultCat;
    final ready = context.select((CategoryFormViewModel state) => state.ready);

    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? "Edit category" : "New category"),
        actionsPadding: EdgeInsets.only(right: 8),
        actions: [
          if (editMode && defaultCat != null)
            IconButton(
              onPressed: () async {
                final response = await showDialog(
                  context: context,
                  builder: (_) {
                    return ResetDefaultDialog(
                      initCategory: defaultCat,
                      currentCategory: context.catFormMod.draft,
                    );
                  },
                );
                if (response == null) return;
                if (response && context.mounted) {
                  context.catFormMod.resetCategory();
                }
              },
              icon: Icon(Symbols.reset_wrench),
            ),
          if (editMode)
            IconButton(
              onPressed: () async {
                final items = context.catFormMod.getCategoryItems();
                final response = await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    if (items == null || items.isEmpty) {
                      return DeleteItemDialog();
                    } else {
                      return CategoryFormDeleteDialog(items: items, currencyFormat: context.catFormMod.currencyFormat,);
                    }
                  },
                );
                if (response == null) return;
                if (response && context.mounted) {
                  await context.catFormMod.deleteCategoryItem();
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
              icon: Icon(Icons.delete),
            ),
          IconButton(
            onPressed: () {
              final error = context.catFormMod.validateForm();
              if (error == null) {
                context.catFormMod.submitCategory();
                context.pop();
              } else {
                context.showErrorNotification(message: error);
              }
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child:
            ready
                ? const CategoryFormBody()
                : const Center(
                  child: CircularProgressIndicator(),
                ),
      ),
    );
  }
}

class CategoryFormDeleteDialog extends StatelessWidget {
  const CategoryFormDeleteDialog({
    super.key,
    required this.items,
    required this.currencyFormat
  });

  final List<CostItem> items;
  final String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  }) currencyFormat;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete Items?"),
      content: SizedBox(
        // height: 300,
        width: 300,
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You have ${items.length} cost item${items.length > 1 ? "s" : ""} tied to this category.",
            ),
            Container(
              // height: 200,
              width: 300,
              constraints: BoxConstraints(maxHeight: 200),
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ...items.map(
                        (item) => Row(
                          spacing: 12,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Text(
                                item.date?.formatStd() ?? "",
                                style: context.customTt.paragraphTextSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 2,
                              child: Text(
                                item.name ?? "",
                                style: context.customTt.paragraphTextSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Text(
                                currencyFormat(
                                  item.amount ?? 0,
                                  compact: true,
                                ),
                                textAlign: TextAlign.right,
                                style: context.customTt.paragraphTextSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Text(
              "If the category is deleted, the above items will be removed as well. Do you want to proceed?",
            ),
          ],
        ),
      ),
      actions: [
        DismissTextButton(
          onTap: () => context.pop(false),
        ),
        PrimaryNegativeTextButton(
          onTap: () {
            context.pop(true);
          },
        ),
      ],
    );
  }
}

class CategoryFormBody extends StatelessWidget {
  const CategoryFormBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final draft = context.select((CategoryFormViewModel state) => state.draft);
    final type = context.select((CategoryFormViewModel state) => state.draft.costType);
    final color = context.select((CategoryFormViewModel state) => state.draft.color);
    final path = context.select((CategoryFormViewModel state) => state.draft.imagePath);
    final iconData = context.select((CategoryFormViewModel state) => state.draft.iconName);

    return CustomScrollView(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            // Padding(
            //   padding: const EdgeInsets.only(top: 8.0, bottom: 8),
            //   child: Text("Category Name"),
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await context.push<CategoryIconResult?>(
                      '/form/edit-category/category-icon',
                    );
                    if (result == null) return;
                    if (result.path != null) {
                      context.catFormMod.updateIcon(result.path!);
                    } else if (result.iconName != null) {
                      context.catFormMod.updateIconData(result.iconName!);
                    }
                  },
                  child: Stack(
                    alignment: Alignment(0.85, 0.85),
                    children: [
                      CategoryIconContainer(
                        category: draft,
                        containerSize: 103,
                        size: 60,
                        radius: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: context.cs.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.edit, size: 20, color: context.cs.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.name,
                        initialValue: draft.name,
                        onChanged: context.catFormMod.updateTitle,
                        style: context.tt.bodyMedium,
                        decoration: InputDecoration(
                          hintText: "Name your category here...",
                          visualDensity: VisualDensity(vertical: -1),
                          isDense: true,
                        ),
                      ),
                      SegmentedButton(
                        onSelectionChanged: (value) {
                          if (value.isEmpty) return;
                          context.catFormMod.updateCostType(value.first!);
                        },
                        style: SegmentedButton.styleFrom(
                          // selectedBackgroundColor: color,
                          visualDensity: VisualDensity(vertical: 1),
                          side: BorderSide(color: context.customCs.fadeColor2 ?? Colors.white),
                        ),
                        segments:
                            CostType.values
                                .map(
                                  (type) => ButtonSegment(
                                    value: type,
                                    label: Text(type.name.capitalize()),
                                  ),
                                )
                                .toList(),
                        selected: {type},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          sliver: SliverToBoxAdapter(
            child: Text("Color", style: context.customTt.paragraphTitle),
          ),
        ),
        CategoryColorSelectionGrid(),
      ],
    );
  }
}

class CategoryColorSelectionGrid extends StatefulWidget {
  const CategoryColorSelectionGrid({
    super.key,
  });

  @override
  State<CategoryColorSelectionGrid> createState() => _CategoryColorSelectionGridState();
}

class _CategoryColorSelectionGridState extends State<CategoryColorSelectionGrid> {
  List<Color> _colors = [...Colors.primaries, ...Colors.accents];

  @override
  void initState() {
    super.initState();
    generateColorGrid(context.catFormMod.draft.color);
  }

  void generateColorGrid(Color? selectedColor) {
    if (selectedColor == null) return;
    setState(() {
      if (_colors.contains(selectedColor)) {
        _colors = _colors;
      } else {
        _colors.add(selectedColor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.select((CategoryFormViewModel state) => state.draft.color);
    return SliverGrid.count(
      crossAxisCount: 8,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        ..._colors.map(
          (el) {
            final selected = color == el;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.catFormMod.updateColor(el);
                },
                child: AnimatedScale(
                  scale: selected ? 1.1 : 0.9,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    child: Container(
                      decoration: BoxDecoration(
                        border: BoxBorder.all(color: context.customCs.fadeColor2!),
                        color: el.withAlpha(selected ? 255 : 200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 300),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        InkWell(
          onTap: () async {
            // final initColor = color;
            final response = await showDialog<Color?>(
              context: context,
              builder: (dialogContext) {
                Color initColor = color ?? Colors.white;
                return StatefulBuilder(
                  builder: (statefulContext, setState) {
                    debugPrint("dialog rebuilt");
                    return AlertDialog(
                      title: Text("Color picker"),
                      content: SizedBox(
                        height: 300,
                        child: ColorPicker(
                          colorPickerWidth: 300,
                          displayThumbColor: false,
                          hexInputBar: false,
                          pickerAreaHeightPercent: 0.5,
                          enableAlpha: false,
                          labelTypes: [ColorLabelType.hex],
                          labelTextStyle: context.tt.bodyMedium,
                          pickerColor: initColor,
                          onColorChanged: (value) {
                            setState(() {
                              initColor = value;
                            });
                          },
                        ),
                      ),
                      actions: [
                        DismissTextButton(
                          onTap: () {
                            context.pop(null);
                          },
                        ),
                        AffirmativeTextButton(
                          onTap: () {
                            context.pop(initColor);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            );
            if (response == null) return;
            if (context.mounted) {
              context.catFormMod.updateColor(response);
              generateColorGrid(response);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentGeometry.topLeft,
                end: AlignmentGeometry.bottomRight,
                colors: [Colors.red, Colors.green, Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class ResetDefaultDialog extends StatelessWidget {
  const ResetDefaultDialog({
    super.key,
    required this.initCategory,
    required this.currentCategory,
  });

  final CostItemCategory initCategory;
  final CostItemCategory currentCategory;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Reset Category"),
      content: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Are you sure you want to reset this category to default?"),
          Text("Current:", style: context.customTt.paragraphText),
          Row(
            spacing: 12,
            children: [
              CategoryIconContainer(
                category: currentCategory,
                size: 18,
              ),
              Text("${currentCategory.name ?? ""} (${currentCategory.costType?.name ?? ""})"),
            ],
          ),
          Text("Default:", style: context.customTt.paragraphText),
          Row(
            spacing: 12,
            children: [
              CategoryIconContainer(
                category: initCategory,
                size: 18,
              ),
              Text("${initCategory.name ?? ""} (${currentCategory.costType?.name ?? ""})"),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Text("This action cannot be undone."),
        ],
      ),
      actions: [
        DismissTextButton(
          onTap: () => context.pop(false),
        ),
        PrimaryNegativeTextButton(text: "Reset", onTap: () => context.pop(true)),
      ],
    );
  }
}
