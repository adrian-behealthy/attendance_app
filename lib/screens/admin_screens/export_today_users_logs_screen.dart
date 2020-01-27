import 'package:attendance_app/shared/enums.dart';
import 'package:flutter/material.dart';

enum _FileFormat { CSV_FORMAT, PDF_FORMAT }

class ExportTodayUsersLogsScreenScreen extends StatefulWidget {
  @override
  _ExportTodayUsersLogsScreenScreenState createState() =>
      _ExportTodayUsersLogsScreenScreenState();
}

class _ExportTodayUsersLogsScreenScreenState
    extends State<ExportTodayUsersLogsScreenScreen> {
  _FileFormat _fileFormat = _FileFormat.CSV_FORMAT;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Export screen",
                style: Theme.of(context)
                    .primaryTextTheme
                    .headline
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text("Choose file format"),
              SizedBox(
                height: 20.0,
              ),
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
              SizedBox(
                height: 20.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
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
                        result = await _exportLogsCSV();
                      } else {
                        result = await _exportLogsPDF();
                      }
                      if (result != EXPORT_RESULT.FAILED_CSV ||
                          result != EXPORT_RESULT.FAILED_PDF) {
                        Navigator.pop(context, result);
                      } else {
                        if (result == EXPORT_RESULT.FAILED_CSV) {
                          Navigator.pop(context, EXPORT_RESULT.FAILED_CSV);
                        } else {
                          Navigator.pop(context, EXPORT_RESULT.FAILED_PDF);
                        }
                      }
                      return result;
                    },
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _exportLogsCSV() {}

  _exportLogsPDF() {}
}
