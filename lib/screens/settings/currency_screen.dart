import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/screens/settings/currency_viewmodel.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money2/money2.dart';
import 'package:provider/provider.dart';

class CurrencySelectionScreenWrapper extends StatelessWidget {
  const CurrencySelectionScreenWrapper({
    super.key,
    this.currencyExchange = false,
    this.initialValue,
  });

  final bool currencyExchange;
  final double? initialValue;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => CurrencyViewModel(
            currencyRepo: context.read(),
            isCurrencyExchange: currencyExchange,
          ),
      child: const CurrencySelectionScreen(),
    );
  }
}

class CurrencySelectionScreen extends StatelessWidget {
  const CurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select((CurrencyViewModel state) => state.ready);
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Currency"),
        actionsPadding: EdgeInsets.only(right: 8),
        actions: [
          IconButton(
            onPressed: () async {
              final response = await showDialog<bool?>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Restore to Default"),
                    content: Text("This action cannot be undone."),
                    actions: [
                      DismissTextButton(onTap: () => context.pop(false)),
                      PrimaryNegativeTextButton(
                        text: "Reset",
                        onTap: () => context.pop(true),
                      ),
                    ],
                  );
                },
              );
              if (response == true && context.mounted) {
                context.currencyMod.clearRecentlyUsed();
              }
            },
            icon: Icon(Icons.restore),
          ),
        ],
      ),
      body: SafeArea(
        child:
            ready
                ? const CurrencySelectionBody()
                : const Center(
                  child: CircularProgressIndicator(),
                ),
      ),
    );
  }
}

class CurrencySelectionBody extends StatelessWidget {
  const CurrencySelectionBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final contextWatch = context.watch<CurrencyViewModel>();
    final currencies = context.select((CurrencyViewModel state) => state.filteredCurrencies);
    final selected = context.select((CurrencyViewModel state) => state.selectedCurrency);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
          child: CurrencySelectionField(),
        ),
        if (context.currencyMod.isCurrencyExchange)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20.0),
            child: Row(
              spacing: 8,
              children: [
                Text("Convert To:"),
                Expanded(child: Text("${selected.name} (${selected.isoCode})")),
                Text(selected.symbol),
              ],
            ),
          ),
        Divider(),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 12.0),
                sliver: SliverList.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final Currency currency = currencies.elementAt(index);
                    final isSelected = currency.isoCode == selected.isoCode;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                      // tileColor: isSelected ? context.customCs.fadeColor3 : null,
                      title: Row(
                        spacing: 12,
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check,
                              size: 20,
                            ),
                          Expanded(
                            child: Text(
                              "${currency.name} (${currency.symbol})",
                              style: context.tt.bodyMedium!.copyWith(
                                fontSize: 14,
                                // color: isSelected ? context.cs.secondary : null,
                                fontWeight: isSelected ? FontWeight(600) : null,
                              ),
                            ),
                          ),
                          Text(
                            currency.isoCode,
                            style: context.customTt.numberFontSmall!.copyWith(
                              fontSize: 14,
                              // color: isSelected ? context.cs.secondary : null,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final currencyMod = context.currencyMod;
                        if (context.currencyMod.isCurrencyExchange) {
                          context.currencyMod.selectExchangeCurrency(currency);
                          final double? value = await context.push(
                            '/form/exchange',
                            extra: {
                              'base': currencyMod.selectedExchangeCurrency,
                              'target': currencyMod.selectedCurrency,
                            },
                          );
                          if (value == null) return;
                          if (context.mounted) {
                            context.pop(value);
                          }
                        } else {
                          context.pop(currency);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CurrencySelectionField extends StatefulWidget {
  const CurrencySelectionField({
    super.key,
  });

  @override
  State<CurrencySelectionField> createState() => _CurrencySelectionFieldState();
}

class _CurrencySelectionFieldState extends State<CurrencySelectionField> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController()
          ..addListener(() => context.read<CurrencyViewModel>().updateFilter(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      style: context.tt.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        hintText: "Search currencies via name, ISO or countries...",
        hintStyle: TextStyle(color: context.customCs.fadeColor2),
      ),
    );
  }
}
