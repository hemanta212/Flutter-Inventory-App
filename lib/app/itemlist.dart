import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/user.dart';
import 'package:bk_app/services/crud.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/loading.dart';

class ItemList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ItemListState();
  }
}

class ItemListState extends State<ItemList> {
  static CrudHelper crudHelper;
  Stream<QuerySnapshot> items;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    UserData userData = Provider.of<UserData>(context);
    crudHelper = CrudHelper(userData: userData);
    _updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Items"),
      ),
      drawer: CustomScaffold.setDrawer(context),
      body: getItemListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Item(''), 'Create Item');
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getItemListView() {
    ThemeData localTheme = Theme.of(context);
    return StreamBuilder(
        stream: this.items,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot itemSnapshot = snapshot.data.documents[index];
                Item item = Item.fromMapObject(itemSnapshot.data);
                return GestureDetector(
                    key: Key(item.name),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.keyboard_arrow_right),
                      ),
                      title: _getNameAndPrice(context, item),
                      subtitle: Text(item.nickName ?? '',
                          style: localTheme.textTheme.body1),
                      onTap: () {
                        this._showItemInfoDialog(item);
                      },
                      onLongPress: () {
                        String itemId = itemSnapshot.documentID;
                        navigateToDetail(item, 'Edit Item', itemId: itemId);
                      },
                    ),
                    onVerticalDragEnd: (DragEndDetails details) {
                      this._initiateTransaction("Stock Entry", itemSnapshot);
                    },
                    onHorizontalDragEnd: (DragEndDetails details) {
                      this._initiateTransaction("Sales Entry", itemSnapshot);
                    });
              },
            );
          } else {
            return Loading();
          }
        });
  }

  void _showItemInfoDialog(Item item) async {
    ThemeData itemInfoTheme = Theme.of(context);

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              // TODO Image(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(item.name, style: itemInfoTheme.textTheme.display1),
                      Text(item.nickName ?? '',
                          style: itemInfoTheme.textTheme.subhead.copyWith(
                            fontStyle: FontStyle.italic,
                          )),
                      Row(
                        children: <Widget>[
                          WindowUtils.getCard("Marked Price"),
                          WindowUtils.getCard("${item.markedPrice ?? "N/A"}"),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          WindowUtils.getCard("Current CP"),
                          WindowUtils.getCard(FormUtils.fmtToIntIfPossible(
                              FormUtils.getShortDouble(item.costPrice ?? 0.0))),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          WindowUtils.getCard("Total Stocks"),
                          WindowUtils.getCard(
                              FormUtils.fmtToIntIfPossible(item.totalStock)),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text("${item.description ?? ''}",
                          style: itemInfoTheme.textTheme.body1),
                    ]),
              ),
            ],
          );
        });
  }

  void navigateToDetail(Item item, String name, {itemId}) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ItemEntryForm(
          title: name, item: item, itemId: itemId, forEdit: true);
    }));

    if (result == true) {
      this._updateListView();
    }
  }

  void _initiateTransaction(String formName, itemSnapshot) async {
    String itemName = itemSnapshot.data['name'];
    Map formMap = {
      'Sales Entry':
          SalesEntryForm(swipeData: itemSnapshot, title: "Sell $itemName"),
      'Stock Entry':
          StockEntryForm(swipeData: itemSnapshot, title: "Buy $itemName")
    };

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => formMap[formName]));
  }

  void _updateListView() {
    setState(() {
      this.items = crudHelper.getItems();
    });
  }

  static Widget _getNameAndPrice(BuildContext context, Item item) {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;
    String name = item.name;
    String markedPrice = FormUtils.fmtToIntIfPossible(item.markedPrice);
    String finalMarkedPrice = markedPrice.isEmpty ? "" : "Rs $markedPrice";
    return Row(children: <Widget>[
      Expanded(flex: 1, child: Text(name, style: nameStyle)),
      Visibility(
          visible: finalMarkedPrice == '' ? false : true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10.0, width: 1.0),
              Text("Price", style: nameStyle.copyWith(fontSize: 14.0)),
              Text(finalMarkedPrice, style: nameStyle),
            ],
          )),
    ]);
  }
}
