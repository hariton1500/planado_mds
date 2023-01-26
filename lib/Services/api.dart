import 'package:http/http.dart' as http;

class PlanadoAPI {
  String key = '';
  PlanadoAPI();

  Future<String> getUsers() async {
    print('getting users; key = $key');
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/users'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return resp.body;
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }

  Future<String> getUserJobs(String userId) async {
    print('getting users; key = $key');
    try {
      String month = (DateTime.now().month < 10)
          ? '0${DateTime.now().month}'
          : DateTime.now().month.toString();
      String day = (DateTime.now().day < 10)
          ? '0${DateTime.now().day}'
          : DateTime.now().day.toString();
      String url =
          'https://api.planadoapp.com/v2/jobs?assignee[worker_uuid]=$userId&scheduled_at[after]=${DateTime.now().year}-$month-${day}T00:00:00Z&scheduled_at[before]=${DateTime.now().year}-$month-${day}T23:59:59Z';
      print(url);
      var resp = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return resp.body;
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }
}
