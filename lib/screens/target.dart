import 'dart:convert';

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
  List<String> selectedUuids = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          TextButton.icon(
              onPressed: () {
                //print(selectedUuids);
                Navigator.of(context).pop({targetType: selectedUuids});
              },
              icon: const Icon(Icons.select_all),
              label: const Text('Assignee'))
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
                          print(value);
                          setState(() {
                            targetType = value!;
                            selectedUuids.clear();
                          });
                        }))
                    .toList(),
              )),
              Column(
                children: (targets[targetType] as List).map((e) {
                  return CheckboxListTile(
                      //tristate: true,
                      title: Text(e['name'].toString()),
                      value: selectedUuids.contains(e['uuid']),
                      onChanged: (isChecked) {
                        print(isChecked);
                        setState(() {
                          if (isChecked ?? false) {
                            selectedUuids.add(e['uuid']);
                          } else {
                            selectedUuids.remove(e['uuid']);
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
        print(value);
        targets['worker'] = decoded['users'];
        targets['team'] = decoded['teams'];
      });
    });
  }
}
