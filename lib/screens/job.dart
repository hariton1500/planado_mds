
import 'package:flutter/material.dart';

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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Text(widget.job.toString()),
      ),
    );
  }
}