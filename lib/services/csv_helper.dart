import 'dart:io';

import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/row_items.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

class CsvHelper {
  static Future<bool> exportUserLog(
      {@required firstName,
      @required lastName,
      @required DateTime fromDate,
      @required DateTime toDate,
      @required List<Log> logs}) async {
    bool success = true;

//    RowItems columnNames = RowItems(
//        name: "Name",
//        firstName: "Firstname",
//        lastName: "LastName",
//        date: "Date",
//        time: "Time",
//        lat: "Latitude",
//        lng: "Longitude");

    final name = "$firstName$lastName";
    final duration = (fromDate == toDate)
        ? DateFormat("MMMM-dd-y").add_yM().parse(toDate.toIso8601String())
        : "${DateFormat("MMMM-dd-y").add_yM().parse(fromDate.toIso8601String())}_to_${DateFormat("MMMM-dd-y").add_yM().parse(toDate.toIso8601String())}";

    final filename = "${name}_$duration.csv";

    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    bool checkPermission = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);

    if (checkPermission) {
      String dir =
          (await getExternalStorageDirectory()).absolute.path + "/documents";

      File f;
      try {
        f = new File(dir + "filename.csv");
      } catch (e) {
        print(e);
        return false;
      }

      List<dynamic> row = [
        "Date",
        "Time",
        "Project",
        "In/Out",
        "Longitude",
        "Latitude",
        "Comment"
      ];

      List<List<dynamic>> rows = [row];
      for (Log log in logs) {
        var date = DateFormat.yMMMMd('en_US').parse(log.secondsSinceEpoch);
        var time = DateFormat.jm().parse(log.secondsSinceEpoch);
        List<dynamic> row = [];
        row.add(date);
        row.add(time);
        row.add(log.isIn ? "Time-in" : "Time-out");
        row.add(log.projectName);
        row.add("${log.lat}");
        row.add("${log.lng}");
        row.add(log.comment);
        // add to rows
        rows.add(row);
      }

      try {
        String csv = const ListToCsvConverter().convert(rows);
        f.writeAsString(csv);
      } catch (e) {
        print(e);
        success = false;
      }

      return success;
    }
  }
}
