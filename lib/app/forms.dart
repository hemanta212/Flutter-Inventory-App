import 'package:flutter/material.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/models/item.dart';

class Forms{
  static TextEditingController itemNameController = TextEditingController();
  static TextEditingController itemNumberController = TextEditingController();
  static TextEditingController costPriceController = TextEditingController();
  static TextEditingController markedPriceController = TextEditingController();

  TextStyle textStyle = Theme.of(context).textTheme.title;
  final double _minimumPadding = 5.0;
  Item item;

  DbHelper databaseHelper = DbHelper();

  static Form genItemEntryForm(passedItem, BuildContext context, {onSave, onDelete}){
    var _formKey = GlobalKey<FormState>();
    item = passedItem;

    return Form(
      key: formKey,
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
            padding: EdgeInsets.only(
              bottom: _minimumPadding,
              top:_minimumPadding
            ),

            child: Row(
              children: <Widget>[
                WindowUtils.genButton(context, "Save", onSave),
                WindowUtils.genButton(context, "Delete", onDelete)
              ]
            ) // Row

           ), // Paddin
         ]
        ) //List view
      ) // Padding
    ); // Container
  }

  static void updateItemName() {
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

  static void updateCostPrice(){
    var a = item.id;
    debugPrint('ITem id $a');
    item.costPrice = double.parse(costPriceController.text);
  }

  static void updateMarkedPrice(){
    item.markedPrice = double.parse(markedPriceController.text);
  }

}
