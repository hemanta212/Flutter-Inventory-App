class UserData {
  /// More private userData to store general info about users
  String uid;
  String email;
  bool verified;
  String targetEmail = 'sharmahemanta.212@gmail.com';
  Map roles;
  UserData({this.uid, this.email, this.verified, this.roles});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['targetEmail'] = this.targetEmail;
    map['email'] = this.email;
    map['uid'] = this.uid;
    map['verified'] = this.verified;
    map['roles'] = this.roles;
    return map;
  }

  UserData.fromMapObject(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.verified = map['verified'];
    this.email = map['email'];
    this.targetEmail = map['targetEmail'];
    this.roles = map['roles'];
  }
}
