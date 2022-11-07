import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/Model/TUserChat.dart';
import 'package:get/get.dart';

class UserControllerRealTimeDataBase extends GetxController {
  List<TUserChat> users = [];
  bool isloaduser = false;
  getUsers() {
    isloaduser = true;

    FirebaseDatabase.instance.ref("Users").orderByKey().onValue.listen((event) {
      users.clear();
      final data = Map<String?, dynamic>.from(
        event.snapshot.value as Map,
      );

      data.forEach((key, value) {
        print("$value");
        print('------------------------>${TUserChat.fromJson(value).name}');

        users.add(TUserChat.fromJson(value));
      });
      update();
      isloaduser = false;
    });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getUsers();
    super.onInit();
  }
}
