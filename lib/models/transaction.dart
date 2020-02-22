class ItemTransaction {
  int _type;
  double _amount;
  double _costPrice;
  double _dueAmount;
  String _itemId;
  double _items;
  String _date;
  String _description;
  int _createdAt;

  ItemTransaction(
      this._type, this._itemId, this._amount, this._items, this._date,
      [this._description, this._costPrice]);

  String get itemId => _itemId;

  int get type => _type;

  int get createdAt => _createdAt;

  double get amount => _amount;

  double get costPrice => _costPrice;

  double get dueAmount => _dueAmount;

  String get date => _date;

  double get items => _items;

  String get description => _description;

  set itemId(String newItemId) {
    this._itemId = newItemId;
  }

  set type(int newType) {
    this._type = newType;
  }

  set createdAt(int newCreatedAt) {
    this._createdAt = newCreatedAt;
  }

  set description(String newDesc) {
    this._description = newDesc;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set amount(double newAmount) {
    this._amount = newAmount;
  }

  set costPrice(double newCostPrice) {
    this._costPrice = newCostPrice;
  }

  set dueAmount(double newDueAmount) {
    this._dueAmount = newDueAmount;
  }

  set items(double newItems) {
    this._items = newItems;
  }

  // Convert a note obj to map obj
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['item_id'] = _itemId;
    map['type'] = _type;
    map['description'] = _description;
    map['due_amount'] = _dueAmount;
    map['date'] = _date;
    map['amount'] = _amount;
    map['items'] = _items;
    map['cost_price'] = _costPrice;
    map['created_at'] = _createdAt;
    return map;
  }

  // Extract item obj from map obj
  ItemTransaction.fromMapObject(Map<String, dynamic> map) {
    this._type = map['type'];
    this._description = map['description'];
    this._dueAmount = map['due_amount'];
    this._itemId = map['item_id'];
    this._date = map['date'];
    this._amount = map['amount'];
    this._costPrice = map['cost_price'];
    this._items = map['items'];
    this._createdAt = map['created_at'];
  }
}
