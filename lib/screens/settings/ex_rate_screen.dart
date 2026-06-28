import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/reusable/reusable_widgets.dart';
import 'package:budget_tracker/screens/settings/ex_rate_viewmodel.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyExchangeScreen extends StatelessWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loaded = context.select((ExRateViewModel state) => state.ready);

    return Scaffold(
      appBar: AppBar(
        title: Text("Exchange Currency"),
        actions: [
          IconButton(
            onPressed: () {
              context.navMod.pop(context.exRateMod.convertedValue);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(12, 20, 12, 0),
        child: Stack(
          children: [
            const CurrentExchangeBody(),
            if (!loaded)
              Container(
                color: Colors.black.withAlpha(100),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class CurrentExchangeBody extends StatelessWidget {
  const CurrentExchangeBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseCurrency = context.exRateMod.baseCurrency;
    final targetCurrency = context.exRateMod.targetCurrency;
    final rate = context.select((ExRateViewModel state) => state.resultRate);
    final finalValue = context.select((ExRateViewModel state) => state.formattedConvertedValue);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReusableContainer(
                padding: EdgeInsets.all(20),
                filled: true,
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Input Amount',
                      style: context.tt.bodyMedium!.copyWith(
                        fontSize: 14,
                        color: context.cs.surface,
                      ),
                    ),
                    const CurrencyExchangeInputField(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "1 ${baseCurrency.isoCode}",
                        style: context.customTt.numberFontMedium!.copyWith(
                          fontSize: 12,
                          color: context.customCs.fadeColor1,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Icon(
                      Icons.arrow_downward,
                      size: 50,
                    ),
                    Expanded(
                      child: Text(
                        "${rate.toStringAsFixed(4)} ${targetCurrency.isoCode}",
                        style: context.customTt.numberFontMedium!.copyWith(
                          fontSize: 12,
                          color: context.customCs.fadeColor1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ReusableContainer(
                padding: EdgeInsets.all(20),
                filled: true,
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Converted Amount',
                      style: context.tt.bodyMedium!.copyWith(
                        fontSize: 14,
                        color: context.cs.surface,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (targetCurrency.symbolOnLeft) Text(
                          targetCurrency.symbol,
                          style: context.customTt.numberFontLarge?.copyWith(
                            height: 1.2,
                            color: context.cs.surface,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            maxLines: 1,
                            textAlign: targetCurrency.symbolOnLeft ? TextAlign.end : TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            finalValue,
                            style: context.customTt.numberFontLarge?.copyWith(
                              height: 1.2,
                              color: context.cs.surface,
                            ),
                          ),
                        ),
                        if (!targetCurrency.symbolOnLeft) Text(
                          targetCurrency.symbol,
                          style: context.customTt.numberFontLarge?.copyWith(
                            height: 1.2,
                            color: context.cs.surface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 20),
          sliver: SliverToBoxAdapter(
            child: const Divider(),
          ),
        ),
        const CustomExchangeRateField(),
      ],
    );
  }
}

class CustomExchangeRateField extends StatelessWidget {
  const CustomExchangeRateField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseCurrency = context.exRateMod.baseCurrency;
    final targetCurrency = context.exRateMod.targetCurrency;
    final useCustomRate = context.select((ExRateViewModel state) => state.useCustomRate);
    final controller = context.select((ExRateViewModel state) => state.exRateController);
    final inverse = context.select((ExRateViewModel state) => state.isInverse);

    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          "Last Updated: ${DateTime.now().formatFull()}",
          style: context.customTt.paragraphText,
        ),
        SizedBox(
          height: 4,
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: context.exRateMod.toggleCustomExchangeRate,
          child: Row(
            spacing: 12,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: useCustomRate,
                    onChanged: (value) => context.exRateMod.toggleCustomExchangeRate(),
                  ),
                ),
              ),
              Expanded(child: Text("Custom Rate")),
              IconButton(
                onPressed: context.exRateMod.resetCustomExchangeRate,
                icon: Icon(
                  Icons.restore_outlined,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Row(
          spacing: 16,
          children: [
            SizedBox(
              width: 150,
              child: DropdownMenu(
                enabled: useCustomRate,
                textStyle: context.tt.bodyMedium,
                inputDecorationTheme: InputDecorationThemeData(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  filled: useCustomRate,
                  constraints: BoxConstraints(minHeight: 20),
                  isDense: true,
                  visualDensity: VisualDensity(vertical: -4),
                ),
                initialSelection: 0,
                onSelected: (value) {
                  if (value == null) return;
                  context.exRateMod.inverseRate(value == 1);
                },
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries:
                    [baseCurrency, targetCurrency]
                        .mapIndexed(
                          (index, val) => DropdownMenuEntry(
                            value: index,
                            label: "1 ${val.isoCode}",
                          ),
                        )
                        .toList(),
              ),
            ),
            Text("="),
            Expanded(
              child: TextFormField(
                enabled: useCustomRate,
                controller: controller,
                style: context.tt.bodyMedium!.copyWith(
                  color: useCustomRate ? null : context.customCs.fadeColor1,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: useCustomRate,
                  constraints: BoxConstraints(minHeight: 40),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  suffixIconConstraints: BoxConstraints(minHeight: 40),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Text(
                          inverse ? baseCurrency.isoCode : targetCurrency.isoCode,
                          style: context.tt.bodyMedium!.copyWith(
                            color: useCustomRate ? null : context.customCs.fadeColor1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class CurrencyExchangeInputField extends StatefulWidget {
  const CurrencyExchangeInputField({
    super.key,
  });

  @override
  State<CurrencyExchangeInputField> createState() => _CurrencyExchangeInputFieldState();
}

class _CurrencyExchangeInputFieldState extends State<CurrencyExchangeInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "1")
      ..addListener(() => context.exRateMod.updateBaseAmount(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.exRateMod.baseCurrency;
    return TextFormField(
      controller: _controller,
      autofocus: true,
      cursorColor: context.cs.surface,
      style: context.customTt.numberFontLarge?.copyWith(
        fontSize: 50,
        height: 1.2,
        color: context.cs.surface,
      ),
      textAlign: currency.symbolOnLeft ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon:
            currency.symbolOnLeft
                ? Text(
                  currency.symbol,
                  style: context.customTt.numberFontLarge?.copyWith(
                    fontSize: 50,
                    height: 1.2,
                    color: context.cs.surface,
                  ),
                )
                : null,
        suffixIcon:
            !currency.symbolOnLeft
                ? Text(
                  currency.symbol,
                  style: context.customTt.numberFontLarge?.copyWith(
                    fontSize: 50,
                    height: 1.2,
                    color: context.cs.surface,
                  ),
                )
                : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
      ),
      keyboardType: TextInputType.number,
    );
  }
}
