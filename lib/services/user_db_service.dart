import 'package:attendance_app/models/user_data.dart';
import 'package:attendance_app/shared/user_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class UserDbService {
  @required
  final uid;
  final CollectionReference userCollection =
      Firestore.instance.collection("users");

  UserDbService({this.uid});

  Future addUser({@required firstName, @required lastName}) async {
    bool isAdmin = false;
    bool isActive = true;
    return await userCollection.document(uid).setData({
      'first_name': firstName,
      'last_name': lastName,
      'is_admin': isAdmin,
      'is_active': isActive,
    });
  }

  Future updateUser(
      {@required String userId,
      @required firstName,
      @required lastName,
      bool isActive}) async {
    bool isAdmin = false;
    return await userCollection.document(userId).updateData(
      {
        'first_name': firstName,
        'last_name': lastName,
        'is_admin': isAdmin,
        'is_active': isActive ?? true,
      },
    );
  }
}
