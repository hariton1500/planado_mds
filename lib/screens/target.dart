import 'package:flutter/material.dart';
import 'package:planado_mds/Widgets/users.dart';

class TargetScreen extends StatelessWidget {
  const TargetScreen({Key? key, required this.authKey}) : super(key: key);
  final String authKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UsersWidget(authKey: authKey),
    );
  }
}
