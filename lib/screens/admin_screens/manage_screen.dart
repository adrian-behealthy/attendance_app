import 'package:attendance_app/services/auth_service.dart';
import 'package:attendance_app/services/management_service.dart';
import 'package:attendance_app/shared/password_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ManageScreen extends StatefulWidget {
  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  static final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>();
  bool isPasswordMatched = true;
  bool isPasswordHidden = true;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User management"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: Text("Loading.."),
            );
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemExtent: 80.0,
            itemBuilder: (context, index) =>
                _buildList(context, snapshot.data.documents[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showRegistrationBottomSheet();
        },
      ),
    );
  }

  _showRegistrationBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: <Widget>[
              FormBuilder(
                key: _fbKey,
                child: Column(
                  children: <Widget>[
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

                        if (_fbKey.currentState.validate()) {
                          print(_fbKey.currentState.value);
                          final firstName =
                              _fbKey.currentState.value['first_name'];
                          final lastName =
                              _fbKey.currentState.value['last_name'];

                          final email = _fbKey.currentState.value['email'];
                          final password = PasswordGenerator.generate(8);
                          print('Password: $password');
                          final result = ManagementService().registerNewUser(
                              email, password, firstName, lastName);
                          if (result == null) {
                            if (this.mounted) {
                              setState(() {
                                errorMsg = "Registration failure!";
                              });
                            }
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
        );
      },
    );
  }

  _buildList(BuildContext context, DocumentSnapshot document) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 8.0,
        child: ListTile(
          title: Text(
              "${document['first_name'] ?? ''} ${document['last_name'] ?? ''}"),
          subtitle: Text((document["is_active"] ? "Active" : "Inactive") + " " +
              (document["is_admin"] ? "Admin" : "User")),
        ),
      ),
    );
  }
}
