import 'package:flutter/material.dart';

class CheckPlatform {
  final BuildContext context;
  const CheckPlatform({this.context});
  isIOS() {
    return Theme.of(context).platform == TargetPlatform.iOS ? true : false;
  }
}
