class Item {
  int _id;
  String _name;
  String _nickName = '';
  String _description;
  double _costPrice;
  double _markedPrice;
  double _totalStock = 0.0;

  Item(this._name,
      [this._nickName, this._costPrice, this._markedPrice, this._description
      // NOTE : various item custom units
      ]);

  Item.withId(this._id, this._name,
      [this._nickName, this._costPrice, this._markedPrice, this._description]);

  int get id => _id;

  String get name => _name;

  String get nickName => _nickName;

  double get costPrice => _costPrice;

  String get description => _description;

  double get markedPrice => _markedPrice;

  double get totalStock => _totalStock;

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

  set costPrice(double newCostPrice) {
    //if (this._costPricesMap['$newCostPrice'].isFinite ?? false) {}
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

  // Convert a note obj to map obj
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = _id;
    }

    map['name'] = _name;
    map['nick_name'] = _nickName;
    map['description'] = _description;
    map['cost_price'] = _costPrice;
    map['marked_price'] = _markedPrice;
    map['total_stock'] = _totalStock;
    return map;
  }

  // Extract item obj from map obj
  Item.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._description = map['description'];
    this._name = map['name'];
    this._nickName = map['nick_name'];
    this._costPrice = map['cost_price'];
    this._markedPrice = map['marked_price'];
    this._totalStock = map['total_stock'];
  }
}
