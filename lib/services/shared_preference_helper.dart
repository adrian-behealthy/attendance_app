import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static Future<bool> getIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get("isAdmin");
  }

  static Future setIsAdmin(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool("isAdmin", isAdmin ?? false);
  }
}
