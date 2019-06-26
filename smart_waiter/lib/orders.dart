import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_waiter/models/user_data.dart';
import 'package:smart_waiter/utils/internet_access.dart';
import 'package:smart_waiter/utils/show_internet_status.dart';
import 'package:smart_waiter/utils/show_progress.dart';
import 'package:smart_waiter/utils/show_dialog.dart';
import 'package:smart_waiter/models/order_data.dart';
import 'package:smart_waiter/utils/custom_services.dart';
import 'dart:async';

class TodayOrder extends StatefulWidget {
  final bool isIOS;
  final User user;
  TodayOrder({Key key, this.user, this.isIOS}) : super(key: key);
  _TodayOrderState createState() => _TodayOrderState(user);
}

class _TodayOrderState extends State<TodayOrder> implements OrderContract {
  bool _isLoading = true;
  bool internetAccess = false;
  ShowDialog _showDialog;
  ShowInternetStatus _showInternetStatus;
  CustomService _customService;

  User user;
  var scaffoldKey = new GlobalKey<ScaffoldState>();
  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  List<MadeOrder> madeOrderList = new List<MadeOrder>();
  List<bool> _loadingList = new List<bool>();

  List<String> orderStatusList = ['ALL', 'Ready', 'Reached'];
  String _orderStatus;

  OrderPresenter _orderPresenter;

  _TodayOrderState(User user) {
    this.user = user;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    _customService = new CustomService();
    _showInternetStatus = new ShowInternetStatus();
    _orderPresenter = new OrderPresenter(this);
    _orderStatus = orderStatusList[0];
    getOrderDetails();
    checkOrderTimer();
    super.initState();
  }

  void checkOrderTimer() {
    new Timer.periodic(Duration(seconds: 120), (Timer t) async {
      setState(() {
        _orderStatus = orderStatusList[0];
      });
      await getOrderDetails();
    });
  }

  @override
  void onSuccess(List<MadeOrder> madeOrderList) {
    _loadingList = new List<bool>();
    for (int i = 0; i < madeOrderList.length; i++) {
      _loadingList.add(false);
    }
    setState(() {
      this.madeOrderList = madeOrderList;
    });
  }

