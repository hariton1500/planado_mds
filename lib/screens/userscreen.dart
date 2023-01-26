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
    print(jobs);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['first_name']),
      ),
      body: jobs.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: (jobs['jobs'] as List).length,
              itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                colorOfJob(jobs['jobs'][index]['status']))),
                        onPressed: () {},
                        child: Text(jobs['jobs'][index].toString())),
                  ))
          : Container(),
    );
  }

  void loadJobs() {
    widget.api.getUserJobs(widget.user['uuid']).then((value) {
      if (value != '') {
        print(value);
        Map<String, dynamic> decoded = {};
        decoded = jsonDecode(value);
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
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
