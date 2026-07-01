// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';

class EditSavedItemScreenWrapper extends StatelessWidget {
  const EditSavedItemScreenWrapper({
    super.key,
    this.initSavedItem,
    this.initCostItem,
  });

  final SavedItem? initSavedItem;
  final CostItem? initCostItem;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => SavedItemViewModel(
            initItem: initSavedItem,
            initCostData: initCostItem,
            categoryRepo: context.read(),
            savedItemRepo: context.read(),
          ),
      child: const EditSavedItemScreen(),
    );
  }
}

class EditSavedItemScreen extends StatelessWidget {
  const EditSavedItemScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final ready = context.select((SavedItemViewModel state) => state.ready);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.savedItemMod.inEditMode ? "Edit Saved Item" : "New Saved Item"),
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(12, 20, 12, 0),
        child: ready ? const EditSavedItemBody() : const Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}

class EditSavedItemBody extends StatelessWidget {
  const EditSavedItemBody({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final draft = context.select((SavedItemViewModel state) => state.draft);
    final inputDecoration = InputDecoration(
      hintText: "Title your saved",
      filled: false,
      fillColor: context.customCs.fadeColor4,
    );
    return CustomScrollView(
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
                          category: context.savedItemMod.curCategory,
                          inverse: true,
                        ),
                        Expanded(
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                            cursorColor: context.cs.surface,
                            initialValue: draft.title,
                            onChanged: context.savedItemMod.updateTitle,
                            autofocus: !context.savedItemMod.inEditMode,
                            style: context.customTt.dateLabel!.copyWith(
                              fontSize: 30,
                              color: context.cs.surface,
                            ),
                            decoration: inputDecoration,
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
                initialValue: draft.description,
                onChanged: context.savedItemMod.updateDesc,
                title: 'Description',
                checkboxValue: context.select((SavedItemViewModel state) => state.keepDesc),
                onToggleCheckbox:
                    (value) => context.savedItemMod.toggleKeepValue(value, "description"),
              ),
              SavedItemField(
                initialValue: draft.amount?.formatRoundedString(),
                onChanged: context.savedItemMod.updateAmount,
                keyboardType: TextInputType.number,
                title: 'Amount',
                prefix: Text("RM"),
                textAlign: TextAlign.right,
    
                checkboxValue: context.select((SavedItemViewModel state) => state.keepAmount),
                onToggleCheckbox:
                    (value) => context.savedItemMod.toggleKeepValue(value, "amount"),
              ),
              SavedItemField(
                initialValue: draft.date?.formatFull(),
                onChanged: context.savedItemMod.updateDate,
                textAlign: TextAlign.right,
                title: 'Date',
                checkboxValue: context.select((SavedItemViewModel state) => state.keepDate),
                onToggleCheckbox:
                    (value) => context.savedItemMod.toggleKeepValue(value, "date"),
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(child: SizedBox()),
                  DismissTextButton(
                    onTap: () => context.nav.pop(false),
                  ),
                  AffirmativeTextButton(
                    text: "Save",
                    onTap: () async {
                      await context.savedItemMod.submitSavedItem();
                      context.nav.pop(true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SavedItemField extends StatelessWidget {
  const SavedItemField({
    super.key,
    required this.title,
    required this.checkboxValue,
    this.keyboardType,
    this.onTap,
    this.onToggleCheckbox,
    this.textAlign = TextAlign.left,
    this.prefix,
    this.initialValue,
    this.onChanged,
  });

  final String title;
  final bool checkboxValue;
  final void Function(bool?)? onToggleCheckbox;

  final TextAlign textAlign;
  final Widget? prefix;
  final GestureTapCallback? onTap;
  final TextInputType? keyboardType;

  final String? initialValue;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(
    BuildContext context,
  ) {
    final inputDecoration = InputDecoration(
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
          onChanged: onChanged,
          initialValue: initialValue,
          textCapitalization: TextCapitalization.sentences,
          enabled: checkboxValue,
          keyboardType: keyboardType,
          onTap: onTap,
          textAlign: textAlign,
          style: context.tt.bodyMedium!.copyWith(fontSize: 14),
          decoration: inputDecoration,
        ),
      ],
    );
  }
}
