import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase/Model/TUserChat.dart';
import 'package:flutter_firebase/Module/Screens/Home/HomeScreen.dart';
import 'package:flutter_firebase/utils/constant.dart';
import 'package:get/get.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({super.key, this.verificationId, this.name});
  String? verificationId;
  String? name;
  TextEditingController controller = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: decorinput,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '586',
                    ),
                  ),
                )),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: decor,
              child: TextButton(
                child: const Text('تأكيد الكود'),
                onPressed: () async {
                  try {
                    // Create a PhoneAuthCredential with the code
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId!,
                            smsCode: controller.text);

                    // Sign the user in (or link) with the credential
                    await auth.signInWithCredential(credential);
                    FirebaseAuth.instance
                        .authStateChanges()
                        .listen((User? user) {
                      if (user != null) {
                        TUserChat userChat = TUserChat(
                            id: user.uid,
                            name: name,
                            numberPhone: user.phoneNumber);
                        writeUserFirebase(userChat);
                      }
                    });

                    Get.to(HomeScreen());
                  } catch (e) {
                    print(e.toString());
                  }
                },
              ),
            )
          ],
        ),
      )),
    );
  }
}

writeUserFirebase(TUserChat user) async {
  DatabaseReference postListRef = FirebaseDatabase.instance.ref('Users');
  DatabaseReference newUsertRef = postListRef.push();
  if (user != null) {
    newUsertRef
        .set({'id':user.id,'name':user.name,'numberPhone':user.numberPhone})
        .then((value) => Get.snackbar('إضافة', 'تم التسجيل بنجاح'));
  }
}
