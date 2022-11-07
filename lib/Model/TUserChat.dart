class TUserChat {
    TUserChat({
        this.id,
        this.name,
        this.numberPhone,
       
    });

    String? id;
    String? name;
    String? numberPhone;
    
factory TUserChat.fromJson(Map<dynamic, dynamic> json) =>
      TUserChat(id: json['id'], name: json['name'],numberPhone: json['numberPhone']);


    Map<String, String?> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "numberPhone": numberPhone == null ? null : numberPhone,
       
    };
}