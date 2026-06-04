import 'dart:math';
import 'dart:ui';

import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CostItem {
  CostItem(
      this.name,
      this.amount,
      this.category,
    {
      this.uuid,
      this.image,
      required this.date,
      required this.costType,
    }
  );

  String? uuid;
  String category;
  String? image;
  String name;
  double amount;
  DateTime date;
  CostType costType;

  // create a instance of cost item from form
  CostItem.fromForm(CostItemFormResult result,{required String id}) :
    uuid = id,
    date = result.date,
    costType = result.costType,
    category = result.category,
    amount = result.amount,
    name  = result.name
  ;

  CostItem.update(CostItemFormResult result, String id) :
    uuid = id,
    date = result.date,
    costType = result.costType,
    category = result.category,
    amount = result.amount,
    name  = result.name
  ;

  // create cost item into json
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'date': date.formatFull(),
    'costType': costType.name,
    'category': category,
    'amount': amount,
    'name': name,
  };

  // CostItem.fromJson(Map<String, dynamic> json) : 
  //   uuid = json['uuid'] as String,
  //   name = json['name'] as String,
  //   amount = json['amount'] as double,
  //   costType = CostType.values.where((costType) => costType.name == json['costType']).first,
  //   date = json['date'] as String;

  bool get isExpense => costType == CostType.expense;

  List<dynamic> toList() {
    final jsonObject = toJson();
    return List.generate(jsonObject.length, (i) => jsonObject.values.elementAt(i));
  }

  CostItem.fromList(List<dynamic> list) :
    uuid = list[0] as String,
    date = (list[1] as String).parseFull(), 
    costType = CostType.values.where((costType) => costType.name == list[2] as String).first,
    category = list[3] as String,
    amount = list[4] as double,
    name = list[5] as String;

  // DateTime get dateTime => date.standardDateParse(); 
  // String get yearMonthString => date.substring(0,7); //DateFormat: yyyy-MM-dd

  String getCurrencyValue(String currencySymbol, [bool? includeSign]) {
    final String value = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    final String? sign;
    if (includeSign == false) {
      sign = '';
    } else {
      sign = costType == CostType.expense? '-' : '+';
    }
    return '$sign $currencySymbol$value';
  }

  double getAbsoluteAmount() => costType == CostType.expense? 0 - amount: amount;
  // CostItemCategory get categoryItem {
  //   return AppModel().categories.where((categoryItem) => categoryItem.name == category).first;
  // }
}

class FormArgument {
  const FormArgument({
    // required this.isNew,
    this.oriRoute,
    this.selectedCostItem
  });

  // final bool isNew;
  final String? oriRoute;
  final CostItem? selectedCostItem;
}

class CostItemCategory {
  const CostItemCategory({
    this.id,
    this.name,
    this.color,
    this.imagePath,
    this.costType
  });

  final String? id;
  final String? name;
  final Color? color;
  final String? imagePath;
  final CostType? costType;

  ColorScheme colorScheme(ThemeMode mode) {
    Brightness brightness;
    // final themeMode = ThemeMode.light;
    switch (mode) {
      case ThemeMode.dark:
        brightness = Brightness.dark;
      case ThemeMode.light:
        brightness = Brightness.light;
      default:
        brightness = PlatformDispatcher.instance.platformBrightness;
    } 

    // debugPrint("getColorScheme, brightness: ${brightness.name}, theme: ${themeMode}");
    return ColorScheme.fromSeed(
      seedColor: color!,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      // contrastLevel: -0.1,
      // contrastLevel: -0.5,
      brightness: brightness 
    );
  }

  Widget createIcon(double size, ThemeMode mode, [Color? foregroundColor]) {
    final fg = foregroundColor ?? colorScheme(mode).onPrimaryContainer; 
    return SvgPicture.asset(
      imagePath!,
      colorFilter: foregroundColor == null? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
      // color: fg,
      height: size,
      width: size,
    );
  }

  Widget generateRoundedIcon(double size, ThemeMode mode, [Color? backgroundColor, Color? foregroundColor]) {
    final bg = backgroundColor ?? colorScheme(mode).primaryContainer; 
    // final bg = backgroundColor ?? colorScheme.primary; 
    final fg = foregroundColor ?? colorScheme(mode).onPrimaryContainer; 
    return Container(
      height: size + 12,
      width: size + 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg.withValues(
              red: min<double>((bg.r + 20/255), 1),
              blue: min<double>((bg.b + 20/255), 1),
              green: min<double>((bg.g + 20/255), 1),
            ),
            bg,
            bg.withAlpha(100),

          ]
        ),
        // color: bg
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: createIcon(size, mode, fg)
      ),
    );
  }

  // String getLocalizedName(BuildContext context) {
  //   final Map<String,dynamic> categoryJson = jsonDecode(AppLocalizations.of(context)!.categories);
  //   return categoryJson[name] ?? "NA";
  // }
}

class CostMetric {
  CostMetric({
    this.expense = 0,
    this.income = 0,
    // this.budgets,
  });

  double? expense;
  double? income;
  // List<Budget>? budgets;
  
  get balance => (income ?? 0) - (expense ?? 0);

  // CostMetric.update(CostMetric initMetric, double newExpense, double newIncome): 
  //   expense =  initMetric.expense! + newExpense,
  //   income = initMetric.income! + newIncome;

  void addToMetric(CostItem costItem) {
    expense = expense! + (costItem.costType == CostType.expense ? costItem.amount: 0); 
    income = income! + (costItem.costType == CostType.income ? costItem.amount: 0);
  }

  void minusFromMetric(CostItem costItem) {
    expense = expense! - (costItem.costType == CostType.expense ? costItem.amount: 0); 
    income = income! - (costItem.costType == CostType.income ? costItem.amount: 0);
  }
}