import 'dart:io';

import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/row_items.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CsvHelper {
  static Future<bool> exportUserLog(
      {@required firstName,
      @required lastName,
      @required int fromDate,
      @required int toDate,
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
        ? DateFormat("y-MMM-dd")
            .format(DateTime.fromMillisecondsSinceEpoch(toDate))
        : "${DateFormat("y-MMM-dd").format(DateTime.fromMillisecondsSinceEpoch(fromDate))}" +
            "_to_" +
            "${DateFormat("y-MMM-dd").format(DateTime.fromMillisecondsSinceEpoch(toDate))}";

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
        return false;
      }

      final attendanceDir = new Directory(dir);
      bool isThere = await attendanceDir.exists();
      if (!isThere) {
        attendanceDir.create(recursive: true);
      }
      print(dir);
      File f;
      try {
        f = new File(dir + "/$filename");
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
        print(log.secondsSinceEpoch);
        var date = DateFormat("y-MMM-dd").format(
            DateTime.fromMillisecondsSinceEpoch(log.secondsSinceEpoch * 1000));
        var time = DateFormat("hh:mm a").format(
            DateTime.fromMillisecondsSinceEpoch(log.secondsSinceEpoch * 1000));
        print(time);
        print(date);
        //                return false;
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
    } else {
      return false;
    }
    return success;
  }
}
