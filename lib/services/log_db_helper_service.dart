import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class LogDbHelperService {
  final uid;
  final fromDate;
  final toDate;
  List<String> _uids = [];
  Map<String, UserData> _userMap = {};

  LogDbHelperService(
      {this.uid, @required this.fromDate, @required this.toDate});

  final Firestore firestore = Firestore.instance;

  Stream<List<Log>> logsByUid() async* {
    if (this.uid == null) {
      print("uid was not set");
      yield [];
    }
    _uids = [this.uid];
    _userMap = await _getUserMap();
    final CollectionReference logCollection = firestore.collection("logs");

    List<Log> logList = [];
    Stream<QuerySnapshot> filteredLogs = _filteredByUid(logCollection);

    logList = await filteredLogs.map(_logListFromSnapshot).first;
    if (logList.isNotEmpty) yield logList;
  }

  Stream<List<Log>> logsByDate() async* {
    final CollectionReference logCollection = firestore.collection("logs");
    _userMap = await _getUserMap();
//    print(_userMap);
    List<Log> logList = [];
    Stream<QuerySnapshot> filteredLogSnapshots = _filteredByDate(logCollection);
    logList = await filteredLogSnapshots.map(_logListFromSnapshot).first;
    if (logList.isNotEmpty) yield logList;
  }

  List<Log> _logListFromSnapshot(QuerySnapshot snapshot) {
    List<Log> logs = [];
    snapshot.documents.forEach(
      (doc) {
        final UserData userData = _userMap[doc.data['uid']];
        final firstName = userData?.firstName ?? '';
        final lastName = userData?.lastName ?? '';

        logs.add(
          Log(
            doc.documentID,
            doc.data['seconds_since_epoch'],
            doc.data['location'].latitude,
            doc.data['location'].longitude,
            doc.data['is_in'],
            doc.data['project_name'],
            doc.data['comment'],
            firstName: firstName,
            lastName: lastName,
          ),
        );
      },
    );
    return logs;
  }

  Map<String, UserData> _userDataMapFromSnapshot(QuerySnapshot snapshot) {
    Map<String, UserData> userMap = {};
    for (var id in _uids) {
      for (DocumentSnapshot doc in snapshot.documents) {
        if (doc.data['first_name'] == null) continue;
        if (doc.documentID == id) {
//          print(doc.data);
//          print(doc.data['first_name']);
          userMap.putIfAbsent(
            doc.documentID,
            () => UserData(
              firstName: doc.data['first_name'] ?? '',
              lastName: doc.data['last_name'] ?? '',
            ),
          );
          break;
        }
      }
    }
    return userMap;
  }

  Stream<QuerySnapshot> _filteredByUid(
      CollectionReference logCollection) async* {
    var filtered = await logCollection
        .where("seconds_since_epoch",
            isGreaterThanOrEqualTo: fromDate, isLessThanOrEqualTo: toDate)
        .orderBy("seconds_since_epoch", descending: true)
        .where(
          "uid",
          isEqualTo: this.uid,
        )
        .getDocuments();
    yield filtered;
  }

  Stream<QuerySnapshot> _filteredByDate(
      CollectionReference logCollection) async* {
    var filtered = await logCollection
        .where("seconds_since_epoch",
            isGreaterThanOrEqualTo: fromDate, isLessThanOrEqualTo: toDate)
        .orderBy("seconds_since_epoch", descending: true)
        .getDocuments();

    yield filtered;
  }

  Future<Map<String, UserData>> _getUserMap() async {
    final CollectionReference userCollection = firestore.collection("users");
    Map<String, UserData> userMap = {};
    if (_uids.isEmpty) {
      QuerySnapshot s = await userCollection.getDocuments();
      for (DocumentSnapshot doc in s.documents) {
        _uids.add(doc.documentID);
      }
    }
    try {
      userMap =
          await userCollection.snapshots().map(_userDataMapFromSnapshot).first;
    } catch (e) {
      print(e);
    }
    return userMap;
  }
}
