import 'package:attendance_app/models/log.dart';
import 'package:attendance_app/models/user.dart';
import 'package:attendance_app/models/user_data.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogDbService {
  final String uid;
  final CollectionReference logCollection =
      Firestore.instance.collection("logs");

  LogDbService({@required this.uid});

  Future addData(
      {@required bool isIn,
      String projectName,
      @required double lat,
      @required double lng,
      String comment}) async {
    return await logCollection.document().setData({
      'is_in': isIn,
      'project_name': projectName,
      'location': GeoPoint(lat, lng),
      'uid': uid,
      'seconds_since_epoch':
          (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      'comment': comment
    });
  }

  Future updateData(
      {@required String logId,
      @required bool isIn,
      String projectName,
      @required double lat,
      @required double lng,
      String comment}) async {
    return await logCollection.document(logId).updateData({
      'is_in': isIn,
      'project_name': projectName,
      'location': GeoPoint(lat, lng),
      'uid': uid,
      'seconds_since_epoch':
          (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      'comment': comment
    });
  }

  static Stream<List<Log>> logs(String uid, int fromDate, int toDate) async* {
    final Firestore firestore = Firestore.instance;

    final CollectionReference logCollection = firestore.collection("logs");

    List<Log> logList = [];
    print(fromDate);
    print(toDate);
//    Stream<QuerySnapshot> filteredLogSnapshots
    CollectionReference filteredLogs = logCollection
//        .orderBy("seconds_since_epoch", descending: true)
        .where("seconds_since_epoch",
            isGreaterThanOrEqualTo: fromDate, isLessThanOrEqualTo: toDate);

//    await logCollection.snapshots()
    await filteredLogs
        .snapshots()
        .map(_logListFromSnapshot)
        .first
        .then((list) async {
      logList = await list;
    });
    if (logList.isNotEmpty) yield logList;
  }

  static Future<List<Log>> _logListFromSnapshot(QuerySnapshot snapshot) async {
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
      print("timeStamp ${doc.data["seconds_since_epoch"]}");
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

  static Map<String, UserData> _userDataListFromSnapshot(
      QuerySnapshot snapshot) {
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
