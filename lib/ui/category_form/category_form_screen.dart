// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
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
    final ctxWatch = context.watch<CategoryFormViewModel>();
    final ready = context.select((CategoryFormViewModel state) => state.ready);

    Widget getBottomSheetIcon(CostItemCategory cat) {
      return Row(
        spacing: 12,
        children: [
          CategoryIconContainer(
            category: cat,
            size: 22,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat.name?.capitalize() ?? "Untitled",
                style: context.customTt.numberFontSmall,
              ),
              Text(
                cat.costType?.name.capitalize() ?? "",
                style: context.customTt.paragraphTextSmall,
              ),
            ],
          ),
        ],
      );
    }

    return CustomScaffold(
      appBarTitle: Text(editMode ? "Edit category" : "New category"),
      bottomSheet: CustomActionBottomSheet(
        top: 20,
        showNegativeButton: editMode,
        onNegativeButtonPressed: () async {
          final items = context.catFormMod.getCategoryItems();
          final response = await showDialog(
            context: context,
            builder: (dialogContext) {
              if (items == null || items.isEmpty) {
                return DeleteItemDialog();
              } else {
                return CategoryFormDeleteDialog(
                  items: items,
                  currencyFormat: context.catFormMod.currencyFormat,
                );
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
        onPrimaryButtonPressed: () {
          final error = context.catFormMod.validateForm();
          if (error == null) {
            context.catFormMod.submitCategory();
            context.pop();
          } else {
            context.showErrorNotification(message: error);
          }
        },
        content: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                editMode ? "Editing Category" : "Creating Category",
                style: context.customTt.numberFontSmall,
              ),
            ),
            if (editMode)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Initial",
                      style: context.customTt.paragraphTextSmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "New",
                      style: context.customTt.paragraphTextSmall,
                    ),
                  ),
                ],
              ),
            if (editMode)
              Row(
                children: [
                  ...[
                    ctxWatch.initCategory!,
                    ctxWatch.draft,
                  ].map((cat) => Expanded(child: getBottomSheetIcon(cat))),
                ],
              ),
            if (!editMode) getBottomSheetIcon(ctxWatch.draft),
          ],
        ),
      ),
      // actions: [
      //   if (editMode && defaultCat != null)
      //     IconButton(
      //       onPressed: () async {
      //         final response = await showDialog(
      //           context: context,
      //           builder: (_) {
      //             return ResetDefaultDialog(
      //               initCategory: defaultCat,
      //               currentCategory: context.catFormMod.draft,
      //             );
      //           },
      //         );
      //         if (response == null) return;
      //         if (response && context.mounted) {
      //           context.catFormMod.resetCategory();
      //         }
      //       },
      //       icon: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 20),
      //     ),
      //   if (editMode)
      //     IconButton(
      //       onPressed: () async {
      //         final items = context.catFormMod.getCategoryItems();
      //         final response = await showDialog(
      //           context: context,
      //           builder: (dialogContext) {
      //             if (items == null || items.isEmpty) {
      //               return DeleteItemDialog();
      //             } else {
      //               return CategoryFormDeleteDialog(
      //                 items: items,
      //                 currencyFormat: context.catFormMod.currencyFormat,
      //               );
      //             }
      //           },
      //         );
      //         if (response == null) return;
      //         if (response && context.mounted) {
      //           await context.catFormMod.deleteCategoryItem();
      //           if (context.mounted) {
      //             context.pop();
      //           }
      //         }
      //       },
      //       icon: FaIcon(
      //         FontAwesomeIcons.trash,
      //         size: 20,
      //       ),
      //     ),
        // IconButton(
        //   onPressed: () {
        //     final error = context.catFormMod.validateForm();
        //     if (error == null) {
        //       context.catFormMod.submitCategory();
        //       context.pop();
        //     } else {
        //       context.showErrorNotification(message: error);
        //     }
        //   },
        //   icon: FaIcon(FontAwesomeIcons.solidFloppyDisk, size: 20),
        // ),
      // ],
      ready: ready,
      child: CategoryFormBody(),
    );
  }
}

class CategoryFormDeleteDialog extends StatelessWidget {
  const CategoryFormDeleteDialog({super.key, required this.items, required this.currencyFormat});

  final List<CostItem> items;
  final String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  currencyFormat;

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
    final contextWatch = context.watch<CategoryFormViewModel>();
    final draft = contextWatch.draft;
    final selectedType = contextWatch.draft.costType;
    // final color = contextWatch.draft.color;
    // final path = contextWatch.draft.imagePath;
    // final iconData = contextWatch.draft.iconName;

