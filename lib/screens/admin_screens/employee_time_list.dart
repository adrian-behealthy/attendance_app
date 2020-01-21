import 'package:flutter/material.dart';

class EmployeeTimeList extends StatefulWidget {
  @override
  _EmployeeTimeListState createState() => _EmployeeTimeListState();
}

class _EmployeeTimeListState extends State<EmployeeTimeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Time List"),
      ),
    );
  }
}
