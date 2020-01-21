import 'package:attendance_app/screens/wrapper.dart';
import 'package:attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value:  AuthService().user,
      child: MaterialApp(
        title: 'Attendance App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green[800],
        ),
        home: Wrapper(),
      ),
    );
  }
}
