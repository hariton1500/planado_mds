import 'package:flutter/material.dart';
import 'package:planado_mds/Models/settings.dart';

class Setup extends StatefulWidget {
  const Setup({Key? key, required this.settings}) : super(key: key);
  final Settings settings;

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  bool keyHasChanged = true;
  String key = '';
  bool isCheckOk = false;

  @override
  void initState() {
    widget.settings.load().then((value) => setState(() {
          key = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
              onPressed: () {
                widget.settings
                    .save(key)
                    .then((value) => Navigator.of(context).pop());
              },
              icon: Icon(
                Icons.save,
                color: isCheckOk ? Colors.green : Colors.black,
              ),
              label: const Text('Save'))
        ],
      ),
      body: Center(
        child: Column(children: [
          const Text('Authorization key:'),
          TextField(
            controller: TextEditingController(text: key),
            onChanged: (value) {
              key = value;
              setState(() {
                keyHasChanged = true;
              });
            },
          ),
          keyHasChanged
              ? TextButton.icon(
                  onPressed: () {
                    setState(() {
                      keyHasChanged = false;
                    });
                    widget.settings.checkKey(key).then((ok) {
                      if (ok) {
                        setState(() {
                          isCheckOk = true;
                        });
                      } else {
                        setState(() {
                          isCheckOk = false;
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Check it'))
              : Container()
        ]),
      ),
    );
  }
}
