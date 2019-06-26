import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/show_internet_status.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/table_book/select_slot.dart';
import 'dart:async';

class SelectTable extends StatefulWidget {
  final bool isIOS;
  final User user;
  final String personNum;
  final callbackCheckTable;
  SelectTable({this.isIOS, this.user, this.personNum, this.callbackCheckTable});
  @override
  _SelectTableState createState() => _SelectTableState(user, personNum);
}

class _SelectTableState extends State<SelectTable>
    implements TableBookContract {
  bool _isLoading = true;
  bool internetAccess = false;
  ShowDialog _showDialog;
  ShowInternetStatus _showInternetStatus;

  User user;
  TableBooking tableBooking;
  bool checkingTable;
  DatabaseHelper db = new DatabaseHelper();

  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  String personNum;
  TableB _tableNum;
  List personNumList = ['1', '2', '3', '4', '5', '6'];
  List<TableB> tableList = new List<TableB>();
  TableBookPresenter _tableBookPresenter;

  _SelectTableState(user, personNum) {
    this.user = user;
    this.personNum = personNum;
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
    getTableList(this.personNum);
    _showInternetStatus = new ShowInternetStatus();
    super.initState();
  }

  @override
  void onGetBookedTableSuccess(TableBooking tableBooking) async {}

  @override
  void onBookTableSuccess(Map res) async {}

  @override
  void onBookTableError(String errorString) {}

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
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
      _isLoading = false;
    });
  }

  Widget getSelectTableButton(TableB tableB) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: tableB.isAvail
                ? _tableNum != null && _tableNum.name == tableB.name
                    ? Colors.red
                    : Colors.blue
                : Colors.grey,
            width: 2.0,
          ),
        ),
        child: tableB.isAvail
            ? FlatButton(
                onPressed: () async {
                  setState(() {
                    _tableNum = tableB;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SelectSlot(
                            isIOS: widget.isIOS,
                            user: this.user,
                            personNum: this.personNum,
                            tableNum: this._tableNum,
                            callbackCheckTable: widget.callbackCheckTable,
                          ),
                    ),
                  );
                },
                child: Text(
                  "${tableB.name}",
                ),
              )
            : FlatButton(
                onPressed: null,
                child: Text(
                  "${tableB.name}",
                ),
              ),
      ),
    );
  }

  Widget getSelectTableImageButton(TableB tableB) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: tableB.isAvail
                ? _tableNum != null && _tableNum.name == tableB.name
                    ? Colors.red
                    : Colors.blue
                : Colors.grey,
            width: 2.0,
          ),
        ),
        child: tableB.isAvail
            ? FlatButton(
                onPressed: () async {
                  setState(() {
                    _tableNum = tableB;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SelectSlot(
                            isIOS: widget.isIOS,
                            user: this.user,
                            personNum: this.personNum,
                            tableNum: this._tableNum,
                            callbackCheckTable: widget.callbackCheckTable,
                          ),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/images/table.png",
                  width: 40,
                ),
              )
            : FlatButton(
                onPressed: null,
                child: Image.asset(
                  "assets/images/table.png",
                  width: 40,
                ),
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

  Widget showTextWidget(String str) {
    return Container(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 3.0,
          ),
        ),
        child: FlatButton(
          onPressed: null,
          child: Text("$str"),
        ),
      ),
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

    Widget getTable(List<TableB> tableList, callFunction) {
      return Table(children: getTableRows(tableList, callFunction));
    }

    Widget drawTables(List<TableB> tableList, callFunction) {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300],
                        width: 3.0,
                      ),
                    ),
                    child: Text(
                      "Kitchen",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getSelectTableImageButton(tableList[0]),
              getSelectTableImageButton(tableList[1]),
            ],
          ),
          Center(
            child: getSelectTableImageButton(tableList[2]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getSelectTableImageButton(tableList[3]),
              getSelectTableImageButton(tableList[4]),
            ],
          ),
          Center(
            child: getSelectTableImageButton(tableList[5]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getSelectTableImageButton(tableList[6]),
              getSelectTableImageButton(tableList[7]),
            ],
          ),
          Center(
            child: getSelectTableImageButton(tableList[8]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getSelectTableImageButton(tableList[9]),
//              showTextWidget("Door"),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300],
                        width: 3.0,
                      ),
                    ),
                    child: Text(
                      "Door",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }

    Widget _selectTableBody() {
      return Container(
        padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Number of Person",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    "${this.personNum}",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            drawTables(this.tableList, getSelectTableButton),
//            getTable(this.tableList, getSelectTableButton),
          ],
        ),
      );
    }

    return new Scaffold(
      appBar: AppBar(
        title: Text("Select Table Number"),
      ),
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
    );
  }
}
