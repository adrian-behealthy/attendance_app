import 'package:attendance_app/screens/admin_screens/user_registration_screen.dart';
import 'package:attendance_app/services/management_service.dart';
import 'package:attendance_app/services/user_db_service.dart';
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
  static final GlobalKey<FormBuilderState> _fbDialogKey =
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Material(child: UserRegistrationScreen()),
            ),
          );
        },
      ),
    );
  }

  _buildList(BuildContext context, DocumentSnapshot document) {
    switch (_userFilter) {
      case UserFilter.AllNonAdminUsers:
        if (document["is_admin"] == true) return Container();
        break;
      case UserFilter.AllAdminUsers:
        if (document["is_admin"] == false) return Container();
        break;
      case UserFilter.AllActiveNonAdminUsers:
        if (!(document["is_admin"] == false && document["is_active"] == true))
          return Container();
        break;
      case UserFilter.AllNonActiveNonAdminUsers:
        if (!(document["is_admin"] == false && document["is_active"] == false))
          return Container();
        break;
      default: // All
    }

    return Container(
      child: Card(
        elevation: 8.0,
        child: ListTile(
          title: Text(
              "${document['first_name'] ?? ''} ${document['last_name'] ?? ''}"),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              document["is_active"]
                  ? Text(
                      "Active",
                      style: TextStyle(color: Colors.green),
                    )
                  : Text("Inactive", style: TextStyle(color: Colors.red)),
              document["is_admin"]
                  ? Text(
                      "Admin",
                      style: TextStyle(color: Colors.red),
                    )
                  : Text("User", style: TextStyle(color: Colors.blue)),
            ],
          ),
          leading: document["is_admin"]
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Edit user data"),
                          content: Container(
                            child: FormBuilder(
                              key: _fbDialogKey,
                              child: Wrap(
                                children: <Widget>[
                                  FormBuilderTextField(
                                    attribute: "first_name",
                                    initialValue: document['first_name'],
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        labelText: "First name"),
                                    validators: [
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.maxLength(70),
                                    ],
                                  ),
                                  FormBuilderTextField(
                                    attribute: "last_name",
                                    initialValue: document['last_name'],
                                    keyboardType: TextInputType.text,
                                    decoration:
                                        InputDecoration(labelText: "Last name"),
                                    validators: [
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.maxLength(70),
                                    ],
                                  ),
                                  FormBuilderSwitch(
                                    attribute: "is_active",
                                    label: Text("Is active"),
                                    initialValue: document['is_active'],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      RaisedButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      RaisedButton(
                                        color: Theme.of(context).primaryColor,
                                        child: Text("Submit"),
                                        onPressed: () {
                                          _fbDialogKey.currentState.save();
                                          if (!_fbDialogKey.currentState
                                              .validate()) return;

                                          UserDbService().updateUser(
                                              userId: document.documentID,
                                              firstName: _fbDialogKey
                                                      .currentState
                                                      .value['first_name'] ??
                                                  document['first_name'],
                                              lastName: _fbDialogKey
                                                      .currentState
                                                      .value['last_name'] ??
                                                  document['last_name'],
                                              isActive: _fbDialogKey
                                                      .currentState
                                                      .value['is_active'] ??
                                                  document['is_active']);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
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
}
