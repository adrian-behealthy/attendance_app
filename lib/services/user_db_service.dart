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
      {@required firstName, @required lastName, bool isActive}) async {
    bool isAdmin = false;
    return await userCollection.document(uid).setData(
      {
        'first_name': firstName,
        'last_name': lastName,
        'is_admin': isAdmin,
        'is_active': isActive ?? true,
      },
    );
  }

  UserData _userDataFromSnapshot(QuerySnapshot snapshot) {
    return UserData(
        firstName: snapshot.documents.asMap()["first_name"],
        lastName: snapshot.documents.asMap()["last_name"],
        isActive: snapshot.documents.asMap()['is_active'],
        isAdmin: snapshot.documents.asMap()['is_admin']);
  }

  Stream<UserData> getUserData(UserFilter userFilter) {
    print(userFilter);
    switch (userFilter) {
      case UserFilter.All:
        print("All");
        return userCollection.snapshots().map(_userDataFromSnapshot);
      case UserFilter.AllNonAdminUsers:
        print("AllnonAdminusers");
        return userCollection
            .snapshots()
            .map(_userDataFromSnapshot)
            .where((userData) => !userData.isAdmin);
      case UserFilter.AllAdminUsers:
        return userCollection
            .snapshots()
            .map(_userDataFromSnapshot)
            .where((userData) => userData.isAdmin);
      case UserFilter.AllActiveNonAdminUsers:
        return userCollection
            .snapshots()
            .map(_userDataFromSnapshot)
            .where((userData) => !userData.isAdmin && userData.isActive);
      //case UserFilter.AllNonActiveNonAdminUsers:
      default:
        return userCollection
            .snapshots()
            .map(_userDataFromSnapshot)
            .where((userData) => !userData.isAdmin && !userData.isActive);
    }
  }
}
