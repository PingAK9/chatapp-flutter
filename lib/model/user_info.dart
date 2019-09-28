class User {
  String nickname;
  String photoUrl;
  String id;
  String info;

  User({this.nickname, this.photoUrl, this.id, this.info});

  clone() {
    return new User(nickname: nickname, photoUrl: photoUrl, id: id, info: info);
  }

  User.fromJson(json) {
    nickname = json['nickname'] ?? '';
    photoUrl = json['photoUrl'] ?? '';
    id = json['id'] ?? '';
    info = json['info'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nickname'] = this.nickname;
    data['photoUrl'] = this.photoUrl;
    data['id'] = this.id;
    data['info'] = this.info;
    return data;
  }

  String groupChatID(user){
    if (id.hashCode <= user.id.hashCode) {
      return '$id-${user.id}';
    } else {
      return '${user.id}-$id';
    }
  }
}
