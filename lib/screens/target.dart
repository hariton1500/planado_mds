import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:planado_mds/Services/api.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({Key? key, required this.api}) : super(key: key);
  final PlanadoAPI api;

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  @override
  void initState() {
    loadTargets();
    super.initState();
  }

  Map<String, dynamic> targets = {'worker': [], 'team': []};
  String targetType = 'worker';
  List<Map<String, dynamic>> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          TextButton.icon(
              onPressed: () {
                //log(selectedUuids);
                DateTime toDate;
                TimeOfDay toTime;
                showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7))).then((value) {
                  if (value != null) {
                    toDate = value;
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      }
                    ).then((value) {
                      if (value != null) {
                        toTime = value;
                        toDate = toDate.add(Duration(hours: toTime.hour - 3, minutes: toTime.minute)); // -3 hours to correct LocalTimeZone????
                        Navigator.of(context).pop([selected, toDate, toTime]);
                      }
                    });
                  }
                });
                
              },
              icon: const Icon(Icons.select_all),
              label: const Text('Assign to'))
        ]),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                  child: Column(
                children: targets.keys
                    .map((workerOrteam) => RadioListTile<String>(
                        title: Text(workerOrteam),
                        value: workerOrteam,
                        groupValue: targetType,
                        onChanged: (value) {
                          log(value.toString());
                          setState(() {
                            targetType = value!;
                            selected.clear();
                          });
                        }))
                    .toList(),
              )),
              Column(
                children: (targets[targetType] as List).map((e) {
                  return CheckboxListTile(
                      //tristate: true,
                      title: Text((e['name'] ?? '${e['first_name']} ${e['last_name']}').toString()),
                      value: selected.contains(e),
                      onChanged: (isChecked) {
                        log(isChecked.toString());
                        setState(() {
                          if (isChecked ?? false) {
                            selected.clear(); //rem for multiple selection
                            selected.add(e);
                          } else {
                            selected.remove(e);
                          }
                        });
                      });
                }).toList(),
              )
            ],
          ),
        ));
  }

  void loadTargets() async {
    widget.api.getUsersAndTeamsForChoose().then((value) {
      var decoded = jsonDecode(value);
      setState(() {
        log(value);
        targets['worker'] = decoded['users'];
        targets['team'] = decoded['teams'];
      });
    });
  }
}
