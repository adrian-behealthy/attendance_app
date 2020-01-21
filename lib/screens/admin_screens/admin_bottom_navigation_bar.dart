import 'package:attendance_app/screens/admin_screens/admin_home.dart';
import 'package:attendance_app/screens/admin_screens/employee_time_list.dart';
import 'package:attendance_app/screens/admin_screens/manage_screen.dart';
import 'package:attendance_app/screens/providers/bottom_navigation_bar_provider.dart';
import 'package:attendance_app/shared/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminBottomNavigationBar extends StatefulWidget {
  @override
  _AdminBottomNavigationBarState createState() =>
      _AdminBottomNavigationBarState();
}

class _AdminBottomNavigationBarState extends State<AdminBottomNavigationBar> {
  var _currentTab = [
    AdminHome(),
    EmployeeTimeList(),
    ManageScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      body: _currentTab[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8.0,
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
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            title: new Text('Employees'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.edit),
            title: new Text('Manage'),
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
