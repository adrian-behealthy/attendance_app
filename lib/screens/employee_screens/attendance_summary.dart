import 'package:flutter/material.dart';

class AttendanceSummary extends StatefulWidget {
  @override
  _AttendanceSummaryState createState() => _AttendanceSummaryState();
}

class _AttendanceSummaryState extends State<AttendanceSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance summary"),
      ),
    );
  }
}
