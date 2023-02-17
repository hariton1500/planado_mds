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
          title: Text(widget.job['address']['formatted'] +
              ', k. ' +
              widget.job['address']?['apartment'].toString()),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.job['resolution']?['name'] ?? ''),
              Text(widget.job['description'] ?? ''),
              //Text(widget.job.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
