import 'package:flutter/material.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/colors.dart';

class GetLogOut extends StatefulWidget {
  @override
  GetLogOutState createState() {
    return new GetLogOutState();
  }
}

class GetLogOutState extends State<GetLogOut> implements LogoutScreenContract {
  LogoutScreenPresenter _presenter;
  GetLogOutState() {
    _presenter = new LogoutScreenPresenter(this);
  }
  getLogOut() async {
    _presenter.doLogout(context);
  }
  @override
  void onLogoutError(String errorTxt) {}

  @override
  void onLogoutSuccess() async {}
  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
//          decoration: BoxDecoration(
//            border: Border(
//              top: BorderSide(width: 1.0, color: lErrorRed),
//              left: BorderSide(width: 1.0, color: lErrorRed),
//              right: BorderSide(width: 1.0, color: lErrorRed),
//              bottom: BorderSide(width: 1.0, color: lErrorRed),
//            ),
//          ),
          child: RaisedButton(
            color: lBlue300,
            onPressed: getLogOut,
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

abstract class LogoutScreenContract {
  void onLogoutSuccess();
  void onLogoutError(String error);
}

class LogoutScreenPresenter {
  LogoutScreenContract _view;
  // RestDatasource api = new RestDatasource();
  LogoutScreenPresenter(this._view);

  doLogout(BuildContext context) async {
    try {
      var db = new DatabaseHelper();
      await db.deleteUsers();
      print("logout");
      Navigator.pushNamed(context, "/");
      //var user = await api.logout(email, password);
      _view.onLogoutSuccess();
    } on Exception catch (error) {
      _view.onLogoutError(error.toString());
    }
  }
}
