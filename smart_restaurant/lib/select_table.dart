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
import 'dart:async';

class SelectTable extends StatefulWidget {
  final bool isIOS;
  final User user;
  SelectTable({this.isIOS, this.user});
  @override
  _SelectTableState createState() => _SelectTableState(user);
}

class _SelectTableState extends State<SelectTable>
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
  TableB _tableNum;
  TableB _slotTime;
  List personNumList = ['1', '2', '3', '4', '5', '6'];
  List<TableB> tableList = new List<TableB>();
  List<TableB> slotList = new List<TableB>();
  bool _isLoadingTableList = false;
  bool _isLoadingSlotList = false;
  TableBookPresenter _tableBookPresenter;

  _SelectTableState(user) {
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

  void checkTableBooked() {
    new Timer.periodic(Duration(seconds: 120), (Timer t) async {
      if (this.checkingTable == true) {
        print("checking");
        this.tableBooking =
            await _tableBookPresenter.api.getBookedTable(this.user);
        if (tableBooking == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SelectTable(
                    isIOS: widget.isIOS,
                    user: this.user,
                  ),
            ),
          );
        }
      }
    });
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
              tableBooking: this.tableBooking),
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
  void onBookTableSuccess(Map res) async {
    _showDialog.showDialogCustom(context, "Success", res['responseMessage']);
    this.tableBooking = res['tableBooking'];
    this.checkingTable = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(
            user: this.user,
            callbackUser: this.callbackUser,
            tableBooking: this.tableBooking),
      ),
    );
    setState(() {
      _isLoadingValue = false;
    });
  }

  @override
  void onBookTableError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
    setState(() {
      _isLoadingValue = false;
    });
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
      await _tableBookPresenter.doGetTableBooked(this.user);
    }
  }

  Future getTableList(String personNum) async {
    await getInternetAccessObject();
    if (internetAccess) {
      List<TableB> tableList =
          await _tableBookPresenter.api.getTableList(this.user, personNum);
      if (tableList != null) {
        this.tableList = tableList.toList();
      } else {
        this.tableList = new List<TableB>();
      }
    }
    setState(() {
      _isLoadingTableList = false;
    });
  }

  Future getSlotList(TableB tableB) async {
    await getInternetAccessObject();
    if (internetAccess) {
      List<TableB> slotList =
          await _tableBookPresenter.api.getSlotList(this.user, tableB);
      if (slotList != null) {
        this.slotList = slotList.toList();
      } else {
        this.slotList = new List<TableB>();
      }
    }
    setState(() {
      _isLoadingSlotList = false;
    });
  }

  Future bookTable() async {
    setState(() {
      _isLoadingValue = true;
    });
    await _tableBookPresenter.doBookTable(
        this.user, this._tableNum, this._slotTime);
  }

  Widget getSelectPersonButton(String num) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _personNum == num ? Colors.red : Colors.blue,
          ),
        ),
        child: FlatButton(
          onPressed: () async {
            setState(() {
              _isLoadingTableList = true;
              _tableNum = null;
              _isLoadingSlotList = false;
              _personNum = num;
            });
            await getTableList(_personNum);
          },
          child: Text("$num"),
        ),
      ),
    );
  }

  Widget getSelectTableButton(TableB tableB) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _tableNum != null && _tableNum.name == tableB.name
                ? Colors.red
                : Colors.blue,
          ),
        ),
        child: FlatButton(
          onPressed: () async {
            setState(() {
              _isLoadingSlotList = true;
              _slotTime = null;
              _tableNum = tableB;
            });
            await getSlotList(tableB);
          },
          child: Text("${tableB.name}"),
        ),
      ),
    );
  }

  Widget getSelectSlotButton(TableB tableB) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _slotTime != null && _slotTime.name == tableB.name
                ? Colors.red
                : Colors.blue,
          ),
        ),
        child: FlatButton(
          onPressed: () {
            setState(() {
              _slotTime = tableB;
            });
          },
          child: Text("${tableB.name}"),
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
              height: 40,
            ),
            Container(
              child: Text(
                "Select Person",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            getTable(personNumList, getSelectPersonButton),
            SizedBox(
              height: 14,
            ),
            _personNum != null
                ? _isLoadingTableList
                    ? Container()
                    : Text(
                        "Select Table",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                : Container(),
            _personNum != null
                ? _isLoadingTableList
                    ? gettingDataProgress('Getting Tables')
                    : getTable(this.tableList, getSelectTableButton)
                : Container(),
            SizedBox(
              height: 14,
            ),
            _personNum != null && _tableNum != null
                ? _isLoadingSlotList
                    ? Container()
                    : Text(
                        "Select Time Slot",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                : Container(),
            _personNum != null && _tableNum != null
                ? _isLoadingSlotList
                    ? gettingDataProgress('Getting Time Slots')
                    : slotList.length == 0
                        ? Container(
                            child: Text(
                                "Restaurant is not accepting any order now. Please visit later"),
                          )
                        : getTable(slotList, getSelectSlotButton)
                : Container(),
            SizedBox(
              height: 15,
            ),
            _personNum != null && _tableNum != null && _slotTime != null
                ? _isLoadingValue
                    ? ShowProgress()
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal, width: 4.0),
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            await bookTable();
                          },
                          child: Text("Book Table"),
                        ),
                      )
                : Container(),
          ],
        ),
      );
    }

    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: new Scaffold(
        body: internetAccess
            ? _isLoading ? ShowProgress() : _selectTableBody()
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
                    child: _showInternetStatus.showInternetStatus(widget.isIOS),
                    onRefresh: getInternetAccessObject,
                  ),
      ),
    );
  }
}
