import 'package:flutter/material.dart';

class ItemForm extends StatefulWidget {
  String title;

  ItemForm({this.title});

  @override
  State<StatefulWidget> createState() => _ItemForm();

}

class _ItemForm extends State<ItemForm>{

  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;

  @override
  void initState() {
    super.initState();
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemIdController = TextEditingController();
  TextEditingController wholeSellerNameController = TextEditingController();

  var displayResult = '';

  @override
  Widget build(BuildContext context){

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
              genTextField(labelText: "Item name", hintText: "Name of item you sold", textStyle: textStyle, controller: itemNameController),

              // Nick name
              genTextField(labelText: "Nick name (id)", textStyle: textStyle, controller: itemIdController),

              // Wholeseller name: They are separate entity of their own with properties like name, number, location, etc
              genTextField(labelText: "Wholeseller name", textStyle: textStyle, controller: wholeSellerNameController),

              // TODO
              /* Provide user to define Big unit terms like  
              1 box = 15 items
              1 cartoon = 5 box
              */

            // save
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

  Widget genTextField({String labelText, String hintText, TextStyle textStyle, TextEditingController controller, TextInputType keyboardType = TextInputType.text} ) {
    return Padding(
      padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
      child: TextFormField(
        keyboardType: keyboardType,
        style: textStyle,
        controller: controller,
        validator: (String value) {
          if (value.isEmpty) {
            return "Please enter $labelText";
          }
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: textStyle,
          hintText: hintText,
          errorStyle: TextStyle(
            color: Colors.yellowAccent,
            fontSize: 15.0
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
          )
        ),
      ), // Textfield
    );
  } // genTextField function

}
