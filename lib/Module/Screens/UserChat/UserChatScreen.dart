import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase/Firebase/UserRealtimeDatabase.dart';
import 'package:flutter_firebase/Module/Screens/Message/messageScreen.dart';
import 'package:get/get.dart';

import '../../../Firebase/PostRealtimeDatabase.dart';

class UserChatScreen extends StatefulWidget {
  UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<UserChatScreen> {
  UserControllerRealTimeDataBase usercontrollerRealTimeDataBase =
      Get.find<UserControllerRealTimeDataBase>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<UserControllerRealTimeDataBase>(
      builder: (controller) => controller.isloaduser==true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    return cardUser(controller, index);
                  },
                ),
              ),
            ),
    ));
  }

  Card cardUser(UserControllerRealTimeDataBase controller, int index) {
    return Card(
                      child: InkWell(
                          onTap: () {
                            Get.to(MessageScreen(userChat: controller.users[index],));
                          },
                          child: ListTile(
                            title:
                                Text(controller.users[index].name.toString()),
                            subtitle: Text(controller.users[index].numberPhone
                                .toString()),
                            leading: Icon(CupertinoIcons.chat_bubble_text),
                          )));
  }
}
