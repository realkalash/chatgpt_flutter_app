import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getOpenAiConfig() {
    return _prefs.getString('openAiConfig');
  }

  static Future<bool> setOpenAiConfig(String config) {
    return _prefs.setString('openAiConfig', config);
  }
}