  @override
  void onError(String errorString) {
    setState(() {
      this._loadingList = new List<bool>();
      this.madeOrderList = new List<MadeOrder>();
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", errorString);
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  Future getOrderDetails() async {
    await getInternetAccessObject();
    if (internetAccess) {
      await _orderPresenter.doGetOrderInventory(user, _orderStatus, true);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _statusDropDown(BuildContext context) {
    return Container(
      child: DropdownButtonHideUnderline(
        child: new DropdownButton<String>(
          hint: new Text("Orders"),
          value: _orderStatus,
          items: orderStatusList.map((String orderStatus) {
            return new DropdownMenuItem<String>(
              value: orderStatus.toString(),
              child: Text("${orderStatus.toString().toUpperCase()}"),
            );
          }).toList(),
          onChanged: (String val) async {
            setState(() {
              _orderStatus = val;
              _isLoading = true;
            });
            await getOrderDetails();
          },
        ),
      ),
    );
  }

  Widget _getOrderObject(List<MadeOrder> madeOrderList, List<bool> loadingList,
      int index, int len) {
    String items = "";
    String status = madeOrderList[index].status;
    Color statusColor;
    if (status == orderStatusList[1]) {
      statusColor = Colors.red;
    } else if (status == orderStatusList[2]) {
      statusColor = Colors.green;
    }
    double total = 0.0;
    int orderListLength = madeOrderList[index].orderList.length;
    for (int i = 0; i < orderListLength; i++) {
      total += madeOrderList[index].orderList[i].quantity *
          int.parse(
              madeOrderList[index].orderList[i].menuItemC.price.toString());
      String menuItemName = _customService
          .ucFirst(madeOrderList[index].orderList[i].menuItemC.name);
      if (i == orderListLength - 1) {
        items += madeOrderList[index].orderList[i].quantity.toString() +
            " x " +
            menuItemName;
      } else {
        items += madeOrderList[index].orderList[i].quantity.toString() +
            " x " +
            menuItemName +
            ", ";
      }
    }
    return loadingList[index]
        ? Container(
            height: 180.0,
            child: ShowProgress(),
          )
        : Card(
            elevation: 10.0,
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () async {
                  if (status == orderStatusList[1]) {
                    var reached = await _showDialog.showDialogCustomWithAction(
                        context,
                        "Order Confirmation!",
                        "Has order been reached to\nThe Table \"${madeOrderList[index].tableBooking.tableName}\" ",
                        cancelString: "NOT NOW",
                        okString: "REACHED",
                        boxHeight: 65.0);
                    if (reached == true) {
                      setState(() {
                        loadingList[index] = true;
                      });
                      await _orderPresenter.doChangeOrderStatus(
                          user, madeOrderList[index]);
                    }
                  }
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "ITEMS",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text(
                      "$items",
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "ORDERED ON",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text(
                      "${madeOrderList[index].date}",
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "TOTAL",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text(
                      "\u20b9${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "STATUS",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Container(
                      color: statusColor,
                      child: Container(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          "$status",
                          style: TextStyle(
                            fontSize: 21.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "TABLE NAME",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text(
                        "${madeOrderList[index].tableBooking.tableName.toString()}"),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "TIME",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text(
                      "24 hour F",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text("${madeOrderList[index].tableBooking.slotName}"),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 9.0,
                    ),
                    Text(
                      "COMPLETED ORDER",
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1.0),
                        fontSize: 11.0,
                      ),
                    ),
                    Text("${madeOrderList[index].waiterDate}"),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Widget createListView(BuildContext context, List<MadeOrder> madeOrderList,
        List<bool> loadingList) {
      int len = 1;
      String showStatus;
      len = madeOrderList.length;
      if (len == 0 || madeOrderList == null) {
        len = 1;
        showStatus = "No Orders Yet!";
      }
      return new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: _statusDropDown(context),
            );
          }
          if (showStatus != null && len == 1) {
            return Container(
              child: Center(
                child: Text("$showStatus"),
              ),
            );
          }
          return Container(
            padding: EdgeInsets.all(10.0),
            child: _getOrderObject(madeOrderList, loadingList, index - 1, len),
          );
        },
        itemCount: len + 1,
      );
    }

    Widget createListViewIOS(BuildContext context,
        List<MadeOrder> madeOrderList, List<bool> loadingList) {
      int len = 1;
      String showStatus;
      len = madeOrderList.length;
      if (len == 0 || madeOrderList == null) {
        len = 1;
        showStatus = "No Orders Yet!";
      }
      return new SliverList(
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index == 0) {
              return Container(
                padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: _statusDropDown(context),
              );
            }
            if (showStatus != null && len == 1) {
              return Container(
                child: Center(
                  child: Text("$showStatus"),
                ),
              );
            }
            return Container(
              padding: EdgeInsets.all(10.0),
              child:
                  _getOrderObject(madeOrderList, loadingList, index - 1, len),
            );
          },
          childCount: len + 1,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
            image: new ExactAssetImage('assets/images/food/bg.jpg'),
            fit: BoxFit.cover),
      ),
      child: _isLoading
          ? ShowProgress()
          : internetAccess
              ? widget.isIOS
                  ? new CustomScrollView(
                      slivers: <Widget>[
                        new CupertinoSliverRefreshControl(
                          onRefresh: getOrderDetails,
                        ),
                        new SliverSafeArea(
                          top: false,
                          sliver: createListViewIOS(
                              context, madeOrderList, _loadingList),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      key: refreshIndicatorKey,
                      child:
                          createListView(context, madeOrderList, _loadingList),
                      onRefresh: getOrderDetails,
                    )
              : widget.isIOS
                  ? new CustomScrollView(
                      slivers: <Widget>[
                        new CupertinoSliverRefreshControl(
                          onRefresh: getOrderDetails,
                        ),
                        new SliverSafeArea(
                            top: false,
                            sliver: _showInternetStatus
                                .showInternetStatus(widget.isIOS)),
                      ],
                    )
                  : RefreshIndicator(
                      key: refreshIndicatorKey,
                      child:
                          _showInternetStatus.showInternetStatus(widget.isIOS),
                      onRefresh: getOrderDetails,
                    ),
    );
  }
}
