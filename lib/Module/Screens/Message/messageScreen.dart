import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase/App/App.dart';
import 'package:flutter_firebase/Firebase/MessageRealtimeDatabase.dart';
import 'package:flutter_firebase/Model/TMessage.dart';
import 'package:flutter_firebase/Model/TUserChat.dart';
import 'package:flutter_firebase/utils/constant.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../Posts/PostScreen.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({super.key, this.userChat});
  TUserChat? userChat;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<TMessage> messages = [];

  TextEditingController messageController = TextEditingController();

  MessageControllerRealTimeDataBase messageControllerRealTimeDataBase =
      Get.find<MessageControllerRealTimeDataBase>();

  String imagepath = '';

  String imagename = '';

  String urlImage = '';

  UploadTask? uploadTask;

  Future uploadImage() async {
    final path =
        'Images/${imagename}${DateTime.now().hour.minutes.inSeconds.milliseconds.toString()}';
    final file = File(imagepath);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!
        .whenComplete(() => {Get.snackbar('image', 'تم رفع الصورة بنجاح')});

    urlImage = await snapshot.ref.getDownloadURL();
    print('=================>${urlImage}');
    setState(() {
      uploadTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.userChat!.name.toString())),
        body: buildBody());
  }

  GetBuilder<MessageControllerRealTimeDataBase> buildBody() =>
      messageGetBuilder();

  GetBuilder<MessageControllerRealTimeDataBase> messageGetBuilder() {
    return GetBuilder<MessageControllerRealTimeDataBase>(
      builder: (controller) => Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: messageListViewBuilder(controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: messageTextFiled(controller),
            )
          ],
        ),
      ),
    );
  }

  Column messageTextFiled(MessageControllerRealTimeDataBase controller) {
    return Column(
      children: [
        imagepath != ''
            ? Image.file(
                File(imagepath),
                width: double.infinity,
                height: 150,
                fit: BoxFit.contain,
              )
            : SizedBox.shrink(),
        uploadTask == null ? SizedBox.shrink() : buildProgress(),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: decorinput,
                child: TextField(
                  controller: messageController,
                  textAlign: TextAlign.center,
                  decoration: decorTextFiled('....الرسالة'),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Container(
                child: IconButton(
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();

                if (result != null) {
                  PlatformFile file = result.files.first;

                  print('---------------->${file.name}');
                  print('---------------->${file.bytes}');
                  print('---------------->${file.size}');
                  print('---------------->${file.extension}');
                  print('---------------->${file.path}');
                  setState(() {
                    imagepath = file.path!;
                    imagename = file.name;
                  });
                } else {
                  // User canceled the picker
                }
              },
            )),
            SizedBox(
              width: 5,
            ),
            Container(
                decoration: decor,
                child: TextButton.icon(
                  onPressed: () async {
                    if (imagepath != '') {
                      await uploadImage();
                      setState(() {
                        imagepath = '';
                      });
                    }
                    TMessage message = TMessage(
                        senderid: App.uid.toString(),
                        reciverid: widget.userChat!.id,
                        message: messageController.text,
                        urlImage: urlImage);
                    writeMessageFirebase(message);
                    if (messageController.text.isNotEmpty || imagepath != '') {
                      if (App.uid != null) {
                        messageController.clear();
                        // controller.messages.clear();
                      }
                    }
                  },
                  label: const Text('إرسال'),
                  icon: const Icon(Icons.send),
                ))
          ],
        ),
      ],
    );
  }

  ListView messageListViewBuilder(
      MessageControllerRealTimeDataBase controller) {
    return ListView.builder(
      itemCount: controller.messages.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (controller.messages[index].senderid == App.uid &&
                controller.messages[index].reciverid == widget.userChat!.id ||
            controller.messages[index].reciverid == App.uid &&
                controller.messages[index].senderid == widget.userChat!.id) {
          return controller.messages[index].senderid == App.uid
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: messageCard(
                      alignment: Alignment.centerLeft,
                      controller: controller,
                      index: index,
                      colorcard: Colors.white,
                      colortext: Colors.black,
                      textAlign: TextAlign.end),
                )
              : Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      messageCard(
                          alignment: Alignment.centerRight,
                          controller: controller,
                          index: index,
                          colorcard: Colors.blue,
                          colortext: Colors.white,
                          textAlign: TextAlign.end),
                    ],
                  ),
                );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Align messageCard(
      {required MessageControllerRealTimeDataBase controller,
      required int index,
      required Color colorcard,
      required Color colortext,
      required TextAlign textAlign,
      required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: Column(
        children: [
          controller.messages[index].urlImage == ''
              ? SizedBox.shrink()
              : Image.network(
                  controller.messages[index].urlImage!,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  },
                  fit: BoxFit.cover,
                  height: 200,
                ),
          controller.messages[index].message == ''
              ? SizedBox.shrink()
              : Card(
                  color: colorcard,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${controller.messages[index].message.toString()}',
                      textAlign: textAlign,
                      style: TextStyle(
                        color: colortext,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
        ],
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 5,
          );
        }
      });
}

writeMessageFirebase(TMessage message) async {
  DatabaseReference postListRef = FirebaseDatabase.instance.ref('Messages');
  DatabaseReference newUsertRef = postListRef.push();
  if (message != null) {
    newUsertRef.set({
      'senderid': message.senderid,
      'reciverid': message.reciverid,
      'message': message.message,
      'urlImage': message.urlImage
    }).then((value) => Get.snackbar('إضافة', 'تم إرسال الرسالة'));
  }
}
