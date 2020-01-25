import 'package:attendance_app/services/management_service.dart';
import 'package:attendance_app/shared/password_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class UserRegistrationScreen extends StatefulWidget {
  static final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>();

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  bool isButtonDisabled = false;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        FormBuilder(
          key: UserRegistrationScreen._fbKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "Register user",
                  style: Theme.of(context).primaryTextTheme.headline.copyWith(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                FormBuilderTextField(
                  attribute: "first_name",
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "First name"),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(70),
                  ],
                ),
                FormBuilderTextField(
                  attribute: "last_name",
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Last name"),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(70),
                  ],
                ),
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
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MaterialButton(
                color: Colors.grey,
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                disabledColor: Colors.blueGrey,
                onPressed: isButtonDisabled
                    ? null
                    : () async {
                        UserRegistrationScreen._fbKey.currentState.save();

                        if (UserRegistrationScreen._fbKey.currentState
                            .validate()) {
                          setState(() {
                            isButtonDisabled = true;
                          });
                          print(
                              UserRegistrationScreen._fbKey.currentState.value);
                          final firstName = UserRegistrationScreen
                              ._fbKey.currentState.value['first_name'];
                          final lastName = UserRegistrationScreen
                              ._fbKey.currentState.value['last_name'];

                          final email = UserRegistrationScreen
                              ._fbKey.currentState.value['email'];
                          final password = PasswordGenerator.generate(8);
                          print('Password: $password');
                          final bool confirmResult = await showDialog(
                              context: context,
                              builder: (builder) {
                                return AlertDialog(
                                  title: Text("Generated password"),
                                  content: Wrap(
                                    children: <Widget>[
                                      Text("Email : $email"),
                                      Text(
                                        "Password : $password",
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    RaisedButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                    ),
                                    RaisedButton(
                                      child: Text(
                                        "Confirm",
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      color: Colors.redAccent,
                                    ),
                                  ],
                                );
                              });
                          if (confirmResult) {
                            setState(() {
                              isButtonDisabled = false;
                            });
                          }
//                        Navigator.pop(context);
                          final result = ManagementService().registerNewUser(
                              email, password, firstName, lastName);
                          if (result == null) {
                            if (this.mounted) {
                              setState(() {
                                errorMsg = "Registration failure!";
                              });
                            }
                            print("$errorMsg");
                            setState(() {
                              isButtonDisabled = false;
                            });
                          }
                          Navigator.pop(context);
                        } else {
                          print("validation failed");
                          setState(() {
                            isButtonDisabled = false;
                          });
                        }
                      },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          errorMsg,
          style: TextStyle(color: Colors.red),
        )
      ],
    );
  }
}
