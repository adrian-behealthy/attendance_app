
import 'package:attendance_app/services/user_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future registerNewUser(
      String email, String password, String firstName, String lastName) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (user != null) {
        UserDbService(uid: user.uid).addUser(
          firstName: firstName,
          lastName: lastName,
        );
        return null;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
