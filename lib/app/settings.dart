import 'package:bk_app/models/user.dart';
import 'package:bk_app/services/crud.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  final _formKey = GlobalKey<FormState>();

  static CrudHelper crudHelper;
  UserData userData;
  static AuthService _auth = AuthService();

  Map currentMonthHistory = Map();
  final double _minimumPadding = 5.0;
  TextEditingController targetEmailController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.userData = Provider.of<UserData>(context);
    if (this.userData != null) {
      crudHelper = CrudHelper(userData: this.userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.userData == null) {
      return Wrapper();
    }
    return Scaffold(
      appBar: AppBar(
          leading: Icon(Icons.settings),
          title: Text("Settings"),
          actions: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.person),
                    onPressed: () async {
                      setState(() {
                        _auth.signOut();
                      });
                    }),
                Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text('Log out')),
              ],
            )
          ]),
      drawer: CustomScaffold.setDrawer(context),
      body: this.getSettings(),
    );
  }

  Widget getSettings() {
    final localTheme = Theme.of(context);
    return Material(
        child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: FutureBuilder<UserData>(
                future: crudHelper.getUserDataByUid(this.userData.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    UserData _userData = snapshot.data;
                    this.targetEmailController.text =
                        _userData.targetEmail ?? '';
                    return ListView(children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          SizedBox(height: 20.0),
                          TextFormField(
                              decoration: InputDecoration(
                                labelText: "Target Email",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                              controller: this.targetEmailController,
                              validator: (val) {
                                if (val.isEmpty) {
                                  setState(() {
                                    this.targetEmailController.text =
                                        this.userData.email;
                                  });
                                }
                                return null;
                              }),
                          SizedBox(height: 10.0),
                          TextFormField(
                              enabled: false,
                              initialValue: _userData.email,
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              )),
                          Visibility(
                              visible: _userData.verified ? false : true,
                              child: Row(children: <Widget>[
                                RaisedButton(
                                  color: Colors.red,
                                  child: Text('Email Not verified',
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () {},
                                ),
                                SizedBox(width: 20.0),
                                RaisedButton(
                                    color: Colors.blue[400],
                                    child: Text(
                                      'Send verification',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      print("sending verification");
                                    })
                              ])),
                          SizedBox(height: 20.0),
                          Row(children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                  child: Text('Roles',
                                      style: localTheme.textTheme.title)),
                            ),
                            RaisedButton(
                                color: Colors.blue[400],
                                child: Text(
                                  'Add roles',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.showDialogForRoles();
                                  });
                                }),
                          ]),
                          this.showRolesMapping(this.userData),
                          SizedBox(height: 20.0),

                          // save
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: _minimumPadding * 3,
                                  top: 3 * _minimumPadding),
                              child: Row(children: <Widget>[
                                WindowUtils.genButton(
                                    context, "Save", this.checkAndSave),
                                Container(
                                  width: _minimumPadding,
                                ),
                                WindowUtils.genButton(context, "Discard",
                                    () => Navigator.pop(context))
                              ]) // Row

                              ), // Paddin
                        ]),
                      )
                    ]);
                  } else {
                    return Loading();
                  }
                })));
  }

  void checkAndSave() async {
    if (_formKey.currentState.validate()) {
      print("currentTargetEmail is ${this.targetEmailController.text}");
      this.userData.targetEmail = this.targetEmailController.text;
      if (!await validateTargetEmail(this.userData)) {
        WindowUtils.showAlertDialog(context, "Failed",
            "You don't have access rights to this target email\n${this.userData.targetEmail}");
        return;
      }
      print("saving this.userData ${this.userData.roles}");
      crudHelper.updateUserData(this.userData);
      Navigator.pop(context);
    }
  }

  static Future<bool> validateTargetEmail(userData) async {
    print("userdata email is ${userData.email} and ${userData.targetEmail}");
    if (userData.email == userData.targetEmail) return true;

    UserData targetUserData =
        await crudHelper.getUserData('email', userData.targetEmail);
    if (targetUserData?.roles?.isEmpty ?? true) {
      return false;
    } else {
      if (targetUserData.roles.containsKey(userData.email))
        return true;
      else
        return false;
    }
  }

  Widget showRolesMapping(UserData userData) {
    double _minimumPadding = 5.0;
    return userData.roles?.isNotEmpty ?? false
        ? Padding(
            padding: EdgeInsets.only(right: 1.0, left: 1.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: userData.roles.keys?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  String email = userData.roles.keys.toList()[index];
                  String role = userData.roles[email];
                  return Card(
                      elevation: 5.0,
                      child: Row(children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: _minimumPadding * 3,
                                  bottom: _minimumPadding * 3),
                              padding: EdgeInsets.all(_minimumPadding),
                              child: Text(email, softWrap: true),
                            )),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(role, softWrap: true),
                        )),
                        GestureDetector(
                            child: Icon(Icons.edit),
                            onTap: () {
                              setState(() {
                                showDialogForRoles(email: email, role: role);
                              });
                            }),
                      ]));
                }))
        : SizedBox(width: 20.0);
  }

  void showDialogForRoles({String email, String role}) {
    final _roleFormKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              elevation: 5.0,
              title: Text(
                "Add roles",
              ),
              content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      key: _roleFormKey,
                      child: ListView(children: <Widget>[
                        TextFormField(
                            initialValue: email ?? '',
                            decoration: InputDecoration(
                              labelText: "Email",
                            ),
                            onChanged: (val) => setState(() => email = val),
                            validator: (val) {
                              if (val?.isEmpty ?? false) {
                                return "Please fill this field";
                              } else {
                                return null;
                              }
                            }),
                        SizedBox(width: 20.0),
                        TextFormField(
                            initialValue: role ?? '',
                            decoration: InputDecoration(
                              labelText: "Role",
                            ),
                            onChanged: (val) => setState(() => role = val),
                            validator: (val) {
                              if (val?.isEmpty ?? false) {
                                return "Please fill this field";
                              } else {
                                return null;
                              }
                            }),
                        SizedBox(width: 20.0),
                        RaisedButton(
                            color: Colors.blue[400],
                            child: Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_roleFormKey.currentState.validate()) {
                                if (this.userData.roles == null) {
                                  this.userData.roles = Map();
                                }
                                this.userData.roles[email] = role;
                                print(
                                    "updating this.userData ${this.userData.roles}");
                                crudHelper.updateUserData(this.userData);
                                setState(() => Navigator.pop(context));
                              }
                            }),
                        RaisedButton(
                            color: Colors.red[400],
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_roleFormKey.currentState.validate()) {
                                if (this.userData.roles.containsKey(email)) {
                                  this.userData.roles.remove(email);
                                  crudHelper.updateUserData(this.userData);
                                }
                                role = '';
                                email = '';
                                setState(() => Navigator.pop(context));
                              } else {
                                setState(() => Navigator.pop(context));
                              }
                            }),
                      ]))));
        });
  }
}
