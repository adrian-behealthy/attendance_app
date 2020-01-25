import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/user.dart';
import 'package:attendance_app/services/log_db_helper_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeActivityScreen extends StatefulWidget {
  final String uid;
  final String firstName;
  final String lastName;

  EmployeeActivityScreen({this.uid, this.firstName, this.lastName});

  @override
  _EmployeeActivityScreenState createState() => _EmployeeActivityScreenState();
}

class _EmployeeActivityScreenState extends State<EmployeeActivityScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
//    DateTime dayBefore = _currentTime.subtract(Duration(days: 2));
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
        title: Text('Logs : (${widget.firstName} ${widget.lastName})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Time-in",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    "Time-out",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),

              SizedBox(
                height: 12.0,
              ),
//              Text(
//                "Your today's activities. ($date)",
//                style: TextStyle(
//                    fontSize: Theme.of(context).primaryTextTheme.title.fontSize,
//                    color: Colors.blue,
//                    fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 12.0,
//              ),
              Expanded(
                child: StreamBuilder<List<Log>>(
                  stream: LogDbHelperService(
                          uid: user.uid, fromDate: fromDate, toDate: toDate)
                      .logsByUid(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text("No logs"),
                      );
                    if (snapshot.data.length == 0) {
                      return Text("No logs");
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${log.firstName} ${log.lastName}",
                textAlign: TextAlign.left,
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
}
