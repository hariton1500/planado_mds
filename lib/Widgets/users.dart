import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Screens/userscreen.dart';
import 'package:planado_mds/Services/api.dart';

class UsersWidget extends StatefulWidget {
  const UsersWidget({Key? key, required this.authKey}) : super(key: key);

  final String authKey;

  @override
  State<UsersWidget> createState() => _UsersWidgetState();
}

class _UsersWidgetState extends State<UsersWidget> {
  PlanadoAPI api = PlanadoAPI();

  @override
  void initState() {
    loadUsers();
    super.initState();
  }

  Map<String, dynamic> users = {};

  @override
  Widget build(BuildContext context) {
    if (users.containsKey('users')) {
      return ListView.builder(
          itemCount: (users['users'] as List).length,
          shrinkWrap: true,
          itemBuilder: (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue)),
                  child: Text(users['users'][index]['first_name'] +
                      ' ' +
                      users['users'][index]['last_name']),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserScreen(
                            user: users['users'][index], api: api)));
                  },
                ),
              ));
    }
    return Text(users.toString(),
    );
  }

  void loadUsers() {
    api.key = widget.authKey;
    api.getUsers().then((value) {
      //print(value);
      Map<String, dynamic> decoded = {};
      if (value != '') decoded = jsonDecode(value);
      setState(() {
        users = decoded;
      });
    });
  }
}
