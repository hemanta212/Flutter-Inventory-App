import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String _id;
  String _name;
  String _nickName;
  String _description;
  double _costPrice;
  String _markedPrice;
  double _totalStock = 0.0;
  String _lastStockEntry;
  int _used = 0;
  Map _units;

  Item(
    this._name, [
    this._nickName,
    this._costPrice,
    this._markedPrice,
    this._description,
  ]);

  String get id => _id;

  String get name => _name;

  String get nickName => _nickName;

  String get lastStockEntry => _lastStockEntry;

  double get costPrice => _costPrice;

  String get description => _description;

  String get markedPrice => _markedPrice;

  double get totalStock => _totalStock;

  int get used => _used;
  Map get units => _units;

  set id(String newId) {
    this._id = newId;
  }

  set name(String newName) {
    if (newName.length <= 140) {
      this._name = newName;
    }
  }

  set nickName(String newNickName) {
    if (newNickName.length <= 40) {
      this._nickName = newNickName;
    }
  }

  set description(String newDesc) {
    this._description = newDesc;
  }

  set lastStockEntry(String newLastStockEntryId) {
    this._lastStockEntry = newLastStockEntryId;
  }

  set used(int newUsed) {
    this._used = newUsed;
  }

  set costPrice(double newCostPrice) {
    this._costPrice = newCostPrice;
  }

  set markedPrice(String newMarkedPrice) {
    this._markedPrice = newMarkedPrice;
  }

  set totalStock(double newTotalStock) {
    this._totalStock = newTotalStock;
  }

  set units(Map newUnits) {
    this._units = newUnits;
  }

  void increaseStock(double addedStock) {
    this._totalStock += addedStock;
  }

  void decreaseStock(double soldStock) {
    this._totalStock -= soldStock;
  }

  List<double> getNewCostPriceAndStock(
      double totalCostPriceOfTransaction, double noOfItemsInTransaction) {
    /// We average the two cp thus calculating a new equivalent cp

    /// Suppose we buy 10 items 'A' in 100 and 5 'B' in 200.
    /// We have two CP's but SP is always one at a time here we will
    /// sell in 250 here profit becomes 15 * 250 - (10 * 100 + 5 * 200)
    /// Can we get a combined cp that gives the same profit?
    /// Just get avg. Avg cp = (100 * 10 + 200 * 5 ) / (10 + 5 )

    // If new item just register first transaction as is.
    if (this._costPrice == null)
      return [
        totalCostPriceOfTransaction / noOfItemsInTransaction,
        noOfItemsInTransaction
      ];

    double currentCp = this._costPrice;
    double totalCurrentCpOfStocks = currentCp * this._totalStock;
    double totalCp = totalCurrentCpOfStocks + totalCostPriceOfTransaction;
    double totalItems = this._totalStock + noOfItemsInTransaction;
    double newCp = totalCp / totalItems;
    return [newCp, totalItems];
  }

  void modifyLatestStockEntry(transaction, double newNoOfItemsInTransaction,
      double newTotalCostPriceOfTransaction) {
    /// Retrieves and redo the current costPrice calculation
    /// So when 6 units costing $10 each and 4 units costing 20 each are
    /// Combined by above cp method, it gives combined CP of $14 for (6 + 4 = 10) units.
    /// When user comes later to say that he was mistaken and it was 5 units
    /// costing $25 each (not 4 & $20) then we have to recover the already done calculation
    /// and redo it. This function does it.
    /// It takes the faulty stock entry transaction ( 4 & $20), then from current total
    /// stock of 10 retrieves the old totalstock (6) and through equation 14 = (4*20 + 6*x) / (6+4)
    /// which was used to take out the avg CP($14), takes the unknown X (oldCp before faulty transaction)
    /// Now since we know old 6 and $10 and new correct 5 and $25 we can reapply the formula to get CP.

    // confirm the transaction type as incoming or stock entry (1)
    assert(transaction.type == 1);
    // Retrieve old cp and totalStock before faulty transaction
    double oldTransactionItems = transaction.items;
    double oldTransactionCostPrice = transaction.amount / oldTransactionItems;
    print(
        "Got old transaction cp $oldTransactionCostPrice and items $oldTransactionItems");
    double oldTotalStock = this._totalStock - oldTransactionItems;
    double oldTotalCostPrice = ((this._costPrice * this._totalStock) -
            (oldTransactionItems * oldTransactionCostPrice))
        .abs();

    print(
        "Got total costprice of old $oldTotalCostPrice & items $oldTotalStock");
    // Reapply to get new cp from new updated transaction info
    double totalCp = oldTotalCostPrice + newTotalCostPriceOfTransaction;
    double totalItems = oldTotalStock + newNoOfItemsInTransaction;
    double newCp = totalCp / totalItems;
    this._costPrice = newCp;
    this._totalStock = totalItems;
  }

  static List<Item> fromQuerySnapshot(QuerySnapshot snapshot) {
    List<Item> items = List<Item>();
    snapshot.documents.forEach((DocumentSnapshot doc) {
      Item item = Item.fromMapObject(doc.data);
      item.id = doc.documentID;
      items.add(item);
    });
    items.sort((a, b) {
      return b.used.compareTo(a.used);
    });
    return items;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['id'] = _id;
    map['name'] = _name;
    map['nick_name'] = _nickName;
    map['description'] = _description;
    map['cost_price'] = _costPrice;
    map['marked_price'] = _markedPrice;
    map['total_stock'] = _totalStock;
    map['last_stock_entry'] = _lastStockEntry;
    map['used'] = _used;
    map['units'] = _units;
    return map;
  }

  Item.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._description = map['description'];
    this._name = map['name'];
    this._nickName = map['nick_name'];
    this._costPrice = map['cost_price'];
    this._markedPrice = map['marked_price'];
    this._totalStock = map['total_stock'];
    this._lastStockEntry = map['last_stock_entry'];
    this._used = map['used'];
    this._units = map['units'];
  }
}
