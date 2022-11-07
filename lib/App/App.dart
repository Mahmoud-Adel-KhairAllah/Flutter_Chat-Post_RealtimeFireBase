import 'package:firebase_auth/firebase_auth.dart';

class App {
 static String? uid;
  static getuid() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        uid = user.uid;
        print('uid------------>${user.uid}');
      }
    });
  }
}
