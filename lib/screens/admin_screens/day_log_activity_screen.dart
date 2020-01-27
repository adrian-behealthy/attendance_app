import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/screens/admin_screens/export_particular_date_logs_screen.dart';
import 'package:attendance_app/services/constants.dart';
import 'package:attendance_app/services/log_db_helper_service.dart';
import 'package:attendance_app/shared/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class DayLogActivityScreen extends StatefulWidget {
  @override
  _DayLogActivityScreenState createState() => _DayLogActivityScreenState();
}

class _DayLogActivityScreenState extends State<DayLogActivityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<FormBuilderState> _fbKey = new GlobalKey<FormBuilderState>();
  List<Log> logs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String date = _selectedDate.year.toString() +
        "-" +
        _selectedDate.month.toString().padLeft(2, '0') +
        "-" +
        _selectedDate.day.toString().padLeft(2, '0');
    DateTime fromDate = DateTime.parse(date);
    DateTime dayAfter = _selectedDate.add(Duration(days: 1));
    DateTime toDate = DateTime.parse(dayAfter.year.toString() +
        "-" +
        dayAfter.month.toString().padLeft(2, '0') +
        "-" +
        dayAfter.day.toString().padLeft(2, '0'));
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Particular date logs'),
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
              FormBuilder(
                key: _fbKey,
                autovalidate: true,
                child: Column(
                  children: <Widget>[
                    FormBuilderDateTimePicker(
                      attribute: "date",
                      validators: [FormBuilderValidators.required()],
                      onSaved: (val) {
                        setState(() {
                          _selectedDate = val;
                        });
                      },
                      onChanged: (DateTime val) {
                        _fbKey.currentState.save();
                      },
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      format: DateFormat("d MMMM y"),
                      initialDate: DateTime.now(),
                      lastDate: DateTime.now(),
                      firstDate: DateTime.now()
                          .subtract(Duration(days: MAX_DAYS_BACKWARD)),
                      decoration: InputDecoration(
                          labelText: "Date of logs", fillColor: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: Text(
                  "All activities on ${DateFormat('MMM d, y').format(fromDate)}",
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).primaryTextTheme.title.fontSize,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              Expanded(
                child: StreamBuilder<List<Log>>(
                  stream: LogDbHelperService(
                          fromDate:
                              (fromDate.millisecondsSinceEpoch / 1000).floor(),
                          toDate:
                              (toDate.millisecondsSinceEpoch / 1000).floor())
                      .logsByDate(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text(
                            "No logs for ${DateFormat('MMMM d, y').format(fromDate)}"),
                      );
                    if (snapshot.data.length == 0) {
                      return Center(
                          child: Text(
                              "No logs for ${DateFormat('MMMM d, y').format(fromDate)}"));
                    }
                    logs = snapshot.data;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        logs.isEmpty
                            ? null
                            : FlatButton.icon(
                                onPressed: () async {
                                  EXPORT_RESULT result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ExportParticularDateLogsScreen(
//                                  firstName: logs.first.firstName,
//                                  lastName: logs.first.lastName,
//                                  logs: logs,
//                                  fromDate: fromDate,
//                                  toDate: toDate,
                                              date: fromDate,
                                              logs: logs),
                                    ),
                                  );

                                  String exportMsg = "";
                                  Color snackbarColor = Colors.blue;
                                  switch (result) {
                                    case EXPORT_RESULT.CANCELED_EXPORT:
                                      break;
                                    case EXPORT_RESULT.SUCCESS_PDF:
                                      exportMsg =
                                          "The logs successfully exported as PDF";
                                      break;
                                    case EXPORT_RESULT.SUCCESS_CSV:
                                      exportMsg =
                                          "The logs successfully exported as CSV";
                                      break;
                                    case EXPORT_RESULT.FAILED_PDF:
                                      exportMsg =
                                          "Error in exporting logs in PDF.";
                                      snackbarColor = Colors.redAccent;
                                      break;
                                    case EXPORT_RESULT.FAILED_CSV:
                                      exportMsg =
                                          "Error in exporting logs in CSV.";
                                      snackbarColor = Colors.redAccent;
                                      break;
                                  }
                                  if (result == EXPORT_RESULT.SUCCESS_CSV) {
                                    exportMsg =
                                        "The logs successfully exported as CSV";
                                  } else if (result ==
                                      EXPORT_RESULT.SUCCESS_PDF) {
                                    exportMsg =
                                        "The logs successfully exported as PDF";
                                  } else if (result ==
                                      EXPORT_RESULT.FAILED_CSV) {
                                    exportMsg =
                                        "Error in exporting logs in CSV.";
                                    snackbarColor = Colors.redAccent;
                                  } else if (result ==
                                      EXPORT_RESULT.FAILED_PDF) {
                                    exportMsg =
                                        "Error in exporting logs in PDF.";
                                    snackbarColor = Colors.redAccent;
                                  }

                                  if (result != EXPORT_RESULT.CANCELED_EXPORT) {
                                    _scaffoldKey.currentState
                                        .removeCurrentSnackBar();
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        backgroundColor: snackbarColor,
                                        content: Text(
                                          "$exportMsg",
                                          textAlign: TextAlign.center,
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    print(result);
                                  }
                                },
                                icon: Icon(
                                  Icons.save,
                                  color: Colors.green[800],
                                  size: 36.0,
                                ),
                                label: Text(
                                  "Export",
                                  style: TextStyle(color: Colors.green[800]),
                                ),
                              ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) =>
                                _buildList(context, snapshot.data[index]),
                          ),
                        ),
                      ],
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
              Text(DateFormat("h:m a").format(dateTime)),
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

  @override
  void dispose() {
    super.dispose();
  }
}
