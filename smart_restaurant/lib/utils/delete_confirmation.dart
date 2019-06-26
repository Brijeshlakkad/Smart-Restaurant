import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DeleteConfirmation {
  Future<bool> showConfirmDialog(BuildContext context, bool isIOS,
      {title = "Are you sure?"}) async {
    bool status = false;
    isIOS
        ? await showDialog<String>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('$title'),
                  actions: <Widget>[
                    new CupertinoDialogAction(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                        status = false;
                      },
                    ),
                    new CupertinoDialogAction(
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        status = true;
                      },
                    ),
                  ],
                ),
          )
        : await showDialog<String>(
            context: context,
            builder: (BuildContext context) => new AlertDialog(
                  contentPadding: const EdgeInsets.all(16.0),
                  content: new Container(
                    child: Text('$title'),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                          status = false;
                        }),
                    new FlatButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                        status = true;
                      },
                    )
                  ],
                ),
          );
    return status;
  }
}
