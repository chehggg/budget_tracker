// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
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

    debugPrint("rebuild form");
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? "Edit category" : "New category"),
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
              icon: Icon(Icons.restore),
            ),
          if (editMode)
            IconButton(
              onPressed: () async {
                final items = context.catFormMod.getCategoryItems();
                final response = await showDialog(
                  context: context,
                  builder: (_) {
                    if (items == null || items.isEmpty) {
                      return DeleteItemDialog();
                    } else {
                      return CategoryFormDeleteDialog(items: items);
                    }
                  },
                );
                if (response == null) return;
                if (response && context.mounted) {
                  context.catFormMod.deleteCategoryItem();
                  context.pop();
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
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 12),
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
  });

  final List<CostItem> items;

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
                                context.catFormMod.currencyFormat(
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

    return CustomScrollView(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: Text("Category Name"),
            ),
            Row(
              spacing: 12,
              children: [
                GestureDetector(
                  onTap: () async {
                    final svgPath = await context.push<String?>(
                      '/form/edit-category/category-icon',
                    );
                    if (svgPath == null) return;
                    context.catFormMod.updateIcon(svgPath);
                  },
                  child: CategoryIconContainer(category: draft),
                ),
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    initialValue: draft.name,
                    onChanged: context.catFormMod.updateTitle,
                    style: context.tt.bodyMedium,
                    decoration: InputDecoration(hintText: "Name your category here"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8),
              child: Text("Cost Type"),
            ),
            SegmentedButton(
              onSelectionChanged: (value) {
                if (value.isEmpty) return;
                context.catFormMod.updateCostType(value.first!);
              },
              segments:
                  CostType.values
                      .map(
                        (type) => ButtonSegment(value: type, label: Text(type.name.capitalize())),
                      )
                      .toList(),
              selected: {type},
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text("Color"),
            ),
            BlockPicker(
              pickerColor: draft.color ?? Colors.white,
              onColorChanged: context.catFormMod.updateColor,
              layoutBuilder: (context, colors, child) {
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: GridView.count(
                    crossAxisCount: 7,
                    children: [...colors.map((color) => child(color))],
                  ),
                );
              },
              itemBuilder: (color, isCurrentColor, changeColor) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: changeColor,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      height: isCurrentColor ? 30 : 20,
                      width: isCurrentColor ? 30 : 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ]),
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
