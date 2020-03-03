import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/app/forms/salesEntryForm.dart';
import 'package:bk_app/app/forms/stockEntryForm.dart';
import 'package:bk_app/app/transactions/salesOverview.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/models/user.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/utils/utils.dart';
import 'package:bk_app/services/crud.dart';

class TransactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionListState();
  }
}

class TransactionListState extends State<TransactionList> {
  static CrudHelper crudHelper;
  Map itemMapCache = Map();
  Stream<List<ItemTransaction>> transactions;
  List<ItemTransaction> pendingTransactions;
  bool loading = true;
  static UserData userData;
  Map currentMonthHistory = Map();

  @override
  void initState() {
    _initializeItemMapCache();
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
    if (userData == null) {
      return Wrapper();
    }
    List<Tab> viewTabs = <Tab>[
      Tab(text: "History"),
      Tab(text: "Pending"),
    ];
    return DefaultTabController(
        length: viewTabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transactions"),
            bottom: TabBar(tabs: viewTabs),
          ),
          drawer: CustomScaffold.setDrawer(context),
          body: TabBarView(children: <Widget>[
            getTransactionListView(),
            showPendingTransactions(),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              this._showTransactionProfit();
            },
            tooltip: 'Caclulate Profit',
            child: Icon(Icons.book),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: buildBottomAppBar(context),
        ));
  }

  static BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.card_travel),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Transactions', caller: 'Transactions')),
          SizedBox(width: 20.0),
          IconButton(
              icon: Icon(Icons.access_alarm),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Due Transactions', caller: 'Transactions')),
          SizedBox(width: 150.0),
          IconButton(
              icon: Icon(Icons.history),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Month History', caller: 'Transactions'))
        ],
      ),
    );
  }

  StreamBuilder getTransactionListView() {
    return StreamBuilder(
      stream: this.transactions,
      builder: (context, snapshot) {
        if (snapshot.hasData && !loading) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              ItemTransaction transaction = snapshot.data[index];
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        Text("Amount"),
                        Text(
                            "Rs. ${FormUtils.fmtToIntIfPossible(transaction.amount)}"),
                      ],
                    ),
                    title:
                        getDescription(context, transaction, this.itemMapCache),
                    onTap: () {
                      navigateToDetail(context, transaction, 'Edit Item',
                          updateListView: this._updateListView);
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

  Widget showPendingTransactions() {
    if (this.pendingTransactions != null) {
      return ListView.builder(
        itemCount: this.pendingTransactions.length,
        itemBuilder: (BuildContext context, int index) {
          ItemTransaction transaction = this.pendingTransactions[index];
          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Text("Amount"),
                    Text("Rs. ${transaction.amount}"),
                  ],
                ),
                title: getDescription(context, transaction, this.itemMapCache),
                subtitle: Text(transaction.signature),
                onTap: () {
                  navigateToDetail(context, transaction, 'Edit Item',
                      updateListView: this._updateListView);
                },
              ));
        },
      );
    } else {
      return Loading();
    }
  }

  void _showTransactionProfit() async {
    Map itemTransactionMap = await AppUtils.getTransactionsForToday(context);
    Map salesTransactions = Map();

    // transactions of type = 0 means outgoing(sales)
    //1 means incoming(stockentry)
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

  static Widget getDescription(
      BuildContext context, ItemTransaction transaction, Map cache) {
    ThemeData localTheme = Theme.of(context);
    String itemName = getItemName(transaction, cache: cache);
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
            Text("$action: $itemNo units\n$itemName",
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

  static void navigateToDetail(
      BuildContext context, ItemTransaction transaction, String name,
      {updateListView}) async {
    var form;
    if (transaction.type == 0) {
      form =
          SalesEntryForm(title: name, transaction: transaction, forEdit: true);
    } else {
      form = StockEntryForm(
        title: name,
        transaction: transaction,
        forEdit: true,
      );
    }

    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return form;
    }));

    if (result == true) {
      updateListView();
    }
  }

  void _updateListView() async {
    List<ItemTransaction> pendingTransactions =
        await crudHelper.getPendingTransactions();
    setState(() {
      this.transactions = crudHelper.getItemTransactionStream();
      this.pendingTransactions = pendingTransactions.reversed.toList();
    });
  }

  void _initializeItemMapCache() async {
    this.itemMapCache = await StartupCache().itemMap;
    setState(() {
      this.loading = false;
    });
  }

  static String getItemName(ItemTransaction transaction, {cache}) {
    if (cache.isEmpty) {
      debugPrint("item cache still empty");
      return 'N/A';
    }

    Map map = cache;
    List infoList = map[transaction.itemId];
    String itemName = infoList?.first ?? 'N/A';
    return itemName;
  }
}
