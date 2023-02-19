import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:planado_mds/Helpers/color.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key, required this.job}) : super(key: key);

  final Map<String, dynamic> job;

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.job);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job['template']['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          tileColor: colorOfJob(widget.job['status'],
              widget.job['resolution']?['successful'] ?? false),
          shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          leading: Column(
            children: [
              Text(DateTime.parse(widget.job['scheduled_at']).toLocal().toString()),
              Text('${((widget.job['scheduled_duration']['minutes'] / 60) as double).toStringAsFixed(1).toString()} hours')
            ],
          ),
          title: Text(widget.job['address']['formatted'] +
              ', k. ' +
              widget.job['address']?['apartment'].toString()),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.job['resolution']?['name'] ?? ''),
              Text(widget.job['description'] ?? ''),
              (widget.job['contacts'] as List).isNotEmpty ? Text(widget.job['contacts'][0]['value']) : Container(),
              //Text(widget.job.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
