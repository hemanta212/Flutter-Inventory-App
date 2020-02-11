import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionOverview extends StatefulWidget {
  final Map salesTransactionInfo;

  TransactionOverview(this.salesTransactionInfo);

  @override
  State<StatefulWidget> createState() {
    return TransactionOverviewState(this.salesTransactionInfo);
  }
}

class TransactionOverviewState extends State<TransactionOverview> {
  Map salesTransactionInfo;
  Map overViewMap;
  TransactionOverviewState(this.salesTransactionInfo);

  TextStyle nameStyle;

  @override
  void initState() {
    super.initState();
    overViewMap = this.salesTransactionInfo;
    overViewMap.removeWhere((key, value) {
      if (!['Name', 'Profit', 'Item'].contains(key)) {
        return true;
      } else {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    this.nameStyle = Theme.of(context).textTheme.subhead;
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction Overview"),
      ),
      body: getTransactionOverview(),
    );
  }

  Widget getTransactionOverview() {
    return ListView(
      children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                columnSpacing: 15.0,
                columns: getDataColumns(),
                rows: getDataRows())),
        this._displayProfit(),
      ],
    );
  }

  List<DataRow> getDataRows() {
    List<DataRow> dataRows = List();
    List rowCells = List();
    int rowLength;
    int order = 0;

    this.overViewMap.forEach((key, value) {
      rowLength = value.length;
      for (int i = 0; i < rowLength; i++) {
        if (order == 0) {
          rowCells.add([
            DataCell(Container(
                width: 150, child: Text("${value[i]}", softWrap: true)))
          ]);
        } else {
          rowCells[i].add(DataCell(Text("${value[i]}", style: this.nameStyle)));
        }
      }
      order += 1;
    });

    rowCells.forEach((row) {
      dataRows.add(DataRow(cells: row));
    });

    return dataRows; //_sortDataRows(dataRows);
  }

  List<DataColumn> getDataColumns() {
    List<DataColumn> dataCols = List();
    this.overViewMap.forEach((key, value) {
      dataCols.add(DataColumn(label: Text(key)));
    });
    return dataCols;
  }

  Widget _displayProfit() {
    return Row(
      children: <Widget>[
        this._getCard("Profit"),
        this._getCard("${this._calculateProfit()}"),
      ],
    );
  }

  List<DataRow> _sortDataRows(List<DataRow> dataRows) {
    dataRows.sort((DataRow first, DataRow second) {
      DateTime firstDate = _getDateTimeFromDataRow(first);
      DateTime secondDate = _getDateTimeFromDataRow(second);
      return firstDate.compareTo(secondDate);
    });
    return dataRows;
  }

  DateTime _getDateTimeFromDataRow(DataRow row) {
    String rawDate = row.cells.last.child.toString();
    String strDate = rawDate.split("\"")[1];
    DateTime date = DateFormat.jm().parseLoose(strDate);
    return date;
  }

  double _calculateProfit() {
    List<double> profits = this.salesTransactionInfo['Profit'];
    return profits.reduce((first, second) {
      return first + second;
    });
  }

  Widget _getCard(String label) {
    return Expanded(
        child: Card(
            elevation: 5.0,
            child: Center(
              heightFactor: 2,
              child: Text(label),
            )));
  }
}
