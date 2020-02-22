class Item {
  String _name;
  String _nickName;
  String _description;
  double _costPrice;
  double _markedPrice;
  double _totalStock = 0.0;
  String _lastStockEntry;
  int _used = 0;

  Item(
    this._name, [
    this._nickName,
    this._costPrice,
    this._markedPrice,
    this._description,
    // NOTE : various item custom units
  ]);

  String get name => _name;

  String get nickName => _nickName;

  String get lastStockEntry => _lastStockEntry;

  /*
  double get costPrice {
    print("Cost price stocks ${this._costPriceStocks}");
    Map avgCostPriceStocks = _getAvgCostPrice(this._costPriceStocks);
    return avgCostPriceStocks.keys.first;
  }
  */
  double get costPrice => _costPrice;

  String get description => _description;

  double get markedPrice => _markedPrice;

  double get totalStock => _totalStock;

  int get used => _used;

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

  /*
  set costPriceStocks(Map newCostPriceStocksMap) {
    if (this._costPriceStocks == null) this._costPriceStocks = Map();
    if (this._costPriceStocks.length >= 2) {
      Map avgCostPriceMap = _getAvgCostPrice(this._costPriceStocks);
      avgCostPriceMap.addAll(newCostPriceStocksMap);
      this._costPriceStocks = avgCostPriceMap;
    } else {
      this._costPriceStocks.addAll(newCostPriceStocksMap);
      print(
          "$newCostPriceStocksMap item costPriceStocks ${this._costPriceStocks}");
    }
  }
  */
  set costPrice(double newCostPrice) {
    this._costPrice = newCostPrice;
  }

  set markedPrice(double newMarkedPrice) {
    this._markedPrice = newMarkedPrice;
  }

  set totalStock(double newTotalStock) {
    this._totalStock = newTotalStock;
  }

  void increaseStock(double addedStock) {
    this._totalStock += addedStock;
  }

  void decreaseStock(double soldStock) {
    this._totalStock -= soldStock;
  }

  /*
  Map _getAvgCostPrice(Map costPrices) {
    // Basically takes a Map of costPrice and stocks and condense
    // them by calculating a single costPrie that represents all
    // suppose we buy 10 items 'A' in 100 and 5 'B' in 200.
    // We have two CP's but SP is always one at a time here we will
    // sell in 250 here profit becomes 15 * 250 - (10 * 100 + 5 * 200)
    // Can we get a combined cp that gives the same profit?
    // Just get avg. Avg cp = (100 * 10 + 200 * 5 ) / (10 + 5 )

    if (costPrices.isEmpty) return {0.0: 0.0};
    Map avgCostPrice = Map();
    double priceSum = 0.0;
    double totalItems = 0.0;
    costPrices.forEach((price, stocks) {
      totalItems += stocks;
      priceSum += price * stocks;
    });
    double avgPrice = priceSum / totalItems;
    avgCostPrice[avgPrice] = totalItems;
    return avgCostPrice;
  }

  void modifyLatestStockEntry(String field, double value) {
    double currentStock = this._costPriceStocks.values.last;
    double currentPrice = this._costPriceStocks.keys.last;
    if (field == 'price') {
      double newPrice = value;
      this._costPriceStocks.remove(currentPrice);
      this._costPriceStocks[newPrice] = currentStock;
    } else if (field == 'stock') {
      currentStock += value;
      this._costPriceStocks[currentPrice] = currentStock;
    }
  }
  */

  // Convert a note obj to map obj
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['name'] = _name;
    map['nick_name'] = _nickName;
    map['description'] = _description;
    map['cost_price'] = _costPrice;
    map['marked_price'] = _markedPrice;
    map['total_stock'] = _totalStock;
    map['last_stock_entry'] = _lastStockEntry;
    map['used'] = _used;
    return map;
  }

  // Extract item obj from map obj
  Item.fromMapObject(Map<String, dynamic> map) {
    this._description = map['description'];
    this._name = map['name'];
    this._nickName = map['nick_name'];
    this._costPrice = map['cost_price'];
    this._markedPrice = map['marked_price'];
    this._totalStock = map['total_stock'];
    this._lastStockEntry = map['last_stock_entry'];
    this._used = map['used'];
  }
}
