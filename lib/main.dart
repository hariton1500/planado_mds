import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planado_mds/Models/settings.dart';
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

  @override
  void initState() {
    loadPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        ElevatedButton.icon(
            onPressed: () {
              setState(() {
                tab = 'users';
              });
            },
            icon: const Icon(Icons.person),
            label: const Text('users')),
        ElevatedButton.icon(
            onPressed: () {
              setState(() {
                tab = 'teams';
              });
            },
            icon: const Icon(Icons.people),
            label: const Text('teams')),
        ElevatedButton.icon(
            onPressed: () {
              setState(() {
                tab = 'jobs';
              });
            },
            icon: const Icon(Icons.work),
            label: const Text('jobs')),
        ElevatedButton.icon(
            onPressed: () {
              setState(() {
                tab = 'map';
              });
            },
            icon: const Icon(Icons.map),
            label: const Text('map')),
      ]),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Setup(
                          settings: Settings(),
                        )));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (tab == 'users') ...[UsersWidget(authKey: authKey)],
            if (tab == 'teams') ...[const TeamsWidget()],
            if (tab == 'map') ...[const MapWidget()],
            if (tab == 'jobs') ...[JobsWidget(authKey: authKey)],
            if (tab == '') ...[
              RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      tab = 'users';
                    });
                    return Future.value();
                  },
                  child: const Icon(Icons.refresh))
            ]
          ],
        ),
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
}
