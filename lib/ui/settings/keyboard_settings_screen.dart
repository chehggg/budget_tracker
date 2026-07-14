import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KeyboardSettingsScreen extends StatefulWidget {
  const KeyboardSettingsScreen({super.key});

  @override
  State<KeyboardSettingsScreen> createState() => _KeyboardSettingsScreenState();
}

class _KeyboardSettingsScreenState extends State<KeyboardSettingsScreen> {
  // KeyboardLayout _layout = KeyboardLayout.simple;
  KeyboardSettings _settings = KeyboardSettings();
  SimpleKeyboardButtonType _button = SimpleKeyboardButtonType.decimal;

  @override
  void initState() {
    super.initState();

    _settings = context.read<SharedElementRepository>().keyboardSettings;
    _button = context.read<SharedElementRepository>().keyboardButton;
  }

  @override
  Widget build(BuildContext context) {
    final sharedElRepo = context.read<SharedElementRepository>();
    final currencyRepo = context.read<CurrencyRepository>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Keyboard Settings"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 20, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    "Current Keyboard",
                    style: context.customTt.numberFontSmall,
                  ),
                  SizedBox(
                    height: 220,
                    child: CustomKeyboard(
                      layout: _settings.layout,
                      customButtonReversed: _settings.customButtonReversed,
                      reversed: _settings.rowReversed,
                      customButton:
                          _button == SimpleKeyboardButtonType.doubleZero &&
                                  _settings.layout == KeyboardLayout.simple
                              ? "00"
                              : currencyRepo.currency.decimalSeparator,
                      controller: TextEditingController(),
                      selectedDate: DateTime.now(),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          title: Text(
                            "Keyboard Layout",
                            style: context.customTt.paragraphTitle,
                          ),
                          // dense: true,
                          visualDensity: VisualDensity(vertical: -4),
                          trailing: SizedBox(
                            width: 200,
                            child: DropdownMenu(
                              initialSelection: _settings.layout,
                              onSelected: (value) {
                                setState(() {
                                  _settings = _settings.copyWith(layout: value);
                                });
                                sharedElRepo.updateKeyboardLayout(_settings.layout);
                              },
                              expandedInsets: EdgeInsets.zero,
                              dropdownMenuEntries:
                                  KeyboardLayout.values
                                      .map(
                                        (el) => DropdownMenuEntry(
                                          value: el,
                                          label: el.name,
                                          style: TextButton.styleFrom(
                                            visualDensity: VisualDensity(vertical: -2),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              textStyle: context.tt.bodyMedium,
                              inputDecorationTheme: InputDecorationThemeData(
                                visualDensity: VisualDensity(vertical: -4),
                                constraints: BoxConstraints(maxHeight: 40),
                              ),
                              menuStyle: MenuStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                visualDensity: VisualDensity.comfortable,
                                backgroundColor: WidgetStatePropertyAll(
                                  context.cs.surfaceContainer ?? Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          title: Text(
                            "Custom Button",
                            style: context.customTt.paragraphTitle,
                          ),
                          // dense: true,
                          visualDensity: VisualDensity(vertical: -4),
                          trailing: SizedBox(
                            width: 200,
                            child: DropdownMenu(
                              enabled: _settings.layout == KeyboardLayout.simple,
                              initialSelection: _button,
                              onSelected: (value) {
                                setState(() {
                                  _button = value ?? _button;
                                });
                                sharedElRepo.updateKeyboardCustomButton(_button);
                              },
                              expandedInsets: EdgeInsets.zero,
                              dropdownMenuEntries:
                                  SimpleKeyboardButtonType.values
                                      .map(
                                        (buttonType) => DropdownMenuEntry(
                                          value: buttonType,
                                          label:
                                              buttonType == SimpleKeyboardButtonType.doubleZero
                                                  ? "00"
                                                  : "${currencyRepo.currency.decimalSeparator} (Decimal separator)",
                                          style: TextButton.styleFrom(
                                            visualDensity: VisualDensity(vertical: -2),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              textStyle: context.tt.bodyMedium,
                              inputDecorationTheme: InputDecorationThemeData(
                                visualDensity: VisualDensity(vertical: -4),
                                constraints: BoxConstraints(maxHeight: 40),
                              ),
                              menuStyle: MenuStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                visualDensity: VisualDensity.comfortable,
                                backgroundColor: WidgetStatePropertyAll(
                                  context.cs.surfaceContainer ?? Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        CustomSwitchListTile(
                          value: _settings.rowReversed,
                          title: "Reverse number row",
                          onSelected: (value) {
                            setState(() {
                              _settings = _settings.copyWith(rowReversed: value);
                            });
                            sharedElRepo.updateKeyboardRowSwitch(_settings.rowReversed);
                            debugPrint("value: $value, new value: ${_settings.rowReversed}");
                          },
                        ),
                        CustomSwitchListTile(
                          enabled: _settings.layout == KeyboardLayout.complex,
                          value: _settings.customButtonReversed,
                          title: "Reverse 00 and separator position",
                          onSelected: (value) {
                            setState(() {
                              _settings = _settings.copyWith(customButtonReversed: value);
                            });
                            sharedElRepo.updateKeyboardButtonSwitch(value);
                          },
                        ),
                      ],
                    ),
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
