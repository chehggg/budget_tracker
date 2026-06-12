import 'dart:convert';

import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedItemServices {
  final pref = SharedPreferencesAsync();
  final prefKey = "savedItem";

  Future<Result<List<SavedItem>>> loadSavedItems() async {
    try {
      final prefString = await pref.getString(prefKey);
      if (prefString == null) return Result.ok([]);

      final results =
          (jsonDecode(prefString) as List<dynamic>)
              .map((el) => SavedItem.fromJson(el as Map<String, dynamic>))
              .toList();
      return Result.ok(results);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> writeSavedItems(List<SavedItem> items) async {
    try {
      final json = items.map((SavedItem el) => el.toJson()).toList();
      await pref.setString(prefKey, jsonEncode(json));
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
