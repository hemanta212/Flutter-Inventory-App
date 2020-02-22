import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/models/user.dart';
import 'package:bk_app/app/authenticate/authenticate.dart';
import 'package:bk_app/app/salesentryform.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // return either the Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return SalesEntryForm(title: "Sales Entry");
    }
  }
}
