import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/cache.dart';

class SalesOverview {
  static Map salesTransactionInfo;
  static Map overViewMap;
  static TextStyle nameStyle;
  static BuildContext context;

  static void showTransactions(appContext, infoMap) async {
    context = appContext;
    nameStyle = Theme.of(context).textTheme.subhead;
    salesTransactionInfo = infoMap;
    debugPrint("sales transaction info recieved $infoMap");
    overViewMap = Map()..addAll(salesTransactionInfo);
    overViewMap.removeWhere((key, value) {
      if (!['Name', 'Profit', 'Item'].contains(key)) {
        return true;
      } else {
        return false;
      }
    });

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            children: <Widget>[getTransactionOverview(overViewMap)],
          );
        });
  }

  static Widget getTransactionOverview(Map overViewMap) {
    return Column(
      children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                columnSpacing: 1.0,
                columns: getDataColumns(overViewMap),
                rows: getDataRows(overViewMap))),
        displayProfitAndDueAmount(),
      ],
    );
  }

  static List<DataRow> getDataRows(overViewMap) {
    List<DataRow> dataRows = List();
    List rowCells = List();
    int rowLength;
    int order = 0;

    overViewMap.forEach((key, value) {
      rowLength = value.length;
      for (int i = 0; i < rowLength; i++) {
        if (order == 0) {
          rowCells.add([
            DataCell(
              Container(width: 100, child: Text("${value[i]}")),
              onTap: () => _showTransactionInfoDialog(i),
            )
          ]);
        } else {
          rowCells[i].add(DataCell(Text("${value[i]}", style: nameStyle),
              onTap: () => _showTransactionInfoDialog(i)));
        }
      }
      order += 1;
    });

    rowCells.forEach((row) {
      dataRows.add(DataRow(
        cells: row,
      ));
    });
    return dataRows; //_sortDataRows(dataRows);
  }

  static List<DataColumn> getDataColumns(overViewMap) {
    List<DataColumn> dataCols = List();
    overViewMap.forEach((key, value) {
      dataCols.add(DataColumn(label: Text(key)));
    });
    return dataCols;
  }

  static Widget displayProfitAndDueAmount() {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          WindowUtils.getCard("Profit", color: Theme.of(context).cardColor),
          WindowUtils.getCard("${calculateProfit()}",
              color: Theme.of(context).cardColor),
        ],
      ),
      Visibility(
          visible: isEmptyDouble(calculateDueAmount()) ? false : true,
          child: Row(
            children: <Widget>[
              WindowUtils.getCard("Due Amount",
                  color: Theme.of(context).cardColor),
              WindowUtils.getCard("${calculateDueAmount()}",
                  color: Theme.of(context).cardColor),
            ],
          )),
    ]);
  }

  static List<DataRow> sortDataRows(List<DataRow> dataRows) {
    dataRows.sort((DataRow first, DataRow second) {
      DateTime firstDate = getDateTimeFromDataRow(first);
      DateTime secondDate = getDateTimeFromDataRow(second);
      return firstDate.compareTo(secondDate);
    });
    return dataRows;
  }

  static DateTime getDateTimeFromDataRow(DataRow row) {
    String rawDate = row.cells.last.child.toString();
    String strDate = rawDate.split("\"")[1];
    DateTime date = DateFormat.jm().parseLoose(strDate);
    return date;
  }

  static double calculateProfit() {
    List<double> profits = salesTransactionInfo['Profit'];
    double total = profits.reduce((first, second) {
      return first + second;
    });
    return FormUtils.getShortDouble(total);
  }

  static double calculateDueAmount() {
    List<double> dueAmounts = salesTransactionInfo['DueAmount'];
    debugPrint("dudueAmounts $dueAmounts");
    double total = dueAmounts.reduce((first, second) {
      return first + second;
    });
    return FormUtils.getShortDouble(total);
  }

  static bool isEmptyDouble(double value) {
    if (value == 0.0) {
      return true;
    } else {
      return false;
    }
  }

  static void _showTransactionInfoDialog(int index) async {
    ThemeData itemInfoTheme = Theme.of(context);
    List<String> dates = salesTransactionInfo['Date'];
    String transactionDate = dates[index];
    Map transaction;
    Map itemTransactionMapCache = await StartupCache().itemTransactionMap;
    itemTransactionMapCache.forEach((key, value) {
      if (transactionDate == value['date']) {
        transaction = value;
      }
      debugPrint("got transaction $transaction");
    });

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text("${transaction['date']}",
                          style: itemInfoTheme.textTheme.subhead),
                      SizedBox(height: 16.0),
                      Row(
                        children: <Widget>[
                          WindowUtils.getCard("Cost Price"),
                          WindowUtils.getCard(FormUtils.fmtToIntIfPossible(
                              FormUtils.getShortDouble(
                                  transaction['costPrice']))),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          WindowUtils.getCard("Selling Price"),
                          WindowUtils.getCard(FormUtils.fmtToIntIfPossible(
                              FormUtils.getShortDouble(transaction['amount']))),
                        ],
                      ),
                      Visibility(
                          visible: transaction['dueAmount'] == 0.0 ||
                                  transaction['dueAmount'] == null
                              ? false
                              : true,
                          child: Row(
                            children: <Widget>[
                              WindowUtils.getCard("Due Amount"),
                              WindowUtils.getCard(FormUtils.fmtToIntIfPossible(
                                  FormUtils.getShortDouble(
                                      transaction['dueAmount'] ?? 0.0))),
                            ],
                          )),
                      SizedBox(height: 16.0),
                      Text("${transaction['description'] ?? ''}",
                          style: itemInfoTheme.textTheme.subhead),
                    ]),
              ),
            ],
          );
        });
  }
}
