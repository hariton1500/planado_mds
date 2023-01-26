import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> checkKey(String key) async {
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/users'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }
}
