import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/form/saved_item_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateSavedItemScreen extends StatefulWidget {
  const CreateSavedItemScreen({
    super.key,
  });

  @override
  State<CreateSavedItemScreen> createState() => _CreateSavedItemScreenState();
}

class _CreateSavedItemScreenState extends State<CreateSavedItemScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  // List _options = [];
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: context.savedItemMod.title);
    _descController = TextEditingController(text: context.savedItemMod.description);
    _amountController = TextEditingController(text: context.savedItemMod.amount?.toString());
    _dateController = TextEditingController(text: context.savedItemMod.date?.formatFull());

    debugPrint("controller value: ${_descController.text}");
    _titleController.addListener(() => context.savedItemMod.updateTitle(_titleController.text));
    _descController.addListener(() => context.savedItemMod.updateDesc(_descController.text));
    _amountController.addListener(
      () => context.savedItemMod.updateAmount(_amountController.text),
    );
    // _titleController.addListener(() => context.formMod.updateSavedItemTitle(_titleController.text));
    // _options = context.formMod.saveOptions;
  }

  @override
  Widget build(BuildContext context) {
    // final options = context.select((FormModel state) => state.saveOptions);
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
      ),
      hintText: "Title your saved",
      filled: false,
      fillColor: context.customCs.fadeColor4,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.savedItemMod.isEditMode ? "Edit Saved Item" : "New Saved Item"),
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                spacing: 30,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cs.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Flex(
                      spacing: 8,
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            CategoryIconContainer(
                              category: context.savedItemMod.selectedCategory,
                              inverse: true,
                            ),
                            Expanded(
                              child: TextFormField(
                                cursorColor: context.cs.surface,
                                autofocus: !context.savedItemMod.isEditMode,
                                // canRequestFocus: true,
                                style: context.customTt.dateLabel!.copyWith(
                                  fontSize: 30,
                                  color: context.cs.surface,
                                ),
                                decoration: inputDecoration,
                                controller: _titleController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flex(
                    spacing: 4,
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Divider(),
                      Text(
                        "Optional Fields",
                        style: context.customTt.dateLabel!.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'If checkbox is on, value is preserved for saved item. By default, date is not preserved since this is mainly used as a shortcut to create similar cost item at current date.',
                        style: context.tt.bodyMedium!.copyWith(
                          fontSize: 12,
                          color: context.customCs.fadeColor1 ?? Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  SavedItemField(
                    controller: _descController,
                    title: 'Description',
                    checkboxValue: context.select((SavedItemModel state) => state.keepDesc),
                    onToggleCheckbox:
                        (value) => context.savedItemMod.toggleKeepValue(value, "description"),
                  ),
                  SavedItemField(
                    controller: _amountController,
                    title: 'Amount',
                    prefix: Text("RM"),
                    textAlign: TextAlign.right,

                    checkboxValue: context.select((SavedItemModel state) => state.keepAmount),
                    onToggleCheckbox:
                        (value) => context.savedItemMod.toggleKeepValue(value, "amount"),
                  ),
                  SavedItemField(
                    controller: _dateController,
                    textAlign: TextAlign.right,
                    title: 'Date',
                    checkboxValue: context.select((SavedItemModel state) => state.keepDate),
                    onToggleCheckbox:
                        (value) => context.savedItemMod.toggleKeepValue(value, "date"),
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Expanded(child: SizedBox()),
                      DismissTextButton(
                        onTap: context.nav.pop,
                      ),
                      AffirmativeTextButton(
                        onTap: () async {
                          await context.savedItemMod.saveItem();
                          context.nav.pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedItemField extends StatelessWidget {
  const SavedItemField({
    super.key,
    required this.controller,
    required this.title,
    required this.checkboxValue,
    this.onTap,
    this.onToggleCheckbox,
    this.textAlign = TextAlign.left,
    this.prefix,
  });

  final TextEditingController controller;
  final String title;
  final bool checkboxValue;
  final void Function(bool?)? onToggleCheckbox;

  final TextAlign textAlign;
  final Widget? prefix;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.customCs.fadeColor2 ?? Colors.transparent),
      ),
      prefix: prefix,
      isDense: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      filled: checkboxValue,
      fillColor: context.customCs.fadeColor4,
    );
    return Flex(
      spacing: 12,
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: -4, vertical: -2),
                value: checkboxValue,
                onChanged: onToggleCheckbox,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: context.customTt.numberFontMedium!.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        TextFormField(
          enabled: checkboxValue,
          onTap: onTap,
          textAlign: textAlign,
          style: context.tt.bodyMedium!.copyWith(fontSize: 14),
          decoration: inputDecoration,
          controller: controller,
        ),
      ],
    );
  }
}
