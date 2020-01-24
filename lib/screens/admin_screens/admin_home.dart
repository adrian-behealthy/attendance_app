import 'dart:async';

import 'package:attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with WidgetsBindingObserver {
  Timer getTimer;
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    executeDateObserver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Today's log"),
        ),
        body: Text("${currentTime.toIso8601String()}"));
  }

  /// check app state resume or inactive.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      executeDateObserver();
    }
    if (state == AppLifecycleState.inactive) {
      getTimer.cancel();
    }
  }

  executeDateObserver() {
    getTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => _getDate());
  }

  void _getDate() {
    final timeNow = DateTime.now();
    if (timeNow.difference(currentTime).inSeconds > 0) {
      setState(() {
        currentTime = timeNow;
      });
    }
    return;
  }

  @override
  void dispose() {
    super.dispose();
    getTimer.cancel();
  }
}
