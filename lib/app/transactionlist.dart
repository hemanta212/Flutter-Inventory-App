import 'package:bk_app/services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';
import 'package:bk_app/app/salesOverview.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/utils/loading.dart';

class TransactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionListState();
  }
}

class TransactionListState extends State<TransactionList> {
  CrudHelper crudHelper = CrudHelper();
  Map itemMapCache = Map();
  Stream<QuerySnapshot> transactions;
  bool loading = true;

  @override
  void initState() {
    this._updateListView();
    _initializeItemMapCache();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
      ),
      drawer: CustomScaffold.setDrawer(context),
      body: getTransactionListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this._showTransactionProfit();
        },
        tooltip: 'Caclulate Profit',
        child: Icon(Icons.book),
      ),
    );
  }

  StreamBuilder getTransactionListView() {
    return StreamBuilder(
      stream: this.transactions,
      builder: (context, snapshot) {
        if (snapshot.hasData && !loading) {
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot itemTransactionSnapshot =
                  snapshot.data.documents[index];
              ItemTransaction transaction =
                  ItemTransaction.fromMapObject(itemTransactionSnapshot.data);
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                    title: this._getDescription(context, transaction),
                    subtitle: Text(
                      "Amount: Rs. " +
                          FormUtils.fmtToIntIfPossible(transaction.amount),
                    ),
                    onTap: () {
                      String transactionId = itemTransactionSnapshot.documentID;
                      _navigateToDetail(transaction, 'Edit Item',
                          transactionId: transactionId);
                    },
                  ));
            },
          );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget _getDescription(BuildContext context, ItemTransaction transaction) {
    ThemeData localTheme = Theme.of(context);
    String itemName = this._getItemName(transaction);
    String action = transaction.type.isOdd ? "Bought" : "Sold";
    String itemNo = FormUtils.fmtToIntIfPossible(transaction.items);

    DateTime transactionDate =
        DateFormat.yMMMd().add_jms().parse(transaction.date);
    String dayYear = DateFormat.yMMMd().format(transactionDate);
    String time = DateFormat.jm().format(transactionDate);

    return Row(children: <Widget>[
      Expanded(
          flex: 1,
          child: Column(children: <Widget>[
            Text("$action: $itemNo $itemName",
                style: localTheme.textTheme.subhead),
          ])),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10.0, width: 1.0),
          Text(dayYear,
              style: localTheme.textTheme.body1.copyWith(fontSize: 10.0)),
          Text(time, style: localTheme.textTheme.body2),
        ],
      ),
    ]);
  }

  void _navigateToDetail(ItemTransaction transaction, String name,
      {String transactionId}) async {
    var form;
    if (transaction.type == 0) {
      form = SalesEntryForm(
          title: name,
          transaction: transaction,
          forEdit: true,
          transactionId: transactionId);
    } else {
      form = StockEntryForm(
          title: name,
          transaction: transaction,
          forEdit: true,
          transactionId: transactionId);
    }

    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return form;
    }));

    if (result == true) {
      this._updateListView();
    }
  }

  void _updateListView() {
    setState(() {
      this.transactions = crudHelper.getItemTransactions();
    });
  }

  void _initializeItemMapCache() async {
    this.itemMapCache = await StartupCache().itemMap;
    this.loading = false;
  }

  String _getItemName(ItemTransaction transaction) {
    if (this.itemMapCache.isEmpty) {
      debugPrint("item cache still empty");
      return 'N/A';
    }

    Map map = this.itemMapCache;
    List infoList = map[transaction.itemId];
    String itemName = infoList?.first ?? 'N/A';
    return itemName;
  }

  void _showTransactionProfit() async {
    Map itemTransactionMap = await StartupCache().itemTransactionMap;
    Map salesTransactions = Map();

    // transactions of type = 0 means outgoing(sales) and 1 means incoming(stockentry)
    itemTransactionMap.forEach((transactionId, value) {
      debugPrint("got value $value");
      if (value['type'] == 0) {
        salesTransactions[transactionId] = value;
      }
    });

    if (salesTransactions.isEmpty) {
      WindowUtils.showAlertDialog(
          context, "Failed!", "Sales history is empty!");
      return;
    }

    List<String> names = List();
    List<int> items = List();
    List<double> costPrices = List();
    List<double> sellingPrices = List();
    List<double> profits = List();
    List<double> dueAmounts = List();
    List<String> dates = List();

    Map overViewMap = Map();

    try {
      salesTransactions.forEach((key, value) {
        String itemId = value['itemId'];
        String name;
        try {
          name = this.itemMapCache[itemId][0];
        } catch (e) {
          return;
        }
        int noOfItems = value['items'].toInt();
        double costPrice = FormUtils.getShortDouble(value['costPrice']);
        double dueAmount = FormUtils.getShortDouble(value['dueAmount'] ?? 0.0);
        double sellingPrice = FormUtils.getShortDouble(value['amount']);
        String date = value['date'];
        double _profit = noOfItems * sellingPrice - noOfItems * costPrice;
        double profit = FormUtils.getShortDouble(_profit);

        names.add(name);
        items.add(noOfItems);
        costPrices.add(costPrice);
        sellingPrices.add(sellingPrice);
        dates.add(date);
        profits.add(profit);
        dueAmounts.add(dueAmount);
      });

      overViewMap = {
        'Name': names,
        'Item': items,
        'CP': costPrices,
        'SP': sellingPrices,
        'Profit': profits,
        'DueAmount': dueAmounts,
        'Date': dates
      };
      debugPrint("sending overview map $overViewMap");
    } catch (e) {
      debugPrint("Profita calc error $e");
    }
    SalesOverview.showTransactions(context, overViewMap);
  }
}
