import 'dart:io';

import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/row_items.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attendance_app/shared/enums.dart';

class CsvHelper {
  static Future<EXPORT_RESULT> exportUserLog(
      {@required firstName,
      @required lastName,
      @required DateTime fromDate,
      @required DateTime toDate,
      @required List<Log> logs}) async {
    EXPORT_RESULT result;

    final name = "$firstName$lastName";
    final duration =
        (fromDate.millisecondsSinceEpoch == toDate.millisecondsSinceEpoch)
            ? DateFormat("d-MMM-y").format(toDate)
            : "from_${DateFormat("d-MMM-y").format(fromDate)}" +
                "_to_" +
                "${DateFormat("d-MMM-y").format(toDate)}";

    final filename = "${name}_$duration.csv";

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission == PermissionStatus.granted) {
      String dir = "";

      try {
        dir = (await getExternalStorageDirectory()).absolute.path +
            "/documents/attendace";
      } catch (e) {
        print(e);
        return EXPORT_RESULT.FAILED_CSV;
      }

      final attendanceDir = new Directory(dir);
      bool isThere = await attendanceDir.exists();
      if (!isThere) {
        attendanceDir.create(recursive: true);
      }
      File f;
      try {
        f = new File(dir + "/$filename");
      } catch (e) {
        print(e);
        return EXPORT_RESULT.FAILED_CSV;
      }

      List<dynamic> titles = [
        "Date",
        "Time",
        "Project",
        "In/Out",
        "Longitude",
        "Latitude",
        "Comment"
      ];

      List<List<dynamic>> rows = [titles];
      for (Log log in logs) {
        var date = DateFormat("y-MMM-dd").format(
            DateTime.fromMillisecondsSinceEpoch(log.secondsSinceEpoch * 1000));
        var time = DateFormat("hh:mm a").format(
            DateTime.fromMillisecondsSinceEpoch(log.secondsSinceEpoch * 1000));

        List<dynamic> row = [];
        row.add(date);
        row.add(time);
        row.add(log.projectName);
        row.add(log.isIn ? "Time-in" : "Time-out");
        row.add("${log.lat}");
        row.add("${log.lng}");
        row.add(log.comment);
        // add to rows
        rows.add(row);
      }

      try {
        String csv = const ListToCsvConverter().convert(rows);
        f.writeAsString(csv);
        result = EXPORT_RESULT.SUCCESS_CSV;
      } catch (e) {
        result = EXPORT_RESULT.SUCCESS_CSV;
      }
    } else {
      result = EXPORT_RESULT.FAILED_CSV;
    }
    return result;
  }
}
