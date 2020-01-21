import 'package:attendance_app/models/user.dart';
import 'package:attendance_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SignIn extends StatefulWidget {
//  final Function toggleView;
//
//  const SignIn({Key key, this.toggleView}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>();
  bool isPasswordHidden = true;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Sign-in'),
        actions: <Widget>[
//          FlatButton.icon(
//            icon: Icon(
//              Icons.person,
//              color: Colors.white,
//            ),
//            label: Text(
//              'Register',
//              style: TextStyle(color: Colors.white),
//            ),
//            onPressed: () {
//              widget.toggleView();
//            },
//          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0),
        child: ListView(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "email",
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "Email"),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                      FormBuilderValidators.maxLength(70),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FormBuilderTextField(
                          attribute: "password",
                          obscureText: isPasswordHidden,
                          maxLines: 1,
                          decoration: InputDecoration(labelText: "Password"),
                          validators: [
                            FormBuilderValidators.maxLength(32),
                            FormBuilderValidators.minLength(6),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      setState(() {
                        errorMsg = "";
                      });
                      _fbKey.currentState.save();
                      if (_fbKey.currentState.validate()) {
                        print(_fbKey.currentState.value);
                        final email = _fbKey.currentState.value['email'].toString().trim();
                        final password = _fbKey.currentState.value['password'].toString().trim();

                        User user = await AuthService()
                            .signInWithEmailAndPassword(email, password);
                        if (user == null) {
                          print("error in sining in");
                          setState(() {
                            errorMsg = "Signing failed";
                          });
                          return;
                        }
                      } else {
                        print("validation failed");
                      }
                    },
                  ),
                ),
              ],
            ),
            Text(
              '$errorMsg',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height: 10.0,
            ),
            InkWell(
              onTap: () {},
              child: Text(
                "Forgot password",
                style: TextStyle(color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
