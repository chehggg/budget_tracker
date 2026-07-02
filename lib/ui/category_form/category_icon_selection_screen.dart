import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryIconSelectionScreen extends StatelessWidget {
  const CategoryIconSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Category Icon"),
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              children: [
                Text("Upload from file (SVG format)"),
                TextButton(
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
                      context.pop(file.path);
                    }
                  },
                  child: Text("Browse"),
                ),
              ],
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                    itemBuilder: (context, index) {
                      return SizedBox.shrink();
                    },
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
