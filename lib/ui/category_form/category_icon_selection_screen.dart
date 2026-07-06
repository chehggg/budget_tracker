import 'package:budget_tracker/constants/icons.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryIconSelectionScreen extends StatefulWidget {
  const CategoryIconSelectionScreen({super.key});

  @override
  State<CategoryIconSelectionScreen> createState() => _CategoryIconSelectionScreenState();
}

class _CategoryIconSelectionScreenState extends State<CategoryIconSelectionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<FontAwesomeIcon> _availableIcons =
      icons
          .where(
            (el) =>
                ((el.icon).fontFamily?.contains("Regular") ?? true) ||
                ((el.icon).fontFamily?.contains("Solid") ?? true),
          )
          .toList();
  List<FontAwesomeIcon> _filteredIcons = [];
  bool _showName = false;

  @override
  void initState() {
    super.initState();
    _filteredIcons = _availableIcons;

    _controller.addListener(
      () {
        setState(() {
          _filteredIcons =
              _availableIcons
                  .where(
                    (icon) => icon.name.toLowerCase().contains(_controller.text.toLowerCase()),
                  )
                  .toList();
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void updateFilter() {
  //   _filteredIcons =
  //       icons
  //           .where(
  //             (el) =>
  //                 ((el.icon).fontFamily?.contains("Regular") ?? true) ||
  //                 ((el.icon).fontFamily?.contains("Solid") ?? true),
  //           )
  //           .toList();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Icon"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showName = !_showName;
              });
            },
            icon: Icon(_showName ?  Symbols.more_up : Symbols.more_down),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: Text("Upload from file (SVG format)")),
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity(vertical: -2),
                      textStyle: context.tt.bodyMedium,
                      // side: BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                        side: BorderSide(color: context.customCs.fadeColor1 ?? Colors.white),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      final response = await FilePicker.pickFiles(
                        dialogTitle: "Select Category Icon",
                        type: FileType.custom,
                        allowMultiple: false,
                        allowedExtensions: ['svg'],
                      );
                      if (response == null) return;
                      final file = response.files.first;
                      if (file.extension != "svg") return;
                      if (context.mounted) {
                        context.pop(CategoryIconResult(path: file.path));
                      }
                    },
                    child: Text("Browse"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 20),
              child: TextFormField(
                style: context.tt.bodyMedium,
                controller: _controller,
                decoration: InputDecoration(
                  isDense: true,
                  visualDensity: VisualDensity(vertical: 0),
                  hintText: "Or search for icon here...",
                  // contentPadding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                        itemCount: _filteredIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _filteredIcons.elementAt(index).icon;
                          final iconName = _filteredIcons.elementAt(index).name;
                          return Container(
                            height: _showName ? 80 : 50,
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              onPressed: () {
                                context.pop(CategoryIconResult(iconName: iconName));
                              },
                              icon:
                                  _showName
                                      ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 6,
                                        children: [
                                          FaIcon(
                                            icon,
                                            size: _showName ? 18 : 20,
                                          ),
                                          Text(
                                            iconName,
                                            style: context.customTt.paragraphTextSmall!.copyWith(fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                      : FaIcon(icon),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
