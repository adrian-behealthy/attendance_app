import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/services/constants.dart';
import 'package:attendance_app/services/log_db_helper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class EmployeeActivityScreen extends StatefulWidget {
  final String uid;
  final String firstName;
  final String lastName;

  EmployeeActivityScreen({this.uid, this.firstName, this.lastName});

  @override
  _EmployeeActivityScreenState createState() => _EmployeeActivityScreenState();
}

class _EmployeeActivityScreenState extends State<EmployeeActivityScreen> {
  static final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime _currentTime = DateTime.now();
  int fromDateSinceEpoch;
  int toDateSinceEpoch;
  DateTime dayAfter;
  DateTime fromDate;
  DateTime toDate;

  @override
  void initState() {
    fromDate = DateTime.parse("${_currentTime.year}" +
        "-${_currentTime.month.toString().padLeft(2, '0')}" +
        "-${_currentTime.day.toString().padLeft(2, '0')}");

    fromDateSinceEpoch = (fromDate.millisecondsSinceEpoch / 1000).floor();
    dayAfter = _currentTime.add(Duration(days: 1));
//    dayBefore = _currentTime.subtract(Duration(days: 2));
//    fromDate = (DateTime.parse("${dayBefore.year}" +
//                    "-${dayBefore.month.toString().padLeft(2, '0')}" +
//                    "-${dayBefore.day.toString().padLeft(2, '0')}")
//                .millisecondsSinceEpoch /
//            1000)
//        .floor();
    toDate = DateTime.parse("${dayAfter.year}" +
        "-${dayAfter.month.toString().padLeft(2, '0')}" +
        "-${dayAfter.day.toString().padLeft(2, '0')}");

    toDateSinceEpoch = (toDate.millisecondsSinceEpoch / 1000).floor();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _updateDateRange() {
    setState(() {
      if (fromDate == null) {
        _fbKey.currentState.setState(() => _fbKey.currentState
            .setAttributeValue("from_date",
                DateTime.now().subtract(Duration(days: MAX_DAYS_BACKWARD))));
        _fbKey.currentState.save();
        setState(() {
          fromDate = DateTime.now().subtract(Duration(days: MAX_DAYS_BACKWARD));
        });
      }
      if (toDate == null) {
        _fbKey.currentState.setState(() =>
            _fbKey.currentState.setAttributeValue("to_date", DateTime.now()));
        _fbKey.currentState.save();
        setState(() {
          toDate = DateTime.now().add(Duration(days: 1));
        });
      }
      fromDateSinceEpoch = (DateFormat("y-mm-dd")
                  .parse(fromDate.toIso8601String())
                  .millisecondsSinceEpoch /
              1000)
          .floor();
      dayAfter = toDate.add(Duration(days: 1));
      toDateSinceEpoch = (DateFormat("y-mm-dd")
                  .parse(dayAfter.toIso8601String())
                  .millisecondsSinceEpoch /
              1000)
          .floor();
//      print(DateTime.fromMillisecondsSinceEpoch(fromDateSinceEpoch * 1000));
//      print(DateTime.fromMillisecondsSinceEpoch(toDateSinceEpoch * 1000));
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateDateRange();
    print(toDate);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title:
            Text('Logs : ${widget.firstName ?? ""} ${widget.lastName ?? ""}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FormBuilder(
                key: _fbKey,
                autovalidate: true,
                child: Column(
                  children: <Widget>[
                    FormBuilderDateTimePicker(
                      attribute: "from_date",
                      validators: [FormBuilderValidators.required()],
                      onSaved: (val) {
                        setState(() {
                          fromDate = val;
                          print(fromDate);
                        });
                      },
                      onChanged: (DateTime val) {
                        if (toDate.difference(val).inDays > 0) {
                          // toDate should not be lower than fromdate
                          _fbKey.currentState
                              .setAttributeValue('from_date', toDate);
                        } else {
                          _fbKey.currentState
                              .setAttributeValue('from_date', val);
                        }
                        _fbKey.currentState.saveAndValidate();
                      },
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      format: DateFormat("d MMMM y"),
                      initialDate: DateTime.now(),
                      lastDate: toDate.difference(DateTime.now()).inDays < 0
                          ? toDate
                          : DateTime.now(),
                      firstDate: DateTime.now()
                          .subtract(Duration(days: MAX_DAYS_BACKWARD)),
                      decoration: InputDecoration(
                          labelText: "From date", fillColor: Colors.black),
                    ),
                    FormBuilderDateTimePicker(
                      attribute: "to_date",
                      onSaved: (val) {
                        setState(() {
                          toDate = val;
                          print(toDate);
                        });
                      },
                      validators: [FormBuilderValidators.required()],
                      onChanged: (DateTime val) {
                        final selectedDate = val;
                        if (val == null) return;

                        print(selectedDate);
                        if (fromDate.difference(selectedDate).inDays > 0) {
                          print(toDate);
                          // toDate should not be greater than toDate
                          _fbKey.currentState
                              .setAttributeValue('to_date', toDate);
                        } else {
                          _fbKey.currentState.setAttributeValue('to_date', val);
                        }
                        _fbKey.currentState.saveAndValidate();
                      },
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      format: DateFormat("d MMMM y"),
                      initialDate: DateTime.now(),
                      lastDate: DateTime.now(),
                      firstDate: fromDate
                                  .difference(DateTime.now().subtract(
                                      Duration(days: MAX_DAYS_BACKWARD)))
                                  .inDays >
                              0
                          ? fromDate
                          : DateTime.now()
                              .subtract(Duration(days: MAX_DAYS_BACKWARD)),
                      decoration: InputDecoration(
                          labelText: "To date", fillColor: Colors.black),
                    ),
                  ],
                ),
              ),
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
              Expanded(
                child: StreamBuilder<List<Log>>(
                  stream: LogDbHelperService(
                          uid: widget.uid,
                          fromDate: fromDateSinceEpoch,
                          toDate: toDateSinceEpoch)
                      .logsByUid(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text("No logs for this duration"),
                      );
                    if (snapshot.data.length == 0) {
                      return Center(child: Text("No logs for this duration"));
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
              SizedBox(
                height: 12.0,
              ),
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
              Text("$dateTime"),
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
