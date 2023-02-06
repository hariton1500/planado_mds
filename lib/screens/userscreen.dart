import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Helpers/color.dart';
import 'package:planado_mds/Screens/job.dart';
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
  Map<String, int> jobsCounter = {};
  bool showComments = false;
  int done = 0, all = 0;
  //Function? back;

  void loadJobs() {
    widget.api.getUserJobs(widget.user['uuid'], ((p0, p1) {
      print('$p0, $p1');
      setState(() {
        done = p0;
        all = p1;
      });
    })).then((value) async {
      if (value != '') {
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

  @override
  Widget build(BuildContext context) {
    //print(jobs);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['first_name'] + ' ' + widget.user['last_name']),
        actions: [
          TextButton.icon(
              onPressed: () {
                setState(() {
                  showComments = !showComments;
                });
              },
              icon: const Icon(Icons.fact_check),
              label: const Text('Comments'))
        ],
      ),
      body: jobs.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: (jobs['jobs'] as List).length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    tileColor: colorOfJob(
                        jobs['jobs'][index]['status'],
                        jobs['jobs'][index]['resolution']?['successful'] ??
                            false),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              JobScreen(job: jobs['jobs'][index])));
                    },
                    leading:
                        Icon(getJobIcon(jobs['jobs'][index]['type']['code'])),
                    title: Text(jobs['jobs'][index]['type']['code'].toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${jobs['jobs'][index]['address']['formatted']}, k. ${jobs['jobs'][index]['address']['apartment']}'),
                        showComments
                            ? Text(
                                jobs['jobs'][index]['description'].toString())
                            : Container()
                      ],
                    ),
                  ),
                );
              })
          : Center(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                value: done / (all == 0 ? 1 : all),
              ),
            )),
    );
  }
}