    return CustomScrollView(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            HorizontalPadding(
              child: Text("Category Info", style: context.customTt.numberFontSmall),
            ),
            SizedBox(
              height: 20,
            ),
            HorizontalPadding(
              child: CustomTextField(
                fieldLabel: "Name",
                // textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                initialValue: draft.name,
                onChanged: context.catFormMod.updateTitle,
                hintText: "Name your category here...",
              ),
            ),
            // SizedBox(height: 16),
            // HorizontalPadding(
            //   child: CustomTextField(
            //     fieldLabel: "Description",
            //     keyboardType: TextInputType.name,
            //     initialValue: draft.name,
            //     onChanged: context.catFormMod.updateTitle,
            //     hintText: "Name your category here...",
            //     minLines: 3,
            //   ),
            // ),
            SizedBox(height: 24,),
            // Divider(height: 40),
            HorizontalPadding(child: Text("Cost Type", style: context.tt.bodyMedium)),
            SizedBox(
              height: 10,
            ),
            
            RadioGroup<CostType>(
              groupValue: selectedType,
              onChanged: (value) {
                if (value != null) context.catFormMod.updateCostType(value);
              },
              child: Column(
                children:
                    CostType.values
                        .map(
                          (type) => CustomRadioListTile<CostType>(
                            title: type.name.capitalize(),
                            value: type,
                            groupValue: selectedType,
                            dense: true,
                          ),
                        )
                        .toList(),
              ),
            ),
            Divider(height: 40),
            SizedBox(
              height: 4,
            ),
            HorizontalPadding(child: Text("Category View", style: context.customTt.numberFontSmall)),
            // HorizontalPadding(child: Text("Applicable for ", style: context.customTt.numberFontSmall)),
            SizedBox(
              height: 10,
            ),
            RadioGroup<CostType>(
              groupValue: selectedType,
              onChanged: (value) {
                if (value != null) context.catFormMod.updateCostType(value);
              },
              child: Column(
                children:
                    CostType.values
                        .map(
                          (type) => CustomRadioListTile<CostType>(
                            title: "Applicable for all groups",
                            value: type,
                            groupValue: selectedType,
                            dense: true,
                          ),
                        )
                        .toList(),
              ),
            ),
            Divider(height: 40),
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
              child: HorizontalPadding(
                child: Row(
                  children: [
                    Expanded(child: Text("Category Icon", style: context.customTt.numberFontSmall)),
                    CategoryIconContainer(
                      category: draft,
                      containerSize: 40,
                      size: 30,
                      radius: 8,
                      inContainer: false,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 40),
            HorizontalPadding(
              child: Text("Category Color", style: context.customTt.numberFontSmall),
            ),
            SizedBox(
              height: 20,
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   spacing: 12,
            //   children: [
            //     GestureDetector(
            //       onTap: () async {
            //         final result = await context.push<CategoryIconResult?>(
            //           '/form/edit-category/category-icon',
            //         );
            //         if (result == null) return;
            //         if (result.path != null) {
            //           context.catFormMod.updateIcon(result.path!);
            //         } else if (result.iconName != null) {
            //           context.catFormMod.updateIconData(result.iconName!);
            //         }
            //       },
            //       child: Stack(
            //         alignment: Alignment(0.85, 0.85),
            //         children: [
            //           CategoryIconContainer(
            //             category: draft,
            //             containerSize: 103,
            //             size: 60,
            //             radius: 20,
            //           ),
            //           Container(
            //             decoration: BoxDecoration(
            //               color: context.cs.surface,
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             padding: EdgeInsets.all(4),
            //             child: Icon(Icons.edit, size: 20, color: context.cs.primary),
            //           ),
            //         ],
            //       ),
            //     ),
            //     Expanded(
            //       child: Column(
            //         spacing: 8,
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.stretch,
            //         children: [
            //           TextFormField(
            //             textCapitalization: TextCapitalization.words,
            //             keyboardType: TextInputType.name,
            //             initialValue: draft.name,
            //             onChanged: context.catFormMod.updateTitle,
            //             style: context.tt.bodyMedium,
            //             decoration: InputDecoration(
            //               hintText: "Name your category here...",
            //               visualDensity: VisualDensity(vertical: -1),
            //               isDense: true,
            //             ),
            //           ),
            //           SegmentedButton(
            //             onSelectionChanged: (value) {
            //               if (value.isEmpty) return;
            //               context.catFormMod.updateCostType(value.first!);
            //             },
            //             style: SegmentedButton.styleFrom(
            //               // selectedBackgroundColor: color,
            //               visualDensity: VisualDensity(vertical: 1),
            //               side: BorderSide(color: context.customCs.fadeColor2 ?? Colors.white),
            //             ),
            //             segments:
            //                 CostType.values
            //                     .map(
            //                       (type) => ButtonSegment(
            //                         value: type,
            //                         label: Text(type.name.capitalize()),
            //                       ),
            //                     )
            //                     .toList(),
            //             selected: {type},
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          ]),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 220),
          sliver: CategoryColorSelectionGrid(),
        ),
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
  List<Color> _colors = [...Colors.primaries];

  @override
  void initState() {
    super.initState();
    generateColorGrid(null);
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
      crossAxisCount: 10,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        ..._colors.map(
          (el) {
            final selected = color == el;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 300),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.check,
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
              child: FaIcon(
                FontAwesomeIcons.plus,
                size: 16,
              ),
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
