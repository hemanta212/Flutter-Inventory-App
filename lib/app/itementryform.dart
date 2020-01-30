import 'package:flutter/material.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/models/item.dart';

class ItemEntryForm extends StatefulWidget {
  String title;
  final Item item;

  ItemEntryForm({this.item, this.title});

  @override
  State<StatefulWidget> createState(){
    return _ItemEntryForm(this.item, this.title);
  }
}


class _ItemEntryForm extends State<ItemEntryForm>{

  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;

  DbHelper databaseHelper = DbHelper();

  String title;
  Item item;

  String displayString = '';

  _ItemEntryForm(this.item, this.title);

  @override
  void initState() {
    super.initState();
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController costPriceController = TextEditingController();
  TextEditingController markedPriceController = TextEditingController();

  @override
  Widget build(BuildContext context){

    TextStyle textStyle = Theme.of(context).textTheme.title;

    // Fill values in text field for updating.
    if (item != null){
      debugPrint("text refill called");
      itemNameController.text = item.name;
      itemNumberController.text = '${item.totalStock}';
      costPriceController.text = '${item.costPrice}';
      markedPriceController.text = '${item.markedPrice}';
    }

    Widget buildForm() {
      return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
            children: <Widget>[

              // Item name
              WindowUtils.genTextField(
                labelText: "Item name",
                hintText: "Name of item you sold",
                textStyle: textStyle,
                controller: itemNameController,
                onChanged: updateItemName,
              ),

              // No of items
              WindowUtils.genTextField(
                labelText: "No of items",
                textStyle: textStyle,
                controller: itemNumberController,
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
                controller: costPriceController,
                keyboardType: TextInputType.number,
                onChanged: updateCostPrice,
              ),

              // Marked price
              WindowUtils.genTextField(
                labelText: "Expected selling price",
                textStyle: textStyle,
                controller: markedPriceController,
                keyboardType: TextInputType.number,
                onChanged: updateMarkedPrice,
              ),

            // save
            Padding(
              padding: EdgeInsets.only(bottom: _minimumPadding, top:_minimumPadding),
              child: Row(
                children: <Widget>[

                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text("Save", textScaleFactor: 1.5),
                      onPressed: () {
                        setState( () {
                          debugPrint("Save button clicked");
                          if (_formKey.currentState.validate()) {
                            _save();
                          }
                        });
                      }
                    ) // RaisedButton Calculate
                  ), //Expanded

                ]

              ) // Row 2 Submit and reset buttons
            ), // Padding

            ] // Column widget list
          ) //Column
        ) // Padding
      ); // Container
  }

  return CustomScaffold.setScaffold(context, this.title, buildForm);
}

  void onSave() {
    setState( () {
      debugPrint("Save button clicked");
      if (_formKey.currentState.validate()) {
        debugPrint("validated");
        _save();
      }
    });
  }

  void updateItemName() {
    var name = itemNameController.text;
    Future<Item> itemFuture = databaseHelper.getItem(name);
    itemFuture.then( (newItem) {
      item = newItem;
      if (item == null){
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
    var a = item.id;
    debugPrint('ITem id $a');
    item.costPrice = double.parse(costPriceController.text);
  }

  void updateMarkedPrice(){
    item.markedPrice = double.parse(markedPriceController.text);
  }


  // Save data to database
  void _save() async {
    if (item == null){
      WindowUtils.showAlertDialog(context, "Status:", "Item not registered");
      return;
    }
    // Update the cost price
    double itemNumber = double.parse(itemNumberController.text);
    item.addStock(itemNumber);

    int result;
    if (item.id != null) {
      // Case 1: Update operation
      debugPrint("Updated item");
      result = await databaseHelper.updateItem(item);
    } else {
      // Case 2: Insert operation
      result = await databaseHelper.insertItem(item);
    }

    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(context, 'Status', 'Stock updated successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(context, 'Status', 'Problem updating stock, try again!');
    }
  }

  // Delete item data
  void _delete() async {
    WindowUtils.moveToLastScreen(context);
    if (item.id == null) {
      // Case 1: Abandon new item creation
      WindowUtils.showAlertDialog(context, 'Status', 'Item not created');
      return;
    }

    // Case 2: Delete item from database
    int result = await databaseHelper.deleteItem(item.id);


    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(context, 'Status', 'Item deleted successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(context, 'Status', 'Problem deleting item, try again!');
    }
  }

}

