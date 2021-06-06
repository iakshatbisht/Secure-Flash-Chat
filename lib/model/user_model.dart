class UserModel{
  String? _nickname;
  String? _id;
  String? _aboutMe;
  String? _photoUrl;
  String? _email;
  List<String>? _followers;
  String? _createdAt;

  String? get nickname => _nickname;

  set nickname(value) {
    _nickname = value;
  }

  String? get id => _id;

  set id(value) {
    _id = value;
  }

  String? get aboutMe => _aboutMe;

  set aboutMe(value) {
    _aboutMe = value;
  }

  String? get photoUrl => _photoUrl;

  set photoUrl(value) {
    _photoUrl = value;
  }

  String? get email => _email;

  set email(value) {
    _email = value;
  }

  List<String>? get followers => _followers;

  set followers(value) {
    _followers = value;
  }

  String? get createdAt => _createdAt;

  set createdAt(value) {
    _createdAt = value;
  }

  Map toMap() {
    var map = Map<String, dynamic>();
    map['createdAt'] = createdAt;
    map['email'] = email;
    map['followers'] = followers;
    map['id'] = id;
    map['nickname'] = nickname;
    map['photoUrl'] = photoUrl;
    map['aboutMe'] = aboutMe;
    return map;
  }

  UserModel fromMap(Map<String, dynamic> map) {
    UserModel _user = UserModel();
    _user.createdAt = map['createdAt'];
    _user.email = map['email'];
    _user.followers = map['followers'];
    _user.id = map['id'];
    _user.nickname = map['nickname'];
    _user.photoUrl = map['photoUrl'];
    _user.aboutMe = map['aboutMe'];
    return _user;
  }

}