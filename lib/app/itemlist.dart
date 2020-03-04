import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/app/forms/itemEntryForm.dart';
import 'package:bk_app/app/forms/salesEntryForm.dart';
import 'package:bk_app/app/forms/stockEntryForm.dart';
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
  Stream<List<Item>> items;
  static List<Item> _itemsList;
  List<Item> itemsList = List<Item>();
  static UserData userData;
  bool showSearchBar = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    if (userData != null) {
      crudHelper = CrudHelper(userData: userData);
      _updateListView();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("I am calu");
    if (userData == null) {
      return Wrapper();
    }
    return Scaffold(
      appBar: this.showSearchBar
          ? null
          : AppBar(
              title: Text("Items"),
              actions: <Widget>[
                IconButton(
                  tooltip: "Search",
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.showSearchBar = true;
                    });
                  },
                ),
              ],
            ),
      drawer: CustomScaffold.setDrawer(context),
      body: this.showSearchBar ? getSearchView() : getItemListView(),
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
                      subtitle: Text(item.nickName ?? '',
                          style: localTheme.textTheme.body1),
                      onTap: () {
                        this._showItemInfoDialog(item);
                      },
                      onLongPress: () {
                        navigateToDetail(item, 'Edit Item');
                      },
                    ),
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity < 0.0) {
                        this._initiateTransaction("Stock Entry", item);
                      } else if (details.primaryVelocity > 0.0) {
                        this._initiateTransaction("Sales Entry", item);
                      }
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
                      Visibility(
                          visible: userData.checkStock ?? true,
                          child: Row(
                            children: <Widget>[
                              WindowUtils.getCard("Total Stocks"),
                              WindowUtils.getCard(FormUtils.fmtToIntIfPossible(
                                  item.totalStock)),
                            ],
                          )),
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
      this._updateListView();
    }
  }

  void _initiateTransaction(String formName, item) async {
    String itemName = item.name;
    Map formMap = {
      'Sales Entry': SalesEntryForm(swipeData: item, title: "Sell $itemName"),
      'Stock Entry': StockEntryForm(swipeData: item, title: "Buy $itemName")
    };

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => formMap[formName]));
  }

  void _updateListView() async {
    _itemsList = await crudHelper.getItems();
    setState(() {
      this.items = crudHelper.getItemStream();
      this.itemsList = _itemsList;
    });
  }

  static Widget _getNameAndPrice(BuildContext context, Item item) {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;
    String name = item.name;
    String markedPrice = item.markedPrice ?? '';
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

  void _modifyItemList(String val) async {
    List<Map> itemsMapList =
        _itemsList.map((Item item) => item.toMap()).toList();
    List<Map> _suggestions =
        FormUtils.genFuzzySuggestionsForItem(val, itemsMapList);
    this.itemsList = _suggestions.map((Map itemMap) {
      return Item.fromMapObject(itemMap);
    }).toList();
  }

  Widget getSearchView({type}) {
    print("search view && ${this.itemsList}");
    ThemeData localTheme = Theme.of(context);
    return Container(
        child: Column(children: <Widget>[
      SizedBox(height: 30.0),
      Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: Row(children: <Widget>[
            Expanded(
                child: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _modifyItemList(value);
                });
              },
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            )),
            IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  setState(() => this.showSearchBar = false);
                }),
          ])),
      Expanded(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: this.itemsList.length,
              itemBuilder: (BuildContext context, int index) {
                Item item = this.itemsList[index];
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
                        navigateToDetail(item, 'Edit Item');
                      },
                    ),
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity < 0.0) {
                        this._initiateTransaction("Stock Entry", item);
                      } else if (details.primaryVelocity > 0.0) {
                        this._initiateTransaction("Sales Entry", item);
                      }
                    });
              }))
    ]));
  }
}
