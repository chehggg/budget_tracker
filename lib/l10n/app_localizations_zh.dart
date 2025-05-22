// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get title => '记账APP';

  @override
  String get newFormTitle => '新预算';

  @override
  String get editFormTitle => '更改预算';

  @override
  String get amount => '数额';

  @override
  String get date => '日期';

  @override
  String get note => '注释';

  @override
  String get expense => '费用';

  @override
  String get income => '收入';

  @override
  String get balance => '存款';

  @override
  String get settings => '设定';

  @override
  String get emptyListDisplay => '这里没有东西!';

  @override
  String get themeMode => '模式';

  @override
  String get currency => '货币';

  @override
  String get changeCurrency => '更换货币';

  @override
  String get searchCurrency => '搜索货币...';

  @override
  String get language => '语言';

  @override
  String get blurSettings => 'Blur Amount When App Launch';

  @override
  String get changeLanguage => '更换语言';

  @override
  String get categories =>
      '{\"sports\": \"运动\", \"food\": \"饮食\", \"transport\": \"交通\", \"entertainment\": \"娱乐\", \"car\": \"车费\", \"home\": \"家用\", \"gift\": \"送礼\", \"loan\": \"贷款\", \"grocery\": \"Grocery\", \"repair\": \"维修\", \"education\": \"教育\", \"insurance\": \"保险\", \"medicine\": \"医疗\", \"salary\": \"工资\", \"partTime\": \"兼职\", \"investment\": \"投资\", \"bonus\": \"花红\"}';
}
