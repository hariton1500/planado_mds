import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planado_mds/Models/settings.dart';
import 'package:planado_mds/Services/api.dart';
import 'package:planado_mds/Widgets/jobs.dart';
import 'package:planado_mds/Widgets/map.dart';
import 'package:planado_mds/Widgets/teams.dart';
import 'package:planado_mds/Widgets/users.dart';
import 'package:planado_mds/Screens/setup/setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planado MDS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            //toolbarTextStyle: TextStyle(color: Colors.black)
          )),
      home: const MyHomePage(title: ' for managers, dispatchers and SEO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String tab = '';
  String authKey = '';
  var payload;
  Map<String, dynamic> users = {}, jobs = {};

  @override
  void initState() {
    loadPrefs();
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Image.asset('assets/images/planado1.png'),
            Text(widget.title),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => Setup(
                              settings: Settings(),
                            )))
                    .then((value) {
                  if (value != null && value != '') {
                    setState(() {
                      authKey = value;
                    });
                  }
                });
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UsersWidget(authKey: authKey, loadedUsers: users,)));
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('users')),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TeamsWidget()));
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('teams')),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobsWidget(authKey: authKey, loadedJobs: jobs,)));
                  },
                  icon: const Icon(Icons.work),
                  label: const Text('jobs')),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      tab = 'map';
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              MapWidget(authKey: authKey, payload: payload ?? '')));
                    });
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('map')
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authKey')) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Setup(
                settings: Settings(),
              )));
    } else {
      authKey = prefs.getString('authKey') ?? '';
      //print(authKey);
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          tab = 'users';
        });
      });
    }
  }
  
  void loadData() async{
    print('waiting for 1 second');
    await Future.delayed(const Duration(seconds: 1));
    print('authKey now is $authKey');
    PlanadoAPI api = PlanadoAPI(auth: authKey);
    api.getUsers().then((value) {
      try {
        users = jsonDecode(value);
        //filter users can do jobs------------------
        (users['users'] as List).removeWhere(
            (element) => !element['permissions']['mobile']['jobs']['complete']);
        //==========================================
     } catch (e) {
        print(e);
      }
    });
    api.getFreeJobs(authKey).then((value) {
      try {
        jobs = jsonDecode(value);
      } catch (e) {
        print(e);
      }
    });
  }
}
