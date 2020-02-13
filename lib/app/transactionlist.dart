import 'package:flutter/material.dart';

import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';
import 'package:bk_app/app/transactionoverview.dart';
import 'package:bk_app/app/testi.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/blocs/database_bloc.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionListState();
  }
}

class TransactionListState extends State<TransactionList> {
  DbHelper databaseHelper = DbHelper();
  final bloc = TransactionBloc();
  Map itemMapCache;
  Map itemTransactionMapCache;

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeItemMapCache();
    _initializeItemTransactionMapCache();
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
        child: Icon(Icons.add),
      ),
    );
  }

  StreamBuilder<List<ItemTransaction>> getTransactionListView() {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;

    return StreamBuilder<List<ItemTransaction>>(
      stream: bloc.transactions,
      builder: (BuildContext context,
          AsyncSnapshot<List<ItemTransaction>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              ItemTransaction transaction = snapshot.data[index];
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                    title: Text(this.getDescription(transaction),
                        style: nameStyle),
                    subtitle: Text(transaction.date ?? ''),
                    onTap: () {
                      navigateToDetail(transaction, 'Edit Item');
                    },
                  ));
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void navigateToDetail(ItemTransaction transaction, String name) async {
    var form;
    if (transaction.type == 0) {
      form =
          SalesEntryForm(title: name, transaction: transaction, forEdit: true);
    } else {
      form =
          StockEntryForm(title: name, transaction: transaction, forEdit: true);
    }

    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return form;
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    setState(() {
      this.bloc.getTransactions();
    });
  }

  void _initializeItemMapCache() {
    Future<Map> futureItemMap = StartupCache().itemMap;
    futureItemMap.then((map) {
      debugPrint("Transaction list: item map reloaded $map");
      this.itemMapCache = map;
    });
  }

  void _initializeItemTransactionMapCache() {
    Future<Map> futureItemTransactionMap = StartupCache().itemTransactionMap;
    futureItemTransactionMap.then((map) {
      debugPrint("Transaction list: item transaction map reloaded $map");
      this.itemTransactionMapCache = map;
    });
  }

  String getDescription(ItemTransaction transaction) {
    if (this.itemMapCache == null) {
      _initializeItemMapCache();
      debugPrint("item cache still null");
      return transaction.description;
    }

    Map map = this.itemMapCache;
    List infoList = map[transaction.itemId];
    String action = transaction.type.isOdd ? "Bought" : "Sold";
    String itemName = infoList?.first ?? 'N/A';
    String itemNo = FormUtils.fmtToIntIfPossible(transaction.items);
    String amount = FormUtils.fmtToIntIfPossible(transaction.amount);
    transaction.description = "$action: $itemNo $itemName \nAmount: $amount";
    return transaction.description; //transaction.description;
  }

  void _showTransactionProfit() async {
    Map itemTransactionMap = await StartupCache().itemTransactionMap;
    Map soldTransactions = Map();
    itemTransactionMap.forEach((transactionId, value) {
      if (value['type'] == 0) soldTransactions[transactionId] = value;
    });
    List<String> names = List();
    List<int> items = List();
    List<double> costPrices = List();
    List<double> sellingPrices = List();
    List<double> profits = List();
    List<String> dates = List();

    Map overViewMap = Map();

    try {
      soldTransactions.forEach((key, value) {
        int itemId = value['itemId'];
        String name;
        try {
          name = this.itemMapCache[itemId][0];
        } catch (e) {
          // name = 'N/A';
          return;
        }
        int noOfItems = value['items'].toInt();
        double costPrice = this._getShortDouble(value['costPrice']);
        double sellingPrice = this._getShortDouble(value['amount']);
        String date = this._simplifyDateString(value['date']);
        double rawProfit = noOfItems * sellingPrice - noOfItems * costPrice;
        double profit = this._getShortDouble(rawProfit);

        names.add(name);
        items.add(noOfItems);
        costPrices.add(costPrice);
        sellingPrices.add(sellingPrice);
        dates.add(date);
        profits.add(profit);
      });

      overViewMap = {
        'Name': names,
        'Item': items,
        'CP': costPrices,
        'SP': sellingPrices,
        'Profit': profits,
        'Date': dates
      };
      debugPrint("sending overview map $overViewMap");
      /*
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TransactionOverview(overViewMap);
      }));
      */
    } catch (e) {
      debugPrint("Profita calc error $e");
    }
    PopDialog.genDialog(context, overViewMap);
  }

  String _simplifyDateString(String date) {
    DateTime value = DateFormat().parseLoose(date);
    String newValue = DateFormat.jm().format(value);
    return newValue;
  }

  double _getShortDouble(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
