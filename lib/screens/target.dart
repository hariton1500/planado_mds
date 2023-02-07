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
                Navigator.of(context).pop(selected);
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
