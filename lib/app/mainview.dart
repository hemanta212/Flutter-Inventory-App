import 'package:flutter/material.dart';
import 'package:bk_app/app/sellingform.dart';
import 'package:bk_app/app/itemform.dart';
import 'package:bk_app/app/itementryform.dart';

class NavDrawerExample extends StatelessWidget {
  const NavDrawerExample({Key key}) : super(key: key);

  void navigateTo({BuildContext context, String title}) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ItemForm(title:title);
    }));

      /*if (result == true){
        updateListView();
      }
      */
    }


  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text('User Name'),
      accountEmail: Text('user.name@email.com'),
      currentAccountPicture: CircleAvatar(
        child: FlutterLogo(size: 42.0),
        backgroundColor: Colors.white,
      ),
      otherAccountsPictures: <Widget>[
        CircleAvatar(
          child: Text('A'),
          backgroundColor: Colors.yellow,
        ),
        CircleAvatar(
          child: Text('B'),
          backgroundColor: Colors.red,
        )
      ],
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
          title: Text("Register Item"),
          onTap: () => navigateTo(context: context, title: "Register Item"),
        ),
        ListTile(
          title: Text('Add Stock'),
          onTap: () => navigateTo(context: context, title: "Stock entry"),
        ),
        ListTile(
          title: Text('other drawer item'),
          onTap: () {},
        ),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookkeeping app',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        accentColor: Colors.indigoAccent,
      ), // ThemeData
      home: SellingForm(title: 'Register sales'),
    );

  }

}
