import 'package:attendance_app/screens/authenticate/register.dart';
import 'package:attendance_app/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool isSignIn = true;

  void toggleView() {
    setState(() {
      isSignIn = !isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
//    return isSignIn
//        ? SignIn(
//            toggleView: toggleView,
//          )
//        : Register(
//            toggleView: toggleView,
//          );
    return SignIn();
  }
}
