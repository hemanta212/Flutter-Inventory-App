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
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final _formKey = GlobalKey<FormState>();
  String _currentTargetEmail;

  static CrudHelper crudHelper;
  static UserData userData;
  static AuthService _auth = AuthService();

  Map currentMonthHistory = Map();
  final double _minimumPadding = 5.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    if (userData != null) {
      crudHelper = CrudHelper(userData: userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
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
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: FutureBuilder<UserData>(
            future: crudHelper.getUserDataByUid(userData.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserData userData = snapshot.data;
                return ListView(children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        initialValue: userData.targetEmail,
                        decoration: InputDecoration(
                          labelText: "Target Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        onChanged: (val) =>
                            setState(() => _currentTargetEmail = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                          enabled: false,
                          initialValue: userData.email,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          )),
                      Visibility(
                          visible: userData.verified ? false : true,
                          child: Row(children: <Widget>[
                            RaisedButton(
                              color: Colors.white,
                              child: Text('Email Not verified',
                                  style: TextStyle(color: Colors.red[400])),
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
                              color: Colors.white,
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
                                this.showDialogForRoles(userData);
                              });
                            }),
                      ]),
                      this.showRolesMapping(userData),
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
            }));
  }

  void checkAndSave() async {
    if (_formKey.currentState.validate()) {
      userData.targetEmail = this._currentTargetEmail ?? userData.email;
      crudHelper.updateUserData(userData);
      Navigator.pop(context);
    }
  }

  Widget showRolesMapping(UserData userData) {
    return userData.roles?.isNotEmpty ?? false
        ? Padding(
            padding: EdgeInsets.only(right: 10.0, left: 10.0),
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
                            child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: email,
                          ),
                        )),
                        Expanded(
                            child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: role,
                          ),
                        )),
                        GestureDetector(
                            child: Icon(Icons.edit),
                            onTap: () {
                              setState(() {
                                showDialogForRoles(userData,
                                    email: email, role: role);
                              });
                            }),
                      ]));
                }))
        : SizedBox(width: 20.0);
  }

  void showDialogForRoles(UserData userData, {String email, String role}) {
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
                                userData.roles[email] = role;
                                crudHelper.updateUserData(userData);
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
                                if (userData.roles.containsKey(email)) {
                                  userData.roles.remove(email);
                                  crudHelper.updateUserData(userData);
                                }
                                role = '';
                                email = '';
                                setState(() => Navigator.pop(context));
                              }
                            }),
                      ]))));
        });
  }
}
