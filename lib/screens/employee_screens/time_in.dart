import 'package:attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class TimeIn extends StatefulWidget {
  @override
  _TimeInState createState() => _TimeInState();
}

class _TimeInState extends State<TimeIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time-in Screen"),
        actions: <Widget>[

        ],
      ),
    );
  }
}
