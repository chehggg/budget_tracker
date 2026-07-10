import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GlobalDisplaySettingsScreen extends StatefulWidget {
  const GlobalDisplaySettingsScreen({super.key});

  @override
  State<GlobalDisplaySettingsScreen> createState() => _GlobalDisplaySettingsScreenState();
}

class _GlobalDisplaySettingsScreenState extends State<GlobalDisplaySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final sharedRepo = context.read<SharedElementRepository>();
    final color = sharedRepo.accentColors;
    return CustomScaffold(
      appBarTitle: const Text('Global Display'),
      child: SliverList(
        delegate: SliverChildListDelegate([
          ColorListTile(
            title: "Positive Number Color",
            color: color.positive,
            onColorChanged: (newColor) {
              sharedRepo.updateAccentColor(
                color.copyWith(positive: newColor),
              );
              setState(() {});
            },
          ),
          ColorListTile(
            title: "Negative Number Color",
            color: color.negative,
            onColorChanged: (newColor) {
              sharedRepo.updateAccentColor(
                color.copyWith(negative: newColor),
              );
              setState(() {});
            },
          ),
          ColorListTile(
            title: "Current Range Color",
            color: color.current,
            onColorChanged: (newColor) {
              sharedRepo.updateAccentColor(
                color.copyWith(current: newColor),
              );
              setState(() {});
            },
          ),
          ColorListTile(
            title: "Previous Range Color",
            color: color.previous,
            onColorChanged: (newColor) {
              sharedRepo.updateAccentColor(
                color.copyWith(previous: newColor),
              );
              setState(() {});
            },
          ),
        ]),
      ),
    );
  }
}

class ColorListTile extends StatelessWidget {
  const ColorListTile({
    super.key,
    required this.color,
    required this.title,
    this.onColorChanged,
  });

  final Color color;
  final String title;
  final void Function(Color)? onColorChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onTap: () async {
        final response = await showDialog<Color?>(
          context: context,
          builder: (context) => ColorPickerDialog(initColor: color),
        );
        if (response != null && context.mounted) {
          onColorChanged?.call(response);
        }
      },
      title: Text(
        title,
        style: context.tt.bodyMedium,
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        width: 20,
        height: 20,
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.initColor});

  final Color initColor;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Color'),
      content: ColorPicker(
        colorPickerWidth: 200,
        pickerColor: _selectedColor,
        onColorChanged: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
        pickerAreaHeightPercent: 0.5,
      ),
      actions: <Widget>[
        DismissTextButton(
          onTap: () {
            context.pop();
          },
        ),
        AffirmativeTextButton(
          text: 'Select',
          onTap: () {
            context.pop(_selectedColor);
          },
        ),
      ],
    );
  }
}
