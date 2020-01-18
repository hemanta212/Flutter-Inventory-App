import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  var displayResult = '';

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),// AppBar

      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
            children: <Widget>[

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
                      textColor: Theme.of(context).primaryColorDark,
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
      ) // Container
    );// Scaffold
  }

  /*
  void navigateTo({String title}) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ItemForm(title:title);
    }));

    /*if (result == true){
      updateListView();
    }
    */
  }
  */

}
