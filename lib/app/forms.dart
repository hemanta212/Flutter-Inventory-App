import 'package:flutter/material.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/models/item.dart';


class ItemEntryForm{
  BuildContext context;
  Item item;

  var _formKey = GlobalKey<FormState>();
  DbHelper databaseHelper = DbHelper();

  ItemEntryForm(this.context, this.item);

  ItemEntryForm.empty(BuildContext context) {
    this.context = context;
    this.item = Item('');
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController costPriceController = TextEditingController();
  TextEditingController markedPriceController = TextEditingController();

  String displayString = '';

  Form genForm(){
    TextStyle textStyle = Theme.of(context).textTheme.title;
    final double _minimumPadding = 5.0;

    return Form(
      key: this._formKey,
      child: Padding(
        padding: EdgeInsets.all(_minimumPadding * 2),
        child: Column(
          children: <Widget>[
            // Item name
            WindowUtils.genTextField(
              labelText: "Item name",
              hintText: "Name of item you sold",
              textStyle: textStyle,
              controller: this.itemNameController,
              onChanged: this.updateItemName,
            ),

            // No of items
            WindowUtils.genTextField(
              labelText: "No of items",
              textStyle: textStyle,
              controller: this.itemNumberController,
              keyboardType: TextInputType.number,
              onChanged: () {},
            ),

            // TODO
            /* Provide user to register using  Big unit terms like
            1 box = 15 items
            1 cartoon = 5 box
            */

            // Cost price
            WindowUtils.genTextField(
              labelText: "Total cost price",
              textStyle: textStyle,
              controller: this.costPriceController,
              keyboardType: TextInputType.number,
              onChanged: this.updateCostPrice,
            ),

            // Marked price
            WindowUtils.genTextField(
              labelText: "Expected selling price",
              textStyle: textStyle,
              controller: this.markedPriceController,
              keyboardType: TextInputType.number,
              onChanged: this.updateMarkedPrice,
            ),

          // save
          Padding(
            padding: EdgeInsets.only(
              bottom: _minimumPadding,
              top:_minimumPadding
            ),

            child: Row(
              children: <Widget>[
                WindowUtils.genButton(
                  this.context, "Save", this.checkAndSave
                ),
                WindowUtils.genButton(
                  this.context, "Delete", this._delete
                )
              ]
            ) // Row

           ), // Paddin
         ]
        ) //List view
      ) // Padding
    ); // Container
  }

  void updateItemName() {
    var name = this.itemNameController.text;
    Future<Item> itemFuture = this.databaseHelper.getItem(name);
    itemFuture.then( (newItem) {
        this.item = newItem;
        if (this.item == null){
          this.displayString = "Unregistered item";
          debugPrint('Unregistered Got item as $name');
        }else {
          this.displayString = "";
          debugPrint('Registered Got item as $name');
        }
      },
      onError: (e){
        debugPrint('UpdateitemName Error::  $e');
    });
  }

  void updateCostPrice(){
    var a = this.item.id;
    debugPrint('ITem id $a');
    this.item.costPrice = double.parse(this.costPriceController.text);
  }

  void updateMarkedPrice(){
    this.item.markedPrice = double.parse(this.markedPriceController.text);
  }

  void checkAndSave() {
    debugPrint("Save button clicked");
    if (this._formKey.currentState.validate()) {
      debugPrint("validated");
      this._save();
    }
  }

  // Save data to database
  void _save() async {
    if (this.item == null){
      WindowUtils.showAlertDialog(this.context, "Status:", "Item not registered");
      return;
    }
    // Update the cost price
    double itemNumber = double.parse(this.itemNumberController.text);
    this.item.addStock(itemNumber);

    int result;
    if (this.item.id != null) {
      // Case 1: Update operation
      debugPrint("Updated item");
      result = await this.databaseHelper.updateItem(item);
    } else {
      // Case 2: Insert operation
      result = await this.databaseHelper.insertItem(item);
    }

    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(this.context, 'Status', 'Stock updated successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(this.context, 'Status', 'Problem updating stock, try again!');
    }
  }

  // Delete item data
  void _delete() async {
    if (this.item.id == null) {
      // Case 1: Abandon new item creation
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item not created');
      return;
    }

    // Case 2: Delete item from database
    int result = await this.databaseHelper.deleteItem(this.item.id);


    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item deleted successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(this.context, 'Status', 'Problem deleting item, try again!');
    }
  }
}



class ItemForm{
  BuildContext context;
  Item item;

  var _formKey = GlobalKey<FormState>();
  DbHelper databaseHelper = DbHelper();

  ItemForm(this.context, this.item);

