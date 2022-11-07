import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase/Firebase/PostRealtimeDatabase.dart';
import 'package:flutter_firebase/Model/TPost.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/constant.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostScreen extends StatefulWidget {
  PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController postController = TextEditingController();
  PostControllerRealTimeDataBase controllerRealTimeDataBase =
      Get.find<PostControllerRealTimeDataBase>();
  String imagepath = '';
  String imagename = '';
  String urlImage = '';
  UploadTask? uploadTask;
  Future uploadImage() async {
    final path = 'Images/${imagename} ${DateTime.now().hour.minutes.inSeconds.milliseconds.toString()}';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                imagepath != ''
                    ? Image.file(
                        File(imagepath),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.contain,
                      )
                    : SizedBox.shrink(),
                    uploadTask==null?SizedBox.shrink():
                    buildProgress(), 
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: decorinput,
                        child: TextField(
                          decoration: decorTextFiled('..... إكتب منشورك'),
                          textAlign: TextAlign.center,
                          controller: postController,
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
                    Container(
                      decoration: decor,
                      child: TextButton(
                          onPressed: () async {
                            if (imagepath != '') {
                              await uploadImage();
                              setState(() {
                                imagepath = '';
                              });
                            } else {
                              Get.snackbar('title', 'Image if you want');
                            }
                            TPost post = TPost(
                                post: postController.text,
                                imageUrl: urlImage,
                                date_slug: DateTime.now()
                                    .day
                                    .hours
                                    .inMinutes
                                    .seconds
                                    .inMilliseconds
                                    .toString());
                            if (postController.text.isNotEmpty ||
                                urlImage != '') {
                              controllerRealTimeDataBase.writeFirebase(post);
                              postController.clear();
                            } else if (postController.text.isEmpty) {
                              Get.snackbar(
                                  'إضافة منشور', 'الرجاء كتابة المنشور');
                            }
                          },
                          child: const Text('نشر')),
                    )
                  ],
                ),
              ],
            ),
          ),
          GetBuilder<PostControllerRealTimeDataBase>(
            builder: (controller) => Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.posts.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                         controller.posts[index].imageUrl==''?SizedBox.shrink(): Image.network(
                            controller.posts[index].imageUrl!,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            fit: BoxFit.contain,
                            height: 200,
                            width: double.infinity,
                          ),
                          Center(
                              child: Text(
                            '${controller.posts[index].post}',
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          )),
                          TextButton.icon(
                              onPressed: () {
                                Share.share(
                                    '${controller.posts[index].imageUrl.toString()} \n ${controller.posts[index].post}',
                                    subject: controller.posts[index].post);
                                //onShare(context);
                              },
                              icon: Icon(Icons.share),
                              label: Text('share'))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(height: 50,
          child: Stack(fit: StackFit.expand,children: [
            LinearProgressIndicator(value: progress,backgroundColor: Colors.grey,
            color: Colors.green,),Center(child: Text('${(100*progress).roundToDouble()}%',style: const TextStyle(color: Colors.white),),)
          ],),
          );
        } else {
          return const SizedBox(
            height: 5,
          );
        }
      });
}
