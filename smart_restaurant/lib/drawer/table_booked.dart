import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';
import 'package:smart_restaurant/utils/qr_code.dart';

class TableBooked extends StatefulWidget {
  final bool isIOS;
  final User user;
  final Function callbackUser;
  final TableBooking tableBooking;
  TableBooked({this.isIOS, this.user, this.callbackUser, this.tableBooking});
  @override
  _TableBookedState createState() =>
      _TableBookedState(user, callbackUser, tableBooking);
}

class _TableBookedState extends State<TableBooked> {
  bool internetAccess = false;

  User user;
  Function callbackUser;
  TableBooking tableBooking;
  bool showQRCode = false;

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
    getInternetAccessObject();
    super.initState();
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
          InkWell(
            onTap: () {
              setState(() {
                showQRCode = !showQRCode;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 5.0,
                ),
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
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
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
                      )
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
          !showQRCode
              ? Container(
                  child: Text("Click on ticket to see QR Code"),
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
                      child: Text("Please show this QR Code at our restaurant"),
                    ),
                  ],
                )
              : Container(),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        // Box decoration takes a gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.3, 0.9],
          colors: [
            Colors.white,
            Colors.cyan[100],
          ],
        ),
      ),
      child: _showTableBooked(),
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
