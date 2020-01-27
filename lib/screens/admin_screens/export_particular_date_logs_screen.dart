import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/services/csv_helper.dart';
import 'package:attendance_app/services/pdf_helper.dart';
import 'package:attendance_app/shared/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _FileFormat { CSV_FORMAT, PDF_FORMAT }

class ExportParticularDateLogsScreen extends StatefulWidget {
  final DateTime date;
  final List<Log> logs;

  const ExportParticularDateLogsScreen({Key key, this.date, this.logs})
      : super(key: key);

  @override
  _ExportParticularDateLogsScreenState createState() =>
      _ExportParticularDateLogsScreenState();
}

class _ExportParticularDateLogsScreenState
    extends State<ExportParticularDateLogsScreen> {
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
                style: Theme.of(context).primaryTextTheme.headline.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Logs for ${DateFormat('MMMM d, y').format(widget.date)}",
                style: Theme.of(context).primaryTextTheme.title.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
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

  _exportLogsCSV() async {
    return await CsvHelper.exportParticularDateLog(
        date: widget.date, logs: widget.logs);
  }

  _exportLogsPDF() async {
    return await PdfHelper.exportParticularDatePDF(
        date: widget.date, logs: widget.logs);
  }
}
