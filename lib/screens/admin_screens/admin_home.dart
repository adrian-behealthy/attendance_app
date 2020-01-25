import 'dart:async';

import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/services/auth_service.dart';
import 'package:attendance_app/services/log_db_helper_service.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with WidgetsBindingObserver {
  Timer getTimer;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    executeDateObserver();
  }

  @override
  Widget build(BuildContext context) {
    String date = _currentTime.month.toString() +
        "/" +
        _currentTime.day.toString() +
        "/" +
        _currentTime.year.toString();

    int fromDate = (DateTime.parse("${_currentTime.year}" +
                    "-${_currentTime.month.toString().padLeft(2, '0')}" +
                    "-${_currentTime.day.toString().padLeft(2, '0')}")
                .millisecondsSinceEpoch /
            1000)
        .floor();
    DateTime dayAfter = _currentTime.add(Duration(days: 1));
//    DateTime dayBefore = _currentTime.subtract(Duration(days: 1));
//    fromDate = (DateTime.parse("${dayBefore.year}" +
//                    "-${dayBefore.month.toString().padLeft(2, '0')}" +
//                    "-${dayBefore.day.toString().padLeft(2, '0')}")
//                .millisecondsSinceEpoch /
//            1000)
//        .floor();
    int toDate = (DateTime.parse("${dayAfter.year}" +
                    "-${dayAfter.month.toString().padLeft(2, '0')}" +
                    "-${dayAfter.day.toString().padLeft(2, '0')}")
                .millisecondsSinceEpoch /
            1000)
        .floor();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Time-in / Time-out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 12.0,
              ),
              Text(
                "Today's all activities. ($date)",
                style: TextStyle(
                    fontSize: Theme.of(context).primaryTextTheme.title.fontSize,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12.0,
              ),
              Expanded(
                child: StreamBuilder<List<Log>>(
                  stream: LogDbHelperService(fromDate: fromDate, toDate: toDate)
                      .logsByDate(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text("No logs for today"),
                      );
                    if (snapshot.data.length == 0) {
                      return Text("No logs for today");
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) =>
                          _buildList(context, snapshot.data[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildList(BuildContext context, Log log) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(log.secondsSinceEpoch * 1000);

    return Container(
      child: Card(
        elevation: 8.0,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${log.firstName} ${log.lastName}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  "${log.projectName ?? ''} ; lat:${log.lat ?? ''}; lng:${log.lng ?? ''}"),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${dateTime.hour}:${dateTime.minute}"),
              log.isIn
                  ? Text(
                      "Time-in",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    )
                  : Text(
                      "Time-out",
                      style: TextStyle(color: Colors.blue),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// check app state resume or inactive.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      executeDateObserver();
    }
    if (state == AppLifecycleState.inactive) {
      getTimer.cancel();
    }
  }

  executeDateObserver() {
    getTimer = Timer.periodic(Duration(seconds: 5), (Timer t) => _getDate());
  }

  void _getDate() {
    final timeNow = DateTime.now();
    if (timeNow.difference(_currentTime).inDays > 0) {
      setState(() {
        _currentTime = timeNow;
      });
    }
    return;
  }

  @override
  void dispose() {
    super.dispose();
    getTimer.cancel();
  }
}
