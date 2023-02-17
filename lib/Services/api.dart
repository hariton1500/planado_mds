import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlanadoAPI {
  String key = '';
  PlanadoAPI({String? auth}) {
    if (auth != null && auth != '') {
      key = auth;
    }
  }

  Future<String> getUsers() async {
    log('getting users; key = $key');
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/users'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //log(resp.body);
        return resp.body;
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
    return '';
  }

  Future<String> getUsersAndTeamsForChoose() async {
    log('getting users and teams for choose; key = $key');
    Map<String, dynamic> answer = {'users': [], 'teams': []};
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/users'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //log(resp.body);
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
        //log(resp.body);
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
      log(e.toString());
      return '';
    }
  }

  Future<String> getUserJobs(String userId, Function(int, int) callback) async {
    log('getting users jobs; user_id = $userId; key = $key');
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
      log(e.toString());
      return '';
    }
    return '';
  }

  Future<String> getFreeJobs() async {
    //key = authKey;
    log('getting free jobs; key=$key');
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
      log(e.toString());
      return '';
    }
    return '';
  }

  Future<String> getJob(String id) async {
    log('getting job; id = $id');
    try {
      String url = 'https://api.planadoapp.com/v2/jobs/$id';
      var resp = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //log(resp.body);
        return resp.body;
      } else {
        log(resp.body);
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
    return '';
  }

  Future<String> getJobType(String typeId) async {
    log('getting job type; typeId = $typeId');
    try {
      var resp = await http.get(
          Uri.parse('https://api.planadoapp.com/v2/job_types'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        Map<String, dynamic> decoded = jsonDecode(resp.body);
        //log(decoded['job_types']);
        return (decoded['job_types'] as List)
            .firstWhere((element) => element['uuid'] == typeId)['code'];
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
    return '';
  }

  Future<String> deleteJob(String jobId) async {
    log('delete job ID = $jobId');
    try {
      var resp = await http.delete(
          Uri.parse('https://api.planadoapp.com/v2/jobs/$jobId'),
          headers: {'Authorization': 'Bearer $key'});
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //Map<String, dynamic> decoded = jsonDecode(resp.body);
        return resp.body;
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
    return '';
  }

  Future<String> assigneeJob(
      {required Map<String, dynamic> job,
      required List<Map<String, dynamic>> assignees, DateTime? toDate, TimeOfDay? toTime}) async {
    log('assignee job = $job to assignees $assignees');
    log('to Date: $toDate, to Time: $toTime');
    try {
      //var list = targetIds.map((e) => {'uuid': e}).toList();
      String month = ((toDate ?? DateTime.now()).month < 10)
          ? '0${(toDate ?? DateTime.now()).month}'
          : (toDate ?? DateTime.now()).month.toString();
      String day = ((toDate ?? DateTime.now()).day < 10)
          ? '0${(toDate ?? DateTime.now()).day}'
          : (toDate ?? DateTime.now()).day.toString();
      job['assignee'] = assignees.first;
      job['assignees'] = assignees;
      String data = jsonEncode({
        'assignee': {'worker': assignees.first},
        'scheduled_at': "${(toDate ?? DateTime.now()).year}-$month-${day}T${toDate?.hour ?? 11}:${toDate?.minute ?? 00}:00.000Z"
      });
      //{'assignee': {'worker': {'uuid':targetIds.first}},
      //[{'worker': {'uuid': targetIds.first}}, {'worker': {'uuid': targetIds.last}}]
      log(data);
      var resp = await http.patch(
        Uri.parse('https://api.planadoapp.com/v2/jobs/${job['uuid']}'),
        headers: {'Authorization': 'Bearer $key'},
        body: data,
      );
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        //Map<String, dynamic> decoded = jsonDecode(resp.body);
        log(resp.body);
        return resp.body;
      } else {
        log(resp.body);
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
    return '';
  }
}
