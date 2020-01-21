import 'package:attendance_app/screens/authenticate/authenticate.dart';
import 'package:attendance_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({Key key, this.toggleView}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>();
  bool isPasswordMatched = true;
  bool isPasswordHidden = true;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Register'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              'Sign-in',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              widget.toggleView();
            },
          ),
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
                  FormBuilderTextField(
                    attribute: "confirm_password",
                    obscureText: isPasswordHidden,
                    maxLines: 1,
                    decoration: InputDecoration(labelText: "Confirm password"),
                    validators: [
                      FormBuilderValidators.maxLength(32),
                      FormBuilderValidators.minLength(6),
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
                    onPressed: () {
                      _fbKey.currentState.save();
                      setState(() {
                        isPasswordMatched =
                            _fbKey.currentState.value['password'].toString() ==
                                _fbKey.currentState.value['confirm_password']
                                    .toString();
                        errorMsg = isPasswordMatched
                            ? ""
                            : "Password does not matched!";
                      });
                      if (_fbKey.currentState.validate()) {
                        print(_fbKey.currentState.value);
                        if (!isPasswordMatched) {
                          print('password does not match');
                          return;
                        }
                        final email = _fbKey.currentState.value['email'];
                        final password = _fbKey.currentState.value['password'];
                        final result = AuthService()
                            .registerWithEmailAndPassword(email, password);
                        if (result == null) {
                          setState(() {
                            errorMsg = "Registration failure!";
                          });
                          print("$errorMsg");
                        }
                      } else {
                        print("validation failed");
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              errorMsg,
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
