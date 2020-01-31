import 'package:bk_app/models/item.dart';


class ItemTransaction{

  int _id;
  int _itemId;
  int _type;
  double _amount;
  double _items;
  String _date;
  String _description;

  ItemTransaction(
    this._type,
    this._itemId,
    this._amount,
    this._items,
    this._date,
    [this._description]
  );

  ItemTransaction.withId(
    this._id,
    this._type,
    this._itemId,
    this._amount,
    this._items,
    this._date,
    [this._description]
  );

  int get id => _id;

  int get itemId => _itemId;

  int get type => _type;

  double get amount => _amount;

  String get description => _description;

  String get date => _date;

  double get items => _items;


  set itemId(int newItemId) {
      this._itemId = newItemId;
    }

  set itemType(int newType) {
    this._type = newType;
  }


  set description(String newDesc) {
    this._description = newDesc;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set amount(double newCostPrice) {
    this._amount = newCostPrice;
  }

  set items(double newItems) {
    this._items = newItems;
  }

  /*
  Item getItem() async {
    Item item = await databaseHelper.getItemFromId(this.itemId);
    return item;
  }

  Item updateItems(double newStock){
     Item item = self.getItem();
     double origStock = item.totalStock;

     if (this._type == 0){
       newStock = origStock + this.items - newStock;
     }else {
       newStock = origStock - this.items + newStock;
     }

     item.totalStock = newStock;
     return item;
  }
    */


  // Convert a note obj to map obj
  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();

    if (id != null){
      map['id'] = _id;
    }

    map['item_id'] = _itemId;
    map['type'] = _type;
    map['description'] = _description;
    map['date'] = _date;
    map['amount'] = _amount;
    map['items'] = _items;
    return map;
  }

  // Extract item obj from map obj
  ItemTransaction.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._type = map['type'];
    this._description = map['description'];
    this._itemId = map['item_id'];
    this._date = map['date'];
    this._amount = map['cost_price'];
    this._items = map['items'];
  }

}
