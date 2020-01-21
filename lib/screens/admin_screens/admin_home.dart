import 'package:attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin"),
        actions: <Widget>[
//          FlatButton.icon(
//              onPressed: () {
//                AuthService().logout();
//              },
//              icon: Icon(Icons.person),
//              label: Text("Logout"))
        ],
      ),
    );
  }
}
