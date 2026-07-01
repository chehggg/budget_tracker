import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/match_type.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/reusable/text_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextSelectionScreen extends StatelessWidget {
  const TextSelectionScreen({super.key, this.initFilter});

  final StringFilter? initFilter;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => TextSelectionViewmodel(
            itemRepo: context.read(),
            categoryRepo: context.read(),
            initFilter: initFilter,
          ),
      child: const TextSelectionBody(),
    );
  }
}

class TextSelectionBody extends StatefulWidget {
  const TextSelectionBody({super.key});

  @override
  State<TextSelectionBody> createState() => _TextSelectionBodyState();
}

class _TextSelectionBodyState extends State<TextSelectionBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController()..addListener(
          () => context.read<TextSelectionViewmodel>().updateFilter(
            _controller.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final readTextMod = context.read<TextSelectionViewmodel>();
    final items = context.select(
      (TextSelectionViewmodel state) => state.displayedItems,
    );
    final filter = context.select(
      (TextSelectionViewmodel state) => state.filter,
    );
    // final selectedCategories = readCatMod.selectedCategories;

    final ready = context.select((TextSelectionViewmodel state) => state.ready);
    // ignore: unused_local_variable
    final length = context.select(
      (TextSelectionViewmodel state) => state.displayedItems.length,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter String"),
        actions: [
          IconButton(
            onPressed: () => context.nav.pop(filter),
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child:
            ready
                ? CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          spacing: 20,
                          children: [
                            DropdownMenu(
                              initialSelection: filter.matchType,
                              textStyle: context.tt.bodyMedium,
                              inputDecorationTheme: InputDecorationThemeData(),
                              onSelected: (val) {
                                if (val == null) return;
                                readTextMod.updateMatchType(val);
                              },
                              dropdownMenuEntries:
                                  StringMatchType.values
                                      .map(
                                        (type) => DropdownMenuEntry(value: type, label: type.name),
                                      )
                                      .toList(),
                            ),
                            Expanded(
                              child: TextFormField(
                                style: context.tt.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: "Filter Strings...",
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                  ),
                                  hintStyle: TextStyle(color: context.customCs.fadeColor2),
                                  prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                ),
                                controller: _controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          spacing: 4,
                          children: [
                            Text(
                              "Example result",
                              style: context.customTt.numberFontSmall!.copyWith(fontSize: 14),
                            ),
                            Text(
                              "(${items.length} returned from latest 200 results.)",
                              style: context.customTt.paragraphText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items.elementAt(index);
                        // final selected = selectedCategories.contains(category);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                          child: Row(
                            spacing: 16,
                            children: [
                              CategoryIconContainer(
                                category: readTextMod.getItemCategory(item),
                                size: 18,
                              ),
                              Expanded(child: Text(item.name?.capitalize() ?? "")),
                            ],
                          ),
                        );
                      },
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
