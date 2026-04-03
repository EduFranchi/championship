import 'package:shared_preferences/shared_preferences.dart';

class CustomSharedPrefs {
  static Future<void> setWinValue(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('winValue', value);
  }

  static Future<int?> getWinValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('winValue');
  }

  static Future<void> setDrawValue(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('drawValue', value);
  }

  static Future<int?> getDrawValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('drawValue');
  }
}
