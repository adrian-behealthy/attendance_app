import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class UserDbService {
  @required
  final uid;
  final CollectionReference users = Firestore.instance.collection("users");

  UserDbService({@required this.uid});

  Future addUser({@required firstName, @required lastName}) async {
    bool isAdmin = false;
    bool isActive = true;
    return await users.document(uid).setData({
      'first_name': firstName,
      'last_name': lastName,
      'is_admin': isAdmin,
      'is_active': isActive,
    });
  }

  Future updateUser(
      {@required firstName, @required lastName, bool isActive}) async {
    bool isAdmin = false;
    return await users.document(uid).setData({
      'first_name': firstName,
      'last_name': lastName,
      'is_admin': isAdmin,
      'is_active': isActive ?? true,
    });
  }
}
