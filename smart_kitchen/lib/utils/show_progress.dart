import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_kitchen/utils/check_platform.dart';
class ShowProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CheckPlatform checkPlatform= new CheckPlatform(context: context);
    return checkPlatform.isIOS()
        ? Container(
            child: Center(
              child: CupertinoActivityIndicator(
                radius: 15.0,
              ),
            ),
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
