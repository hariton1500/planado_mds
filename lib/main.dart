import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:planado_mds/Services/api.dart';
import 'package:planado_mds/Services/settings.dart';
import 'package:planado_mds/Widgets/jobs.dart';
import 'package:planado_mds/Widgets/map.dart';
import 'package:planado_mds/Widgets/users.dart';
import 'package:planado_mds/Screens/setup/setup.dart';

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
  PlanadoAPI api = PlanadoAPI();
  Settings settings = Settings();
  String tab = '';
  //String authKey = '';
  Map<String, dynamic> users = {}, jobs = {};
  bool usersLoaded = false, jobsLoaded = false;

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
                        builder: (context) =>
                            Setup(settings: settings, api: api)))
                    .then((value) {
                  if (value != null && value != '') {
                    setState(() {
                      //api.key = value;
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UsersWidget(
                              api: api,
                              loadedUsers: users,
                            )));
                  },
                  icon: Icon(
                    Icons.person,
                    color: !usersLoaded ? Colors.white : Colors.green,
                  ),
                  label: const Text('users')),
            ),
          ),
          /*
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const TeamsWidget()));
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('teams')),
            ),
          ),
          */
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => JobsWidget(
                              api: api,
                              loadedJobs: jobs,
                            )));
                  },
                  icon: Icon(Icons.work,
                      color: !usersLoaded ? Colors.white : Colors.green),
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
                          builder: (context) => MapWidget(
                              api: api,
                              payload:
                                  jsonEncode({'jobs': jobs, 'users': users}))));
                    });
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('map')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadPrefs() async {
    Settings settings = Settings();
    api.key = await settings.load();
    //api.key = authKey;
    if (api.key == '') {
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Setup(settings: settings, api: api)));
    }
  }

  void loadData() async {
    log('waiting for 1 second');
    await Future.delayed(const Duration(seconds: 1));
    log('authKey now is ${api.key}');
    //PlanadoAPI api = PlanadoAPI(auth: authKey);
    api.getUsers().then((value) {
      try {
        users = jsonDecode(value);
        //filter users can do jobs------------------
        (users['users'] as List).removeWhere(
            (element) => !element['permissions']['mobile']['jobs']['complete']);
        //==========================================
        log('loaded ${(users['users'] as List).length} users');
        setState(() {
          usersLoaded = true;
        });
      } catch (e) {
        log(e.toString());
      }
    });
    api.getFreeJobs().then((value) {
      try {
        jobs = jsonDecode(value);
        log('loaded ${(jobs['jobs'] as List).length} free jobs');
        setState(() {
          jobsLoaded = true;
        });
      } catch (e) {
        log(e.toString());
      }
    });
  }
}
