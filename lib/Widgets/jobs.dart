import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Services/api.dart';
import 'package:planado_mds/Widgets/users.dart';

class JobsWidget extends StatefulWidget {
  const JobsWidget({Key? key, required this.authKey}) : super(key: key);
  final String authKey;

  @override
  State<JobsWidget> createState() => _JobsWidgetState();
}

class _JobsWidgetState extends State<JobsWidget> {
  PlanadoAPI api = PlanadoAPI();

  Map<String, dynamic> jobs = {};

  @override
  void initState() {
    loadJobs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //return Center(child: Text(jobs.toString()),);
    /*
    return ListBody(
      children: (jobs['jobs'] as List)
          .map((job) => ListTile(
                title: Text(job['template']['name']),
                subtitle: Text(
                    job['address']['formatted'] + job['address']['apartment']),
              ))
          .toList(),
    );*/

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
                    onTap: () {},
                    trailing: PopupMenuButton<int>(
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Material(
                                    child:
                                        UsersWidget(authKey: widget.authKey))));
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
                    subtitle: Text(jobs['jobs'][index]['address']['formatted'] +
                        ', k. ' + jobs['jobs'][index]['address']?['apartment'].toString()),
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
