import 'package:attendance_app/models/user.dart';
import 'package:attendance_app/screens/admin_screens/employee_activitiy_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceSummary extends StatefulWidget {
  @override
  _AttendanceSummaryState createState() => _AttendanceSummaryState();
}

class _AttendanceSummaryState extends State<AttendanceSummary> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return EmployeeActivityScreen(uid: user.uid,);
  }
}
