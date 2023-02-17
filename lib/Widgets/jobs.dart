import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:planado_mds/Screens/target.dart';
import 'package:planado_mds/Services/api.dart';
import 'package:planado_mds/Screens/job.dart';

class JobsWidget extends StatefulWidget {
  const JobsWidget({Key? key, required this.api, required this.loadedJobs})
      : super(key: key);
  final PlanadoAPI api;
  final Map<String, dynamic> loadedJobs;

  @override
  State<JobsWidget> createState() => _JobsWidgetState();
}

class _JobsWidgetState extends State<JobsWidget> {
  //PlanadoAPI api = PlanadoAPI();

  Map<String, dynamic> jobs = {};
  bool showComments = true;
  bool isRefreshing = false;

  @override
  void initState() {
    log(
        'init of jobs. passed ${(widget.loadedJobs['jobs'] as List).length} jobs.');
    jobs = widget.loadedJobs;
    if (widget.loadedJobs.isEmpty) loadJobs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Non assigned jobs'),
          actions: [
            isRefreshing ? const RefreshProgressIndicator() :
            IconButton(
                onPressed: () {
                  setState(() {
                    isRefreshing = true;
                  });
                  loadJobs();
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: ListView.builder(
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
                                .push<List>(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TargetScreen(api: widget.api)))
                                .then((value) {
                              if (value != null) {
                                log(value.toString());
                                widget.api
                                    .assigneeJob(
                                        job: jobs['jobs'][index],
                                        assignees: value[0], toDate: value[1], toTime: value[2])
                                    .then((answer) {
                                  log(answer);
                                  if (answer.startsWith('{"job_uuid":"')) {
                                    setState(() {
                                      (jobs['jobs'] as List).removeAt(index);
                                    });
                                  }
                                });
                              }
                            });
                            break;
                          case 1:
                            widget.api
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
                            '${jobs['jobs'][index]['address']['formatted']}, k. ${jobs['jobs'][index]['address']['apartment'] ?? ''}'),
                        showComments
                            ? Text(jobs['jobs'][index]['description'] ?? '')
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
    widget.api.getFreeJobs().then((value) async {
      if (value != '') {
        Map<String, dynamic> decoded = {};
        decoded = jsonDecode(value);
        setState(() {
          jobs = decoded;
          isRefreshing = false;
        });
      } else {
        log('nothig');
      }
    });
  }
}
