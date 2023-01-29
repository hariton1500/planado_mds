import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Screens/target.dart';
import 'package:planado_mds/Services/api.dart';
import 'package:planado_mds/Screens/job.dart';

class JobsWidget extends StatefulWidget {
  const JobsWidget({Key? key, required this.authKey}) : super(key: key);
  final String authKey;

  @override
  State<JobsWidget> createState() => _JobsWidgetState();
}

class _JobsWidgetState extends State<JobsWidget> {
  PlanadoAPI api = PlanadoAPI();

  Map<String, dynamic> jobs = {};
  bool showComments = true;

  @override
  void initState() {
    loadJobs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: (jobs['jobs'] as List).length,
            itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              JobScreen(job: jobs['jobs'][index])));
                    },
                    trailing: PopupMenuButton<int>(
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            Navigator.of(context)
                                .push<List<Map<String, dynamic>>>(MaterialPageRoute(
                                    builder: (context) =>
                                        TargetScreen(api: api)))
                                .then((value) {
                              if (value != null) {
                                print(value);
                                api.assigneeJob(
                                    job: jobs['jobs'][index],
                                    assignees: value
                                );
                              }
                            });
                            break;
                          case 1:
                            api
                                .deleteJob(jobs['jobs'][index]['uuid'])
                                .then((value) {
                              if (value == '{"message":"Performed"}') {
                                setState(() {
                                  (jobs['jobs'] as List).removeAt(index);
                                });
                              }
                            });
                            break;
                          default:
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text('Assign to'),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    title: Text(jobs['jobs'][index]['template']['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${jobs['jobs'][index]['address']['formatted']}, k. ${jobs['jobs'][index]['address']['apartment']}'),
                        showComments
                            ? Text(jobs['jobs'][index]['description'])
                            : Container()
                      ],
                    ),
                  ),
                )),
      );
    } else {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
  }

  void loadJobs() {
    api.getFreeJobs(widget.authKey).then((value) async {
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
}
