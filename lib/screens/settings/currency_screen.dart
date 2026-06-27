import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/screens/settings/currency_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:provider/provider.dart';

class CurrencySelectionScreenWrapper extends StatelessWidget {
  const CurrencySelectionScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrencyViewModel(currencyRepo: context.read()),
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
        leading: BackButton(
          onPressed: context.navMod.pop,
        ),
      ),
      body: SafeArea(
        child:
            ready
                ? const CurrencySelectionBody()
                : Center(
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
    final currencies = context.select((CurrencyViewModel state) => state.filteredCurrencies);
    final selected = context.select((CurrencyViewModel state) => state.selectedCurrency);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          sliver: SliverToBoxAdapter(
            child: const CurrencySelectionField(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 12.0),
          sliver: SliverList.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final Currency currency = currencies.elementAt(index);
              final isSelected = currency.isoCode == selected.isoCode;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                tileColor: isSelected ? context.customCs.fadeColor3 : null,
                title: Row(
                  spacing: 12,
                  children: [
                    if (isSelected) Icon(Icons.check, size: 20,),
                    Expanded(
                      child: Text(
                        currency.name,
                        style: context.tt.bodyMedium!.copyWith(
                          fontSize: 14,
                          // color: isSelected ? context.cs.secondary : null,
                          fontWeight: isSelected ? FontWeight(600) : null,
                        ),
                      ),
                    ),
                    Text(
                      currency.symbol,
                      style: context.customTt.numberFontSmall!.copyWith(
                        // color: isSelected ? context.cs.secondary : null,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  context.read<CurrencyViewModel>().updateCurrency(currency);
                  context.navMod.goToNamedAndRemovePrevious("/settings");
                },
              );
            },
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
