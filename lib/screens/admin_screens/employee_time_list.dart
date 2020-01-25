import 'package:attendance_app/screens/admin_screens/employee_activitiy_screen.dart';
import 'package:attendance_app/shared/user_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeTimeList extends StatefulWidget {
  @override
  _EmployeeTimeListState createState() => _EmployeeTimeListState();
}

class _EmployeeTimeListState extends State<EmployeeTimeList> {
  String errorMsg = "";
  UserFilter _userFilter = UserFilter.AllActiveNonAdminUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee list"),
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
    );
  }

  _buildList(BuildContext context, DocumentSnapshot document) {
    switch (_userFilter) {
      case UserFilter.AllNonAdminUsers:
        if (document["is_admin"] == true) return Container();
        break;
      case UserFilter.AllActiveNonAdminUsers:
        if (!(document["is_admin"] == false && document["is_active"] == true))
          return Container();
        break;
      case UserFilter.AllNonActiveNonAdminUsers:
        if (!(document["is_admin"] == false && document["is_active"] == false))
          return Container();
        break;
      case UserFilter.AllAdminUsers:
      default: // All
    }

    return InkWell(
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
          leading: Icon(
            Icons.description,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Material(
                child: EmployeeActivityScreen(
                    lastName: document['last_name']??'',
                    firstName: document['first_name']??'',
                    uid: document.documentID??'')),
          ),
        );
      },
    );
  }

  _filterDropdown() {
    return Container(
      alignment: Alignment.center,
      child: DropdownButton<UserFilter>(
        items: [
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