  ItemForm.empty(BuildContext context) {
    this.context = context;
    this.item = Item('');
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNickNameController = TextEditingController();

  String displayString = '';

  Form genForm(){
    TextStyle textStyle = Theme.of(context).textTheme.title;
    final double _minimumPadding = 5.0;

    itemNameController.text = item.name;
    itemNickNameController.text = item.nickName;

    return Form(
        key: this._formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: Column(
            children: <Widget>[

              // Item name
              WindowUtils.genTextField(
                labelText: "Item name",
                hintText: "Name of item you sold",
                textStyle: textStyle,
                controller: this.itemNameController,
                onChanged: this.updateItemName
              ),

              // Nick name
              WindowUtils.genTextField(
                labelText: "Nick name (id)",
                textStyle: textStyle,
                controller: this.itemNickNameController,
                onChanged: this.updateItemNickName
              ),

              // TODO
              /* Provide user to define Big unit terms like  
              1 box = 15 items
              1 cartoon = 5 box
              */

              // save
              Padding(
                padding: EdgeInsets.only(
                  bottom: _minimumPadding,
                  top:_minimumPadding
                ),

                child: Row(
                  children: <Widget>[
                    WindowUtils.genButton(this.context, "Save", this.checkAndSave),
                    WindowUtils.genButton(this.context, "Delete", this._delete)
                  ]
                ) // Row

              ), // Padding

            ] // Column widget list
          ) //List view
        ) // Padding
      ); // form
   }

  // Update the title of the Item obj
  void updateItemName() {
    this.item.name = this.itemNameController.text;
  }

  // Update the description of the Item obj
  void updateItemNickName() {
    this.item.nickName = this.itemNickNameController.text;
  }

  void checkAndSave() {
    debugPrint("Save button clicked");
    if (this._formKey.currentState.validate()) {
      debugPrint("validated");
      this._save();
    }
  }


  // Save data to database
  void _save() async {
    // item.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (this.item.id != null) {
      // Case 1: Update operation
      debugPrint("Updated item");
      result = await this.databaseHelper.updateItem(this.item);
    } else {
      // Case 2: Insert operation
      result = await this.databaseHelper.insertItem(this.item);
    }

    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item saved successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(this.context, 'Status', 'Problem saving item, try again!');
    }
  }

  // Delete item data
  void _delete() async {
    if (this.item.id == null) {
      // Case 1: Abandon new item creation
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item not created');
      return;
    }

    // Case 2: Delete item from database
    int result = await this.databaseHelper.deleteItem(this.item.id);


    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item deleted successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(this.context, 'Status', 'Problem deleting item, try again!');
    }
  }
}


class SalesForm{
  BuildContext context;
  Item item;

  var _formKey = GlobalKey<FormState>();
  DbHelper databaseHelper = DbHelper();

  SalesForm(this.context, this.item);

  SalesForm.empty(BuildContext context) {
    this.context = context;
    this.item = Item('');
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  String displayString = '';

  Form genForm(){
    TextStyle textStyle = Theme.of(context).textTheme.title;
    final double _minimumPadding = 5.0;

    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: Column(
            children: <Widget>[

              // Item name
              WindowUtils.genTextField(
                labelText: "Item name",
                hintText: "Name of item you sold",
                textStyle: textStyle,
                controller: this.itemNameController,
                onChanged: this.updateItemName
              ),

              // No of items
              WindowUtils.genTextField(
                labelText: "No of items",
                textStyle: textStyle,
                controller: this.itemNumberController,
                keyboardType: TextInputType.number,
                onChanged: () {}
              ),

              // Selling price
              WindowUtils.genTextField(
                labelText: "Selling price",
                textStyle: textStyle,
                controller: this.sellingPriceController,
                keyboardType: TextInputType.number,
                onChanged: this.updateSellingPrice,
              ),

              // save
              Padding(
                padding: EdgeInsets.only(
                  bottom: _minimumPadding,
                  top:_minimumPadding
                ),

                child: Row(
                  children: <Widget>[
                    WindowUtils.genButton(this.context, "Save", this.checkAndSave),
                    WindowUtils.genButton(this.context, "Delete", this._delete)
                  ]
                ) // Row

              ), // Paddin
            ]
          ) //List view
        ) // Padding
      ); // return

  }

  void updateItemName() {
    var name = this.itemNameController.text;
    Future<Item> itemFuture = this.databaseHelper.getItem(name);
    itemFuture.then( (newItem) {
        this.item = newItem;
        if (this.item == null){
          this.displayString = "Unregistered item";
          debugPrint('Unregistered Got item as $name');
        }else {
          this.displayString = "";
          debugPrint('Registered Got item as $name');
        }
      },
      onError: (e){
        debugPrint('UpdateitemName Error::  $e');
    });
  }

  void updateSellingPrice(){
    debugPrint("selling price updated");
    //this.item.Price = double.parse(this.markedPriceController.text);
  }

  void checkAndSave() {
    debugPrint("Save button clicked");
    if (this._formKey.currentState.validate()) {
      debugPrint("validated");
    }
  }

  void _delete(){
    debugPrint('delete pressed');
  }

 

}
