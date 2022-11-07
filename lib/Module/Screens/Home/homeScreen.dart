import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase/Module/Screens/UserChat/UserChatScreen.dart';
import 'package:flutter_firebase/Module/Screens/Home/homeController.dart';
import 'package:flutter_firebase/Module/Screens/Posts/PostScreen.dart';
import 'package:get/get.dart';
// TODO: Import google_mobile_ads.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../Helper/adHelper.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
HomeController homeController =
      Get.find<HomeController>();
Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }
 

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: const Text('logout'),
                onTap: () async {
                  await FirebaseAuth.instance
                      .signOut()
                      .then((value) => exit(0)); // ...
                },
              ),
            ],
          )),
          appBar: AppBar(
            title: Text('Chat'),
            
            centerTitle: true,
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(Icons.chat),
                text: 'Chat',
              ),
              Tab(
                icon: Icon(Icons.post_add),
                text: 'Posts',
              ),
            ]),
          ),
          body:  SafeArea(
            child: Stack(
              children: 
                [TabBarView(children: [
                   UserChatScreen(),
                  PostScreen()
                ]),


              ],
            ),
          ),
        ));
  }
}

