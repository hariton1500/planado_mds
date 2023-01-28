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
  Map<String, dynamic> targets = {};
  @override
  void initState() {
    loadTargets();
    super.initState();
  }

  String targetType = 'users';
  Map<String, bool> checks = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: ListView(
          children: targets.keys.map((usersOrTeams) => RadioListTile<String>(
            title: Column(children: (targets[usersOrTeams] as List).map((e) {
              return CheckboxListTile(tristate: true, title: Text(e['name'].toString()), value: checks[e['uuid'] ?? false], onChanged: (isChecked){
                print(isChecked);
                setState(() {
                  checks[e['uuid']] = true;
                });
              });
            }).toList(),
            ),
            value: usersOrTeams,
            groupValue: targetType,
            onChanged: (value){
              print(value);
              setState(() {
                targetType = value!;
              });
            }
          )).toList(),
        )
      ),
    );    
  }

  void loadTargets() async{
    widget.api.getUsersAndTeamsForChoose().then((value) {
      setState(() {
        targets = jsonDecode(value);
      });
    });
  }

}

