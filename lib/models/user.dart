class User {
  /// simple small class for bouncing things with firebase auth
  final String uid;
  User({this.uid});
}

class UserData {
  /// More private userData to store general info about users
  String username;
  String uid;
  String email;
  UserData({this.uid, this.username, this.email});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['username'] = this.username;
    map['email'] = this.email;
    map['uid'] = this.uid;
    return map;
  }

  UserData.fromMapObject(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.email = map['email'];
    this.username = map['username'];
  }
}

class UserContent {
  /// User generated contents
  String username;
  Map roles;
  Map items;
  Map transactions;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['username'] = this.username;
    map['roles'] = this.roles;
    map['items'] = this.items;
    map['transactions'] = this.transactions;
    return map;
  }

  UserContent.fromMapObject(Map<String, dynamic> map) {
    this.username = map['username'];
    this.roles = map['roles'];
    this.items = map['items'];
    this.transactions = map['transactions'];
  }
}
