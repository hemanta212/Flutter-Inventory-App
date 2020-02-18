import 'package:flutter/material.dart';

import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/blocs/database_bloc.dart';

class ItemList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ItemListState();
  }
}

class ItemListState extends State<ItemList> {
  DbHelper databaseHelper = DbHelper();
  final bloc = ItemBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
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

  StreamBuilder<List<Item>> getItemListView() {
    ThemeData localTheme = Theme.of(context);
    return StreamBuilder<List<Item>>(
      stream: bloc.items,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              Item item = snapshot.data[index];
              return GestureDetector(
                  key: Key(item.name),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                    title: _getNameAndPrice(context, item),
                    subtitle:
                        Text(item.nickName, style: localTheme.textTheme.body1),
                    onTap: () {
                      this._showItemInfoDialog(item);
                    },
                    onLongPress: () {
                      navigateToDetail(item, 'Edit Item');
                    },
                  ),
                  onHorizontalDragEnd: (DragEndDetails details) {
                    this._initiateTransaction("Sales Entry", item);
                  });
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
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
                      Text(item.nickName,
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
                          WindowUtils.getCard("Cost Price"),
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

  void navigateToDetail(Item item, String name) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ItemEntryForm(title: name, item: item, forEdit: true);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void _initiateTransaction(String formName, item) async {
    Map formMap = {
      'Sales Entry': SalesEntryForm(swipeData: item, title: formName),
      'Stock Entry': StockEntryForm(title: formName)
    };

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => formMap[formName]));
  }

  void updateListView() {
    setState(() {
      this.bloc.getItems();
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
