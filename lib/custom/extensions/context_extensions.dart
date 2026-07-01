import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/models/navigator_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/currency_viewmodel.dart';
import 'package:budget_tracker/screens/settings/ex_rate_viewmodel.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/ui/form/form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_list_viewmodel.dart';
import 'package:budget_tracker/ui/list/main_list_viewmodel.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_viewmodel.dart';
import 'package:budget_tracker/ui/settings/setting_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension BuildContextExtension on BuildContext {
  ThemeData get _theme => Theme.of(this);
  NavigatorState get nav => Navigator.of(this);
  TextTheme get tt => _theme.textTheme;
  ColorScheme get cs => _theme.colorScheme;
  MyTexts get customTt => _theme.extension<MyTexts>()!;
  MyColors get customCs => _theme.extension<MyColors>()!;

  MediaQueryData get mq => MediaQuery.of(this);

  // AppModel get appMod => read<AppModel>();
  NavigatorModel get navMod => read<NavigatorModel>();
  FormViewModel get formMod => read<FormViewModel>();
  ThemeModel get themeMod => read<ThemeModel>();
  ListViewModel get listMod => read<ListViewModel>();
  GoalViewModel get goalMod => read<GoalViewModel>();
  GoalFormViewmodel get goalFormMod => read<GoalFormViewmodel>();
  GoalInfoViewmodel get goalInfoMod => read<GoalInfoViewmodel>();
  SettingsViewModel get settingMod => read<SettingsViewModel>();
  SavedItemViewModel get savedItemMod => read<SavedItemViewModel>();
  ChartViewModel get chartMod => read<ChartViewModel>();
  CurrencyViewModel get currencyMod => read<CurrencyViewModel>();
  ExRateViewModel get exRateMod => read<ExRateViewModel>();

  void showSuccessNotification({required String message, String? title}) {
    Flushbar(
      title: title,
      message: message,
      icon: const Icon(Icons.check, color: Colors.white),
      backgroundColor: Colors.green.shade900,
      duration: const Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 400),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      borderRadius: BorderRadius.circular(8),
      // boxShadows: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
    ).show(this);
  }

  void showErrorNotification({required String message, String? title}) {
    Flushbar(
      title: title,
      message: message,
      icon: const Icon(Icons.error_outline_outlined, color: Colors.white),
      backgroundColor: Colors.red.shade800,
      duration: const Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 400),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      borderRadius: BorderRadius.circular(8),
      // boxShadows: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
    ).show(this);
  }
}
