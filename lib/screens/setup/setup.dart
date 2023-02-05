import 'package:flutter/material.dart';
import 'package:planado_mds/Services/api.dart';
import 'package:planado_mds/Services/settings.dart';

class Setup extends StatefulWidget {
  const Setup({Key? key, required this.settings, required this.api})
      : super(key: key);
  final Settings settings;
  final PlanadoAPI api;

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  bool keyHasChanged = true;
  bool isCheckOk = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
              onPressed: () {
                widget.settings
                    .save(widget.api.key)
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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  labelText: 'Authorization key:',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
              maxLines: 3,
              minLines: 2,
              controller: TextEditingController(text: widget.api.key),
              onChanged: (value) {
                widget.api.key = value;
              },
            ),
          ),
          TextButton.icon(
              onPressed: () {
                setState(() {
                  keyHasChanged = false;
                });
                widget.api.getUsers().then((ok) {
                  if (ok.startsWith('')) {
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
              label: const Text('Check?'))
        ]),
      ),
    );
  }
}
