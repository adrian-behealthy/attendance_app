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
}
