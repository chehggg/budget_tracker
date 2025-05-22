// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Money Tracker';

  @override
  String get newFormTitle => 'New Entry';

  @override
  String get editFormTitle => 'Edit Entry';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get balance => 'Balance';

  @override
  String get settings => 'Settings';

  @override
  String get emptyListDisplay => 'Nothing here!';

  @override
  String get themeMode => 'Theme';

  @override
  String get currency => 'Currency';

  @override
  String get changeCurrency => 'Change Currency';

  @override
  String get searchCurrency => 'Search currency...';

  @override
  String get language => 'Language';

  @override
  String get blurSettings => 'Blur Amount When App Launch';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get categories =>
      '{\"sports\": \"Sports\", \"food\": \"Food\", \"transport\": \"Transport\", \"entertainment\": \"Entertainment\", \"car\": \"Car\", \"home\": \"Home\", \"gift\": \"Gift\", \"loan\": \"Loan\", \"grocery\": \"Grocery\", \"repair\": \"Repair\", \"education\": \"Education\", \"insurance\": \"Insurance\", \"medicine\": \"Medicine\", \"salary\": \"Salary\", \"partTime\": \"Part Time\", \"investment\": \"Investment\", \"bonus\": \"Bonus\", \"shopping\": \"Shopping\", \"luxury\": \"Luxury\", \"pet\": \"Pet\", \"travel\": \"Travel\", \"recreation\": \"Recreation\", \"charity\": \"Charity\"}';
}
