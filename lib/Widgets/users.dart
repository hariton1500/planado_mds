import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Screens/userscreen.dart';
import 'package:planado_mds/Services/api.dart';

class UsersWidget extends StatefulWidget {
  const UsersWidget({Key? key, required this.api, required this.loadedUsers})
      : super(key: key);

  final PlanadoAPI api;
  final Map<String, dynamic> loadedUsers;

  @override
  State<UsersWidget> createState() => _UsersWidgetState();
}

class _UsersWidgetState extends State<UsersWidget> {
  //PlanadoAPI api = PlanadoAPI();

  @override
  void initState() {
    setState(() {
      users = widget.loadedUsers;
    });
    if (widget.loadedUsers.isEmpty) loadUsers();
    super.initState();
  }

  Map<String, dynamic> users = {};

  @override
  Widget build(BuildContext context) {
    if (users.containsKey('users')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workers'),
        ),
        body: ListView.builder(
            itemCount: (users['users'] as List).length,
            shrinkWrap: true,
            itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 30),
                  child: ListTile(
                    dense: true,
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserScreen(
                              user: users['users'][index], api: widget.api)));
                    },
                    title: Text(users['users'][index]['first_name'] +
                        ' ' +
                        users['users'][index]['last_name']),
                  ),
                )),
      );
    } else {
      return const Expanded(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }
  }

  void loadUsers() {
    //api.key = widget.authKey;
    widget.api.getUsers().then((value) {
      //log(value);
      Map<String, dynamic> decoded = {};
      if (value != '') decoded = jsonDecode(value);
      //filter users can do jobs------------------
      (decoded['users'] as List).removeWhere(
          (element) => !element['permissions']['mobile']['jobs']['complete']);
      //==========================================
      setState(() {
        users = decoded;
      });
    });
  }
}
