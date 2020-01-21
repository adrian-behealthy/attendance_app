import 'package:attendance_app/screens/employee_screens/attendance_summary.dart';
import 'package:attendance_app/screens/employee_screens/time_in.dart';
import 'package:attendance_app/screens/providers/bottom_navigation_bar_provider.dart';
import 'package:attendance_app/shared/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeBottomNavigationBar extends StatefulWidget {
  @override
  _EmployeeBottomNavigationBarState createState() =>
      _EmployeeBottomNavigationBarState();
}

class _EmployeeBottomNavigationBarState
    extends State<EmployeeBottomNavigationBar> {
  var _currentTab = [
    TimeIn(),
    AttendanceSummary(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      body: _currentTab[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8.0,
        showUnselectedLabels: false,
        currentIndex: provider.currentIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Theme.of(context).accentColor,
        selectedIconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: Theme.of(context).primaryColor),
        unselectedIconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: Theme.of(context).accentColor),
        selectedItemColor: Theme.of(context).accentColor,
        onTap: (index) {
          provider.currentIndex = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.access_time),
            title: new Text('Time-in'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            title: new Text('Summary'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          )
        ],
      ),
    );
  }
}
