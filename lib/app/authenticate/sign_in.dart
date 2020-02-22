import 'package:bk_app/services/auth.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/utils/window.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
              title: Text('Sign in'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Register'),
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

                    // No of items
                    WindowUtils.genTextField(
                      labelText: "Email",
                      hintText: "example@gmail.com",
                      textStyle: textStyle,
                      controller: this.userEmailController,
                      onChanged: (val) {
                        setState(() => this.userEmailController.text = val);
                      },
                    ),

                    // No of items
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

                    SizedBox(height: 20.0),
                    RaisedButton(
                        color: Colors.pink[400],
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            String email = this.userEmailController.text;
                            String password = this.userPasswordController.text;
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error =
                                    'Could not sign in with those credentials';
                              });
                            }
                          }
                        }),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

