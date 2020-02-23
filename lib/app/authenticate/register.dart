import 'package:bk_app/services/auth.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/utils/window.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text('Sign up'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Sign In'),
                  onPressed: () => widget.toggleView(),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    WindowUtils.genTextField(
                      labelText: "Email",
                      hintText: "example@gmail.com",
                      textStyle: textStyle,
                      controller: this.userEmailController,
                      onChanged: (val) {
                        setState(() => this.userEmailController.text = val);
                      },
                    ),
                    WindowUtils.genTextField(
                      labelText: "Password",
                      textStyle: textStyle,
                      controller: this.userPasswordController,
                      obscureText: true,
                      validator: (val, labelText) => val.length < 6
                          ? 'Enter a $labelText 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => this.userPasswordController.text = val);
                      },
                    ),
                    RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            String email = this.userEmailController.text;
                            String password = this.userPasswordController.text;
                            dynamic result =
                                await _auth.register(email, password);
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error = 'Please supply a valid email';
                              });
                            }
                          }
                        }),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
