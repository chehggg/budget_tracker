import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/category_selection_viewmodel.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key, this.initSelection, this.goalType = GoalType.budget});

  final List<CostItemCategory>? initSelection;
  final GoalType goalType;
  @override
  Widget build(BuildContext context) {
    final CostType? type = switch (goalType) {
      GoalType.budget => CostType.expense,
      GoalType.savings => null,
      GoalType.payment => null,
    };

    return ChangeNotifierProvider(
      create:
          (context) => CategorySelectionViewmodel(
            categoryRepo: context.read(),
            initSelection: initSelection,
            costType: type,
          ),
      child: const CategorySelectionBody(),
    );
  }
}

class CategorySelectionBody extends StatefulWidget {
  const CategorySelectionBody({super.key});

  @override
  State<CategorySelectionBody> createState() => _CategorySelectionBodyState();
}

class _CategorySelectionBodyState extends State<CategorySelectionBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController()..addListener(
          () => context.read<CategorySelectionViewmodel>().updateFilterString(
            _controller.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final readCatMod = context.read<CategorySelectionViewmodel>();
    final displayCat = context.select(
      (CategorySelectionViewmodel state) => state.displayedCategories,
    );
    final selectedCategories = context.select(
      (CategorySelectionViewmodel state) => state.selectedCategories,
    );

    final ready = context.select((CategorySelectionViewmodel state) => state.ready);
    // ignore: unused_local_variable
    final length = context.select(
      (CategorySelectionViewmodel state) => state.selectedCategories.length,
    );
    // final length2 = context.select(
    //   (CategorySelectionViewmodel state) => state.displayedCategories.length,
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter Category"),
        actions: [
          IconButton(
            onPressed: () {
              context.nav.pop(selectedCategories);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.only(top: 20),
        child:
            ready
                ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextFormField(
                        style: context.tt.bodyMedium,
                        decoration: InputDecoration(
                          hintText: "Search for categories...",
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                          ),
                          hintStyle: TextStyle(color: context.customCs.fadeColor2),
                          prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        controller: _controller,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        return readCatMod.areAllSelected
                            ? readCatMod.removeAllCategories()
                            : readCatMod.selectAllCategories();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                        child: Row(
                          spacing: 8,
                          children: [
                            Text(
                              readCatMod.areAllSelected ? "Unselect All" : "Select All",
                              style: context.customTt.numberFontSmall!.copyWith(fontSize: 14),
                            ),
                            Expanded(
                              child: Text(
                                "(${selectedCategories.length} selected)",
                                style: context.customTt.paragraphText,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                              child: Transform.scale(
                                scale: 0.9,
                                child: Checkbox(
                                  value: readCatMod.areAllSelected,
                                  onChanged: (val) {
                                    if (val == null) return;
                                    return val
                                        ? readCatMod.selectAllCategories()
                                        : readCatMod.removeAllCategories();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Divider(),
                          ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverList.builder(
                            itemCount: displayCat.length,
                            itemBuilder: (context, index) {
                              final category = displayCat.elementAt(index);
                              final selected = selectedCategories.contains(category);
                              return InkWell(
                                onTap: () {
                                  return selected
                                      ? readCatMod.removeCategory(category)
                                      : readCatMod.selectCategory(category);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    spacing: 16,
                                    children: [
                                      CategoryIconContainer(
                                        category: category,
                                        size: 18,
                                      ),
                                      Expanded(child: Text(category.name!.capitalize())),
                                      SizedBox(
                                        height: 20,
                                        child: Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(
                                            value: selected,
                                            onChanged: (val) {
                                              if (val == null) return;
                                              return val
                                                  ? readCatMod.selectCategory(category)
                                                  : readCatMod.removeCategory(category);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Center(
                  child: CircularProgressIndicator(),
                ),
      ),
    );
  }
}
