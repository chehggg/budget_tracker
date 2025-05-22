// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get title => 'わかない';

  @override
  String get newFormTitle => '新しい予算';

  @override
  String get editFormTitle => '予算修正';

  @override
  String get amount => '額';

  @override
  String get date => '日付';

  @override
  String get note => 'メモ';

  @override
  String get expense => '支出';

  @override
  String get income => '収入';

  @override
  String get balance => '残高';

  @override
  String get settings => '設置';

  @override
  String get emptyListDisplay => 'ここ何もない！';

  @override
  String get themeMode => 'テーマ';

  @override
  String get currency => '貨幣';

  @override
  String get changeCurrency => '貨幣変更';

  @override
  String get searchCurrency => 'ここ貨幣検索しよう...';

  @override
  String get language => '言語';

  @override
  String get blurSettings => 'Blur Amount When App Launch';

  @override
  String get changeLanguage => '言語変更';

  @override
  String get categories =>
      '{\"sports\": \"スポーツ\", \"food\": \"食事\", \"transport\": \"交通\", \"entertainment\": \"娯楽\", \"car\": \"車\", \"home\": \"家庭\", \"gift\": \"ギフト\", \"loan\": \"贷款\", \"grocery\": \"ショッピング\", \"repair\": \"修理\", \"education\": \"教育\", \"insurance\": \"保険\", \"medicine\": \"治療\", \"salary\": \"給料\", \"partTime\": \"アパート\", \"investment\": \"投資\", \"bonus\": \"ボーナス\"}';
}
