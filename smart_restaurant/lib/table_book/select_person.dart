import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/show_internet_status.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/home_page.dart';
import 'package:smart_restaurant/table_book/select_table.dart';
import 'dart:async';
import "package:path/path.dart" show dirname;
import 'dart:io' show Platform;

class SelectPerson extends StatefulWidget {
  final bool isIOS;
  final User user;
  SelectPerson({this.isIOS, this.user});
  @override
  _SelectPersonState createState() => _SelectPersonState(user);
}

class _SelectPersonState extends State<SelectPerson>
    implements TableBookContract {
  bool _isLoading = true;
  bool _isLoadingValue = false;
  bool internetAccess = false;
  ShowDialog _showDialog;
  ShowInternetStatus _showInternetStatus;

  User user;
  TableBooking tableBooking;
  bool checkingTable;
  DatabaseHelper db = new DatabaseHelper();

  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  String _personNum;
  List personNumList = ['1', '2', '3', '4', '5', '6'];
  TableBookPresenter _tableBookPresenter;

  _SelectPersonState(user) {
    this.user = user;
  }

  Function callbackUser(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
    db.updateUser(user);
  }

  @override
  void initState() {
    checkingTable = false;
    _showDialog = new ShowDialog();
    _tableBookPresenter = new TableBookPresenter(this);
    getTableBooked();
    checkTableBooked();
    _showInternetStatus = new ShowInternetStatus();
    super.initState();
  }

  @override
  void onGetBookedTableSuccess(TableBooking tableBooking) async {
    if (tableBooking != null) {
      this.tableBooking = tableBooking;
      this.checkingTable = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(
                user: this.user,
                callbackUser: this.callbackUser,
                tableBooking: this.tableBooking,
              ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void onBookTableSuccess(Map res) async {}

  @override
  void onBookTableError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
    setState(() {
      _isLoadingValue = false;
    });
  }

  void checkTableBooked() {
    new Timer.periodic(Duration(seconds: 60), (Timer t) async {
      if (this.checkingTable == true) {
        print("checking");
        this.tableBooking =
            await _tableBookPresenter.api.getBookedTable(this.user);
        if (tableBooking == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SelectPerson(
                    isIOS: widget.isIOS,
                    user: this.user,
                  ),
            ),
          );
        }
      }
    });
    print(dirname(Platform.script.toString()));
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  Future getTableBooked() async {
    await getInternetAccessObject();
    if (internetAccess) {
      await _tableBookPresenter.doGetBookedTable(this.user);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget getSelectPersonButton(String num) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _personNum == num ? Colors.red : Colors.blue,
            width: 2.0,
          ),
        ),
        child: FlatButton(
          onPressed: () async {
            setState(() {
              _personNum = num;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SelectTable(
                      isIOS: widget.isIOS,
                      user: this.user,
                      personNum: this._personNum,
                    ),
              ),
            );
          },
          child: Text("$num"),
        ),
      ),
    );
  }

  Widget gettingDataProgress(String str) {
    return Row(
      children: <Widget>[
        Container(
          child: Text('$str'),
        ),
        SizedBox(
          width: 13.0,
        ),
        ShowProgress()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TableCell> getTableCells(List tableList, Function callFunction,
        int start, int end, int actualEnd) {
      List<TableCell> tableCells = new List<TableCell>();
      for (int i = start; i < end; i++) {
        tableCells.add(
          TableCell(
            child: callFunction(tableList[i]),
          ),
        );
      }
      for (int i = end; i < actualEnd; i++) {
        tableCells.add(
          TableCell(
            child: Container(),
          ),
        );
      }
      return tableCells;
    }

    List<TableRow> getTableRows(List tableList, Function callFunction) {
      List<TableRow> tableRows = new List<TableRow>();
      int length = tableList.length;
      int i = 0;
      int j = 0;
      int k = 0;
      while (length != 0) {
        i = j;
        if (length > 4) {
          j += 4;
          length -= 4;
          k = j;
        } else {
          k = j + 4;
          j += length;
          length = 0;
        }
        tableRows.add(
          TableRow(
            children: getTableCells(tableList, callFunction, i, j, k),
          ),
        );
      }
      return tableRows;
    }

    Widget getTable(tableList, callFunction) {
      return Table(children: getTableRows(tableList, callFunction));
    }

    Widget _selectTableBody() {
      return Container(
        padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            getTable(personNumList, getSelectPersonButton),
            SizedBox(
              height: 14,
            ),
          ],
        ),
      );
    }

    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: new Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text("Select Person"),
        ),
        body: _isLoading
            ? ShowProgress()
            : internetAccess
                ? _selectTableBody()
                : widget.isIOS
                    ? new CustomScrollView(
                        slivers: <Widget>[
                          new CupertinoSliverRefreshControl(
                            onRefresh: getInternetAccessObject,
                          ),
                          new SliverSafeArea(
                              top: false,
                              sliver: _showInternetStatus
                                  .showInternetStatus(widget.isIOS)),
                        ],
                      )
                    : RefreshIndicator(
                        key: refreshIndicatorKey,
                        child: _showInternetStatus
                            .showInternetStatus(widget.isIOS),
                        onRefresh: getInternetAccessObject,
                      ),
      ),
    );
  }
}
