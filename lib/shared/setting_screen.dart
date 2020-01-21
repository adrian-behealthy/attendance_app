import 'package:attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              onPressed: () {
                AuthService().logout();
              },
              icon: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
