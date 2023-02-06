import 'dart:convert';

import 'package:http/http.dart' as http;

class PlanadoAPI {
  String key = '';
  PlanadoAPI({String? auth}) {
    if (auth != null && auth != '') {
      key = auth;
    }
  }

  Future<String> getUsers() async {
    print('getting users; key = $key');
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/users'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //print(resp.body);
        return resp.body;
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }

  Future<String> getUsersAndTeamsForChoose() async {
    print('getting users and teams for choose; key = $key');
    Map<String, dynamic> answer = {'users': [], 'teams': []};
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/users'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //print(resp.body);
        var decoded = jsonDecode(resp.body);
        /*
        for (var element in decoded['users']) {
          (answer['users'] as List).add({
            'uuid': element['uuid'],
            'name': '${element['first_name']} ${element['last_name']}'
          });
        }*/
        answer['users'] = decoded['users'];
      }
      resp = await http.get(Uri.parse('https://api.planadoapp.com/v2/teams'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //print(resp.body);
        var decoded = jsonDecode(resp.body);
        answer['teams'] = decoded['teams'];
        /*
        for (var element in decoded['teams']) {
          (answer['teams'] as List)
              .add({'uuid': element['uuid'], 'name': element['name']});
        }*/
      }
      return jsonEncode(answer);
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<String> getUserJobs(String userId, Function(int, int) callback) async {
    print('getting users jobs; user_id = $userId; key = $key');
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
        callback(0, (decoded['jobs'] as List).length);
        for (var job in decoded['jobs']) {
          var respJob = await getJob(job['uuid']);
          if (respJob != '') {
            (jobs['jobs'] as List).add(jsonDecode(respJob)['job']);
            callback((jobs['jobs'] as List).length,
                (decoded['jobs'] as List).length);
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

  Future<String> getFreeJobs() async {
    //key = authKey;
    print('getting free jobs; key=$key');
    Map<String, dynamic> jobs = {'jobs': []};
    try {
      String url =
          'https://api.planadoapp.com/v2/jobs?status[]=posted&status[]=scheduled';
      //url = 'https://api.planadoapp.com/v2/jobs?external_order_id=R-00362473';
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

  Future<String> deleteJob(String jobId) async {
    print('delete job ID = $jobId');
    try {
      var resp = await http.delete(
          Uri.parse('https://api.planadoapp.com/v2/jobs/$jobId'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //Map<String, dynamic> decoded = jsonDecode(resp.body);
        return resp.body;
      }
    } catch (e) {
      print(e);
      return '';
    }
    return '';
  }

  Future<String> assigneeJob(
      {required Map<String, dynamic> job,
      required List<Map<String, dynamic>> assignees}) async {
    print('assignee job = $job to assignees $assignees');
    try {
      //var list = targetIds.map((e) => {'uuid': e}).toList();
      String month = (DateTime.now().month < 10)
          ? '0${DateTime.now().month}'
          : DateTime.now().month.toString();
      String day = (DateTime.now().day < 10)
          ? '0${DateTime.now().day}'
          : DateTime.now().day.toString();
      job['assignee'] = assignees.first;
      job['assignees'] = assignees;
      String data = jsonEncode({
        'assignee': {'worker': assignees.first},
        'scheduled_at': "${DateTime.now().year}-$month-${day}T11:00:00.000Z"
      });
      //{'assignee': {'worker': {'uuid':targetIds.first}},
      //[{'worker': {'uuid': targetIds.first}}, {'worker': {'uuid': targetIds.last}}]
      print(data);
      var resp = await http.patch(
        Uri.parse('https://api.planadoapp.com/v2/jobs/${job['uuid']}'),
        headers: {'Authorization': 'Bearer $key'},
        body: data,
      );
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //Map<String, dynamic> decoded = jsonDecode(resp.body);
        print(resp.body);
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
}
