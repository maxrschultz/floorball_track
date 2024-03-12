import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShootingMainPage extends StatelessWidget {
  const ShootingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return Scaffold(
      appBar: AppBar(
        title: Text('not available yet'),
      ),
      body: Center(
        child: Text('shooting stat not implemented yet'),
      ),
    );
  }
}