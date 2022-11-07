class TMessage {
  TMessage({this.senderid, this.reciverid, this.message, this.urlImage});
  String? senderid;
  String? reciverid;
  String? message;
  String? urlImage;
  factory TMessage.fromJson(Map<dynamic, dynamic> json) => TMessage(
      senderid: json['senderid'],
      reciverid: json['reciverid'],
      message: json['message'],
      urlImage: json['urlImage']
      
      );
}
