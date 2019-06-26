import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_restaurant/utils/color_loader.dart';

class ShowProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ColorLoader(
        radius: 15.0,
        dotRadius: 6.0,
      ),
    );
  }
}
