import 'package:attendance_app/services/management_service.dart';
import 'package:attendance_app/shared/password_generator.dart';
import 'package:attendance_app/shared/user_filter.dart';
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
  UserFilter _userFilter = UserFilter.AllActiveNonAdminUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User management"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            _filterDropdown(),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: Text("Loading..."),
                    );
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
//                    itemExtent: 80.0,
                    itemBuilder: (context, index) =>
                        _buildList(context, snapshot.data.documents[index]),
                  );
                },
              ),
            ),
          ],
        ),
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
        return Container(
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
                      color: Theme
                          .of(context)
                          .accentColor,
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

    switch(_userFilter){

      case UserFilter.AllNonAdminUsers:
        if(document["is_admin"] == true) return Container();
        break;
      case UserFilter.AllAdminUsers:
        if(document["is_admin"] == false) return Container();
        break;
      case UserFilter.AllActiveNonAdminUsers:
        if(!(document["is_admin"] == false && document["is_active"] == true)) return Container();
        break;
      case UserFilter.AllNonActiveNonAdminUsers:
        if(!(document["is_admin"] == false && document["is_active"] == false)) return Container();
        break;
      default: // All
    }

    return Container(
      child: Card(
        elevation: 8.0,
        child: ListTile(
          title: Text(
              "${document['first_name'] ?? ''} ${document['last_name'] ?? ''}"),
          subtitle: Text((document["is_active"] ? "Active" : "Inactive") +
              " " +
              (document["is_admin"] ? "Admin" : "User")),
          trailing: IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme
                  .of(context)
                  .primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  _filterDropdown() {
    return Container(
      alignment: Alignment.center,
      child: DropdownButton<UserFilter>(
        items: [
          DropdownMenuItem<UserFilter>(
            child: Text('All'),
            value: UserFilter.All,
          ),
          DropdownMenuItem<UserFilter>(
            child: Text('Active non-admin users'),
            value: UserFilter.AllActiveNonAdminUsers,
          ),
          DropdownMenuItem<UserFilter>(
            child: Text('All non-admin users'),
            value: UserFilter.AllNonAdminUsers,
          ),
          DropdownMenuItem<UserFilter>(
            child: Text('All non-active non-admin users'),
            value: UserFilter.AllNonActiveNonAdminUsers,
          ),
          DropdownMenuItem<UserFilter>(
            child: Text('All admin users'),
            value: UserFilter.AllAdminUsers,
          )
        ],
        onChanged: (UserFilter value) {
          setState(() {
            _userFilter = value;
          });
        },
        hint: Text('Select Item'),
        value: _userFilter,
        isExpanded: true,
      ),
    );
  }

  _snapshotsWithFilter() {
    switch (_userFilter) {
      case UserFilter.All:
        return
          Firestore.instance.collection("users").snapshots();
      case UserFilter.AllNonAdminUsers:
        return
          Firestore.instance.collection("users").snapshots();
      case UserFilter.AllAdminUsers:
      // TODO: Handle this case.
        break;
      case UserFilter.AllActiveNonAdminUsers:
      // TODO: Handle this case.
        break;
      case UserFilter.AllNonActiveNonAdminUsers:
      // TODO: Handle this case.
        break;
    }
  }
}
