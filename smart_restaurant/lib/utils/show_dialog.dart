import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ShowDialog {
  Future showDialogCustom(BuildContext context, String title, String content,
      {double fontSize = 18.0, double boxHeight=53.0}) async {
    Theme.of(context).platform == TargetPlatform.iOS
        ? await showDialog<String>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("$title"), content: Text("$content")),
          )
        : await showDialog<String>(
            context: context,
            builder: (BuildContext context) => new AlertDialog(
                  contentPadding: const EdgeInsets.all(16.0),
                  content: Container(
                    height: boxHeight,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "$title",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontSize),
                        ),
                        SizedBox(
                          height: 7.0,
                        ),
                        Text("$content",
                            style: TextStyle(fontSize: fontSize - 3)),
                      ],
                    ),
                  ),
                  actions: <Widget>[],
                ),
          );
  }
}
