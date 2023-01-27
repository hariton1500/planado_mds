import 'dart:convert';

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
    print('getting users jobs; key = $userId');
    Map<String, dynamic> jobs = {'jobs': []};
    try {
      String month = (DateTime.now().month < 10)
          ? '0${DateTime.now().month}'
          : DateTime.now().month.toString();
      String day = (DateTime.now().day < 10)
          ? '0${DateTime.now().day}'
          : DateTime.now().day.toString();
      String url =
          'https://api.planadoapp.com/v2/jobs?assignee[worker_uuid]=$userId&scheduled_at[after]=${DateTime.now().year}-$month-${day}T00:00:00Z&scheduled_at[before]=${DateTime.now().year}-$month-${day}T23:59:59Z';
      var resp = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //return resp.body;
        Map<String, dynamic> decoded = jsonDecode(resp.body);
        for (var job in decoded['jobs']) {
          var respJob = await getJob(job['uuid']);
          if (respJob != '') {
            (jobs['jobs'] as List).add(jsonDecode(respJob)['job']);
          }
        }
        return jsonEncode(jobs);
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }

  Future<String> getFreeJobs(String authKey) async {
    key = authKey;
    print('getting free jobs; key=$authKey');
    Map<String, dynamic> jobs = {'jobs': []};
    try {
      String month = (DateTime.now().month < 10)
          ? '0${DateTime.now().month}'
          : DateTime.now().month.toString();
      String day = (DateTime.now().day < 10)
          ? '0${DateTime.now().day}'
          : DateTime.now().day.toString();
      String url = 'https://api.planadoapp.com/v2/jobs?status[]=posted&status[]=scheduled';
      //url = 'https://api.planadoapp.com/v2/jobs?external_order_id=R-00362473';
      var resp = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $authKey'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //return resp.body;
        Map<String, dynamic> decoded = jsonDecode(resp.body);
        for (var job in decoded['jobs']) {
          var respJob = await getJob(job['uuid']);
          if (respJob != '') {
            (jobs['jobs'] as List).add(jsonDecode(respJob)['job']);
          }
        }
        return jsonEncode(jobs);
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }

  Future<String> getJob(String id) async {
    print('getting job; id = $id');
    try {
      String url = 'https://api.planadoapp.com/v2/jobs/$id';
      var resp = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //print(resp.body);
        return resp.body;
      } else {
        print(resp.body);
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }

  Future<String> getJobType(String typeId) async {
    print('getting job type; typeId = $typeId');
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/job_types'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        Map<String, dynamic> decoded = jsonDecode(resp.body);
        //print(decoded['job_types']);
        return (decoded['job_types'] as List)
            .firstWhere((element) => element['uuid'] == typeId)['code'];
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }
}
