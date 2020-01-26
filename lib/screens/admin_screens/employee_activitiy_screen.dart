import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/services/constants.dart';
import 'package:attendance_app/services/csv_helper.dart';
import 'package:attendance_app/services/pdf_helper.dart';
import 'package:attendance_app/services/log_db_helper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/shared/enums.dart';

enum _FileFormat { CSV_FORMAT, PDF_FORMAT }

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
  _FileFormat _fileFormat = _FileFormat.CSV_FORMAT;

  List<Log> logs = [];

  @override
  void initState() {
    fromDate = DateTime.parse(DateFormat("y-MM-dd").format(_currentTime));
    fromDateSinceEpoch = (fromDate.millisecondsSinceEpoch / 1000).floor();
    dayAfter = _currentTime.add(Duration(days: 1));

    toDate = DateTime.parse(DateFormat("y-MM-dd").format(dayAfter));

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
              Expanded(
                child: StreamBuilder<List<Log>>(
                  stream: LogDbHelperService(
                          uid: widget.uid,
                          fromDate: fromDateSinceEpoch,
                          toDate: toDateSinceEpoch)
                      .logsByUid(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text("No logs for this duration"),
                      );
                    }
                    logs = snapshot.data;
                    if (snapshot.data.length == 0) {
                      return Center(child: Text("No logs for this duration"));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        logs.isEmpty
                            ? null
                            : FlatButton.icon(
                                onPressed: () async {
                                  EXPORT_RESULT result = await _showDialog();

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
    String dateTime = DateFormat('d MMM y h:m a').format(
        DateTime.fromMillisecondsSinceEpoch(log.secondsSinceEpoch * 1000));

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

  Future<EXPORT_RESULT> _exportUserLogCSV() async {
    return await CsvHelper.exportUserLog(
        firstName: logs.first.firstName,
        lastName: logs.first.lastName,
        fromDate: fromDate.millisecondsSinceEpoch,
        toDate: toDate.millisecondsSinceEpoch,
        logs: logs);
  }

  String test = "";

  Future<EXPORT_RESULT> _showDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text("Export dialog"),
          content: Wrap(
            children: <Widget>[
              Text("Choose file format"),
              Row(
                children: <Widget>[
                  Radio(
                    value: _FileFormat.CSV_FORMAT,
                    groupValue: _fileFormat,
                    autofocus: true,
                    onChanged: (_FileFormat val) => setState(
                      () {
                        _fileFormat = val;
                      },
                    ),
                  ),
                  Text("CSV format"),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio(
                    value: _FileFormat.PDF_FORMAT,
                    groupValue: _fileFormat,
                    autofocus: true,
                    onChanged: (_FileFormat val) => setState(() {
                      _fileFormat = val;
                    }),
                  ),
                  Text("PDF format"),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, EXPORT_RESULT.CANCELED_EXPORT);
              },
            ),
            RaisedButton(
              child: Text(
                "Export",
              ),
              onPressed: () async {
                EXPORT_RESULT result = EXPORT_RESULT.CANCELED_EXPORT;
                print("pressed");
                if (_fileFormat == _FileFormat.CSV_FORMAT) {
                  result = await _exportUserLogCSV();
                } else {
                  result = await PdfHelper.exportUserLogPDF(
                      firstName: logs.first.firstName,
                      lastName: logs.first.lastName,
                      fromDate: fromDate.millisecondsSinceEpoch,
                      toDate: toDate.millisecondsSinceEpoch,
                      logs: logs);
                }
                if (result != EXPORT_RESULT.FAILED_CSV ||
                    result != EXPORT_RESULT.FAILED_PDF) {
                  Navigator.pop(context, result);
                } else {
                  _scaffoldKey.currentState.removeCurrentSnackBar();
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        "Export failed",
                        textAlign: TextAlign.center,
                      ),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                return result;
              },
              color: Colors.redAccent,
            ),
          ],
        );
      },
    );
  }
}
