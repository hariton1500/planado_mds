import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  String authKey = '';

  Settings();

  Future<void> save(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('authKey', key);
    authKey = key;
  }

  Future<String> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authKey') ?? '';
  }
}
