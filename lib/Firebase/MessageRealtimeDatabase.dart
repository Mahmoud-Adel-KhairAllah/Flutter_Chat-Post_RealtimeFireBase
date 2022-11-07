import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/Model/TMessage.dart';
import 'package:flutter_firebase/Model/TUserChat.dart';
import 'package:get/get.dart';

import '../App/App.dart';

class MessageControllerRealTimeDataBase extends GetxController {
  List<TMessage> messages = [];
  List<TMessage> messagesprivet = [];
  getMessages() {
    FirebaseDatabase.instance.ref("Messages").onValue.listen((event) {
      messages.clear();
      final data = Map<String?, dynamic>.from(
        event.snapshot.value as Map,
      );

      data.forEach((key, value) {
        print("$value");
        if (TMessage.fromJson(value).senderid == App.uid ||
            TMessage.fromJson(value).reciverid == App.uid) {
          print('------------------------>${TMessage.fromJson(value).message}');
          messages.add(TMessage.fromJson(value));
        }
      });
      update();
    });
  }

  List<TMessage> getmessagesPrivet(String id) {
    List<TMessage> messagesprivet = [];
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].senderid == user.uid && messages[i].reciverid == id) {
            print('message------------------>${messagesprivet[i].message}');
            print('senderid------------------>${messagesprivet[i].senderid}');
            print('reciverid------------------>${messagesprivet[i].reciverid}');
            messagesprivet.add(messages[i]);
            update();
            // Get.snackbar(controller.messages[index].senderid.toString(),
            //     controller.messages[index].reciverid.toString());
          }
        }
      }
    });
    return messagesprivet;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getMessages();

    getmessagesPrivet('DpNixspB1PT0n4y9vtnLhyWfG5T2');

    super.onInit();
  }
}
