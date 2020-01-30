import 'package:flutter/material.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/app/forms.dart';
import 'package:bk_app/models/item.dart';

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

  List<String> _forms = ['Sales form', 'Stock entry form', 'Item entry form'];
  var displayResult = '';

  String _currentFormSelected = '';

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  Form Function() getForm;

  @override
  void initState() {
    super.initState();
    _currentFormSelected = _forms[0];
  }


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    if (getForm == null){
      var FormClass = new SalesForm(context, Item(''));
      getForm = FormClass.genForm;
    }

    Widget buildBody() {
      return ListView(
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

          this.getForm(),
        ]
      );
    }

    return CustomScaffold.setScaffold(context, widget.title, buildBody);
  }

  void _dropDownItemSelected(String newValueSelected) {

    Map _stringToForm = {
      'Item entry form': ItemForm.empty(context),
      'Stock entry form': ItemEntryForm.empty(context),
      'Sales form': SalesForm.empty(context),
    };

    setState( () {
        this.getForm = _stringToForm[newValueSelected].genForm;
        this._currentFormSelected = newValueSelected;
    }); // setState
  }

}
