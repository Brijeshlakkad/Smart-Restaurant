import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';
import 'package:smart_restaurant/utils/qr_code.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/delete_confirmation.dart';
import 'package:smart_restaurant/utils/check_platform.dart';
import 'package:smart_restaurant/table_book/book_table.dart';
import 'dart:ui';

class TableBooked extends StatefulWidget {
  final bool isIOS;
  final User user;
  final Function callbackUser;
  final TableBooking tableBooking;
  final callbackCheckTable;
  TableBooked(
      {this.isIOS,
      this.user,
      this.callbackUser,
      this.tableBooking,
      this.callbackCheckTable});
  @override
  _TableBookedState createState() =>
      _TableBookedState(user, callbackUser, tableBooking);
}

class _TableBookedState extends State<TableBooked>
    implements TableActionContract {
  bool _isLoading = false;
  bool internetAccess = false;
  ShowDialog _showDialog;
  CheckPlatform _checkPlatform;
  DeleteConfirmation _deleteConfirmation;

  User user;
  Function callbackUser;
  TableBooking tableBooking;
  bool showQRCode = false;

  TableActionPresenter _tableActionPresenter;
  _TableBookedState(
      User user, Function callbackUser, TableBooking tableBooking) {
    this.user = user;
    this.callbackUser = callbackUser;
    this.tableBooking = tableBooking;
  }
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    _deleteConfirmation = new DeleteConfirmation();
    _checkPlatform = new CheckPlatform(context: context);
    _tableActionPresenter = new TableActionPresenter(this);
    getInternetAccessObject();
    super.initState();
  }

  @override
  void onSuccess(String message) async {
    _showDialog.showDialogCustom(context, "Success", message);
    await Future.delayed(
      Duration(
        seconds: 3,
      ),
    );
    widget.callbackCheckTable(false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => BookTable(
              user: this.user,
            ),
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
    setState(() {
      _isLoading = false;
    });
  }

  void callbackThis(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _showTableBooked() {
      return ListView(
        children: [
          Container(
            padding: EdgeInsets.all(5.0),
            child: Card(
              elevation: 30.0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    showQRCode = !showQRCode;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: new AssetImage("assets/images/booked.png"),
                        alignment: AlignmentGeometry.lerp(
                            Alignment(1, 1), Alignment(1, 1), 2.0)),
                  ),
                  constraints: BoxConstraints(maxHeight: 250.0),
                  padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: QrImage(
                                    data: tableBooking.tableName.toString(),
                                    size: 80.0,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "${this.tableBooking.tableName}",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "${this.tableBooking.date}",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          "(24hr Format)",
                                          style: TextStyle(fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                bool perm =
                                    await _deleteConfirmation.showConfirmDialog(
                                        context, _checkPlatform.isIOS());
                                if (perm) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await _tableActionPresenter
                                      .doRemoveBookedTable(user, tableBooking);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(
                                  "${this.tableBooking.day.toUpperCase()}",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 19.0,
                                  ),
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "${this.tableBooking.slotName}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4.0,
                                    ),
                                    Text(
                                      "(24hr Format)",
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
//            SizedBox(
//              height: 20.0,
//            ),
//            Row(
//              children: <Widget>[
//                Image.asset(
//                  "assets/images/booked.png",
//                  height: 100,
//                ),
//              ],
//            )
                    ],
                  ),
                ),
              ),
            ),
          ),
          !showQRCode
              ? Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Click on ticket to see QR Code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            height: 25.0,
          ),
          showQRCode
              ? Column(
                  children: [
                    Container(
                      child: QrImage(
                        data: tableBooking.tableName.toString(),
                        size: MediaQuery.of(context).size.width * 0.55,
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      child: Text(
                        "Please show this QR Code at our restaurant",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      );
    }

    return new Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
            image: new ExactAssetImage('assets/images/food/bg.jpg'),
            fit: BoxFit.cover),
      ),
      child: _isLoading ? ShowProgress() : _showTableBooked(),
    );
  }
}

//return new Container(
//decoration: new BoxDecoration(
//image: new DecorationImage(
//image: new ExactAssetImage('assets/images/table.jpeg'),
//fit: BoxFit.cover,
//),
//),
//child: new BackdropFilter(
//filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//child: Container(
//padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
//child: _showTableBooked(),
//),
//),
//);
