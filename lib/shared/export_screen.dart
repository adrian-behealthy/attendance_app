import 'package:attendance_app/services/csv_helper.dart';
import 'package:attendance_app/services/pdf_helper.dart';
import 'package:attendance_app/shared/enums.dart';
import 'package:flutter/material.dart';

enum _FileFormat { CSV_FORMAT, PDF_FORMAT }

class ExportScreen extends StatefulWidget {
  final firstName;
  final lastName;
  final fromDate;
  final toDate;
  final logs;

  const ExportScreen(
      {Key key,
      this.firstName,
      this.lastName,
      this.fromDate,
      this.toDate,
      this.logs})
      : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
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
                        result = await _exportUserLogCSV();
                      } else {
                        result = await _exportUserLogPDF();
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

  Future<EXPORT_RESULT> _exportUserLogCSV() async {
    return await CsvHelper.exportUserLog(
        firstName: widget.logs.first.firstName,
        lastName: widget.logs.first.lastName,
        fromDate: widget.fromDate.millisecondsSinceEpoch,
        toDate: widget.toDate.millisecondsSinceEpoch,
        logs: widget.logs);
  }

  Future<EXPORT_RESULT> _exportUserLogPDF() async {
    return await PdfHelper.exportUserLogPDF(
        firstName: widget.logs.first.firstName,
        lastName: widget.logs.first.lastName,
        fromDate: widget.fromDate.millisecondsSinceEpoch,
        toDate: widget.toDate.millisecondsSinceEpoch,
        logs: widget.logs);
  }
}
