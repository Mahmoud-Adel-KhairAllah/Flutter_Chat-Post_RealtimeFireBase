import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../Model/TPost.dart';

class PostControllerRealTimeDataBase extends GetxController {
  List<TPost> posts = [];
  getPosts() {
    FirebaseDatabase.instance
        .ref("Posts")
        .orderByChild('date_slug')
        .onValue
        .listen((event) {
      posts.clear();

      final data = Map<String?, dynamic>.from(
        event.snapshot.value as Map,
      );
    
      
      data.forEach((key, value) {
        posts.add(TPost.fromJson(value));
      });

      update();
    });
  }

  writeFirebase(TPost post) async {
    DatabaseReference postListRef = FirebaseDatabase.instance.ref('Posts');
    DatabaseReference newPostRef = postListRef.push();
    if (post.post != null||post.imageUrl != '') {
      newPostRef.set({
        'post': post.post,
        'imageUrl':post.imageUrl,
        'favoritecount': post.favoritecount,
        'date_slug': post.date_slug
      }).then((value) => Get.snackbar('إضافة', 'تمت الإضافة بنجاح'));
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getPosts();
    super.onInit();
  }
}
