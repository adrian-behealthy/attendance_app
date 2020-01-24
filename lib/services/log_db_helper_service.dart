import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class LogDbHelperService {
  final uid;
  final fromDate;
  final toDate;

  LogDbHelperService(
      {this.uid, @required this.fromDate, @required this.toDate});

  Stream<List<Log>> logsByUid() async* {
    if (this.uid == null) {
      print("uid was not set");
      yield [];
    }
    final Firestore firestore = Firestore.instance;

    final CollectionReference logCollection = firestore.collection("logs");

    List<Log> logList = [];
    Stream<QuerySnapshot> filteredLogs = logCollection
        .where("seconds_since_epoch",
            isGreaterThanOrEqualTo: fromDate, isLessThanOrEqualTo: toDate)
        .orderBy("seconds_since_epoch", descending: true)
        .where("uid", isEqualTo: this.uid)
        .getDocuments()
        .asStream();
    await filteredLogs.map(_logListFromSnapshot).first.then((list) async {
      logList = await list;
    });
    if (logList.isNotEmpty) yield logList;
  }

  Stream<List<Log>> logsByDate() async* {
    final Firestore firestore = Firestore.instance;

    final CollectionReference logCollection = firestore.collection("logs");

    List<Log> logList = [];
    Stream<QuerySnapshot> filteredLogs = logCollection
        .where("seconds_since_epoch",
            isGreaterThanOrEqualTo: fromDate, isLessThanOrEqualTo: toDate)
        .orderBy("seconds_since_epoch", descending: true)
        .getDocuments()
        .asStream();
    await filteredLogs.map(_logListFromSnapshot).first.then((list) async {
      logList = await list;
    });
    if (logList.isNotEmpty) yield logList;
  }

  Future<List<Log>> _logListFromSnapshot(QuerySnapshot snapshot) async {
    final CollectionReference userCollection =
        Firestore.instance.collection("users");
    Map<String, UserData> userMap = {};
    try {
      userMap =
          await userCollection.snapshots().map(_userDataListFromSnapshot).first;
    } catch (e) {
      print(e);
    }
    List<Log> logs = [];

    snapshot.documents.forEach((doc) {
      final firstName = userMap[doc.data["uid"]];
      final lastName = userMap[doc.data["uid"]];

      logs.add(Log(
          doc.data['uid'],
          doc.data['seconds_since_epoch'],
          doc.data['location'].latitude,
          doc.data['location'].longitude,
          doc.data['is_in'],
          doc.data['project_name'],
          doc.data['comment'],
          firstName: firstName,
          lastName: lastName));
    });
    return logs;
  }

  Map<String, UserData> _userDataListFromSnapshot(QuerySnapshot snapshot) {
    Map<String, UserData> userMap = {};
    snapshot.documents.forEach((doc) {
      userMap.putIfAbsent(
          doc.documentID,
          () => UserData(
                firstName: doc.data['first_name'] ?? '',
                lastName: doc.data['last_name'] ?? '',
              ));
    });
    return userMap;
  }
}
