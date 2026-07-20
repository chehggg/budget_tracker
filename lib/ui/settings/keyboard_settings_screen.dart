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
                        CustomDropdownListTile(
                          title: "Keyboard Layout",
                          initSelection: _settings.layout,
                          entries:
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
                          onSelected: (value) {
                            setState(() {
                              _settings = _settings.copyWith(layout: value);
                            });
                            sharedElRepo.updateKeyboardLayout(_settings.layout);
                          },
                        ),
                        CustomDropdownListTile(
                          title: "Custom Button",
                          // dense: true,
                          initSelection: _button,
                          onSelected: (value) {
                            setState(() {
                              _button = value ?? _button;
                            });
                            sharedElRepo.updateKeyboardCustomButton(_button);
                          },
                          entries:
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
