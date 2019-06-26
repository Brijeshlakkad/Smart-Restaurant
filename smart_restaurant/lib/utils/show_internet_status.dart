import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ShowInternetStatus {
  Widget showInternetStatus(isIOS) {
    return isIOS
        ? new SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: 1,
            ),
            delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Container(
                child: Center(
                  child: Text("Please check your internet connection"),
                ),
              );
            }, childCount: 1),
          )
        : new GridView.count(
            crossAxisCount: 1,
            // Generate 100 Widgets that display their index in the List
            children: List.generate(
              1,
              (index) {
                return Container(
                  child: Center(
                    child: Text("Please check your internet connection"),
                  ),
                );
              },
            ),
          );
  }
}
