import 'package:bk_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomScaffold {
  static Widget setDrawer(context) {
    UserData userData = Provider.of<UserData>(context);
    debugPrint("ROLESS NOW IN SCAFFOLD !!! ${userData.roles}");

    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text(userData.email),
        accountEmail: Text(userData.verified ? "" : "*Unverified"),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
              ? Colors.blue
              : Colors.white,
          child: Text(
            "H",
            style: TextStyle(fontSize: 40.0),
          ),
        ),
      ),
      ListTile(
          leading: Icon(Icons.home),
          title: Text("Home"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/mainForm");
          }),
      ListTile(
          leading: Icon(Icons.shopping_cart),
          title: Text('Items'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/itemList");
          }),
      ListTile(
          leading: Icon(Icons.card_travel),
          title: Text('Transactions'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/transactionList");
          }),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("/settings");
        },
      ),
    ]));
  }

  static Widget setAppBar(title, context) {
    return AppBar(
      title: Text(title),
    );
  }

  static Widget setScaffold(BuildContext context, String title, var getBody,
      {appBar = setAppBar}) {
    return Scaffold(
      appBar: appBar(title, context),
      drawer: setDrawer(context),
      body: getBody(context),
    ); // Scaffold
  }
} // Custom Scaffold
