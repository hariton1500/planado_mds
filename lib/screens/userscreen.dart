import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Services/api.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key, required this.user, required this.api})
      : super(key: key);

  final Map<String, dynamic> user;
  final PlanadoAPI api;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    loadJobs();
    super.initState();
  }

  Map<String, dynamic> jobs = {};

  @override
  Widget build(BuildContext context) {
    //print(jobs);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['first_name']),
      ),
      body: jobs.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: (jobs['jobs'] as List).length,
              itemBuilder: (context, index) {
                String type = '';
                //widget.api.getJobType(jobs['jobs'][index]['type_uuid']).then((value) => type = value);
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                colorOfJob(jobs['jobs'][index]['status']))),
                        onPressed: () {},
                        icon: Icon(getJobIcon(jobs['jobs'][index]['type']['code'])),
                        label: Column(
                          children: [
                            Text(jobs['jobs'][index]['type']['code'].toString()),
                            Text('${jobs['jobs'][index]['address']['formatted']}, k. ${jobs['jobs'][index]['address']['apartment']}'),
                            //Text(jobs['jobs'][index]['address'].toString())
                          ],
                        )),
                );})
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void loadJobs() {
    widget.api.getUserJobs(widget.user['uuid']).then((value) async {
      if (value != '') {
        print(value);
        Map<String, dynamic> decoded = {};
        decoded = jsonDecode(value);
        /*
        for (Map<String, dynamic> job in decoded['jobs']) {
          var answer = await widget.api.getJobType(job['type_uuid']);
          job['type'] = answer.toString();
        }*/
        setState(() {
          jobs = decoded;
        });
      } else {
        print('nothig');
      }
    });
  }

  Color colorOfJob(String status) {
    switch (status) {
      case 'published':
        return Colors.blue;
      case 'paused':
        return Colors.grey;
      case 'en_route':
        return Colors.lightBlueAccent;
      case 'started':
        return Colors.green[200]!;
      case 'finished':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData getJobIcon(String type) {
    switch (type) {
      case 'Подключение в многоэтажке':
        return Icons.plus_one;
      default: return Icons.construction;
    }
  }
}
