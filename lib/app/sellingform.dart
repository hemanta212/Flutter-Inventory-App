import 'package:flutter/material.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';

class SellingForm extends StatefulWidget {
  String title;
  SellingForm({this.title});

  @override
  State<StatefulWidget> createState() => _SellingFormState();

}

class _SellingFormState extends State<SellingForm>{

  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;

  List<String> _forms = ['Sales form', 'Stock entry form', 'Item entry Form'];
  String _currentFormSelected = '';

/*
  Map _stringToForm = {
    'entryForm': Forms.genItemEntryForm,
  };
*/

  var getForm;

  @override
  void initState() {
    super.initState();
    _currentFormSelected = _forms[0];
    // getForm = salesForm;
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  var displayResult = '';

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    Form buildForm(){
      return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
            children: <Widget>[

              DropdownButton<String>(
                items: _forms.map( (String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    ); // DropdownMenuItem
                }).toList(),

                onChanged: (String newValueSelected){
                  _dropDownItemSelected(newValueSelected);
                }, //onChanged

                value: _currentFormSelected,
              ), // DropdownButton


              // Item name
              Padding(
                padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
                child: TextFormField(
                  style: textStyle,
                  controller: itemNameController,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Please enter name of item you sold";
                    }
                  },
                  decoration: InputDecoration(
                    labelText:"Item name",
                    labelStyle: textStyle,
                    hintText:"Name of item you sold",
                    errorStyle: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 15.0
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ), // Textfield
              ),

              // No of items
              Padding(
                padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
                child: Row(
                 children: <Widget> [

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: textStyle,
                        controller: itemNumberController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter pieces of items you sold";
                          }
                        },
                        decoration: InputDecoration(
                          labelText:"No of items",
                          labelStyle: textStyle,
                          errorStyle: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 15.0
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                          )
                        ),
                      ), // Textfield
                    )
                  ), // Expanded 1

                  Container(width: _minimumPadding* 5),
                ] // Row widget list
              ), // Row
            ), // Padding Row

              // Selling price
              Padding(
                padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
                child: Row(
                 children: <Widget> [

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: textStyle,
                        controller: sellingPriceController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter total selling price";
                          }
                        },
                        decoration: InputDecoration(
                          labelText:"Total Selling price",
                          labelStyle: textStyle,
                          errorStyle: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 15.0
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                          )
                        ),
                      ), // Textfield
                    )
                  ), // Expanded 1
                ] // Row widget list
              ), // Row
            ), // Padding Row

            Padding(
              padding: EdgeInsets.only(bottom: _minimumPadding, top:_minimumPadding),
              child: Row(
                children: <Widget>[

                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text("Save", textScaleFactor: 1.5),
                      onPressed: () {
                        /*
                        setState( () {
                          if (_formKey.currentState.validate()) {
                            this.displayResult = _calculateTotalReturns();
                          }
                        });
                        */
                        debugPrint("Save button clicked");
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

    return CustomScaffold.setScaffold(context, widget.title, buildForm);
  }

  void _dropDownItemSelected(String newValueSelected) {
    setState( () {
        this._currentFormSelected = newValueSelected;
        //this.getForm = this._stringToForm[newValueSelected];
    }); // setState
  }

}
