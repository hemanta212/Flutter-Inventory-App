import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesOverview {
  static Map salesTransactionInfo;
  static Map overViewMap;
  static TextStyle nameStyle;

  static void showTransactions(context, infoMap) async {
    nameStyle = Theme.of(context).textTheme.subhead;
    salesTransactionInfo = infoMap;
    overViewMap = infoMap;
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
            children: <Widget>[getTransactionOverview(overViewMap)],
          );
        });
  }

  static Widget getTransactionOverview(overViewMap) {
    return Column(
      children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                columnSpacing: 1.0,
                columns: getDataColumns(overViewMap),
                rows: getDataRows(overViewMap))),
        displayProfit(),
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
            DataCell(Container(
                width: 100, child: Text("${value[i]}", softWrap: true)))
          ]);
        } else {
          rowCells[i].add(DataCell(Text("${value[i]}", style: nameStyle)));
        }
      }
      order += 1;
    });

    rowCells.forEach((row) {
      dataRows.add(DataRow(cells: row));
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

  static Widget displayProfit() {
    return Row(
      children: <Widget>[
        getCard("Profit"),
        getCard("${calculateProfit()}"),
      ],
    );
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
    return profits.reduce((first, second) {
      return first + second;
    });
  }

  static Widget getCard(String label) {
    return Expanded(
        child: Card(
            elevation: 5.0,
            child: Center(
              heightFactor: 2,
              child: Text(label),
            )));
  }
}
