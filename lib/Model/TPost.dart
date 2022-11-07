class TPost {
  TPost({this.post, this.imageUrl,this.favoritecount = 0, this.date_slug});
  String? post;
  String? imageUrl;
  int? favoritecount = 0;
  String? date_slug;
  Map<String, dynamic> toJson() => {
        "post": post == null ? null : post,
        "favoritecount": favoritecount == null ? null : favoritecount,
        "date_slug": favoritecount == null ? null : favoritecount,
      };
  factory TPost.fromJson(Map<dynamic, dynamic> json) => TPost(
      post: json['post'],
      imageUrl: json['imageUrl'],
      favoritecount: json['favoritecount'],
      date_slug: json['date_slug']);
}
