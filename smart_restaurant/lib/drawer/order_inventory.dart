import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/show_internet_status.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/models/order_data.dart';
import 'package:smart_restaurant/utils/custom_services.dart';

class OrderInventory extends StatefulWidget {
  final bool isIOS;
  final User user;
  OrderInventory({this.isIOS, this.user});
  @override
  _OrderInventoryState createState() => _OrderInventoryState(user);
}

class _OrderInventoryState extends State<OrderInventory>
    implements OrderContract {
  bool _isLoading = true;
  bool internetAccess = false;
  ShowDialog _showDialog;
  ShowInternetStatus _showInternetStatus;
  CustomService _customService;

  User user;
  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var scaffoldKey = new GlobalKey<ScaffoldState>();

  DatabaseHelper db = new DatabaseHelper();

  OrderPresenter _orderPresenter;
  List<MadeOrder> madeOrderList;

  List<String> orderStatusList = ["Pending", "Processing", "Completed"];

  _OrderInventoryState(user) {
    this.user = user;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _orderPresenter = new OrderPresenter(this);
    _showInternetStatus = new ShowInternetStatus();
    _showDialog = new ShowDialog();
    _customService = new CustomService();
    getOrderInventory();
    super.initState();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  Future getOrderInventory() async {
    await getInternetAccessObject();
    if (internetAccess) {
      await _orderPresenter.doGetOrderInventory(this.user);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSuccess(String message) {
    _showDialog.showDialogCustom(context, "Success", message);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onError(String errorString) {
    setState(() {
      this.madeOrderList = new List<MadeOrder>();
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", errorString);
  }

  @override
  onOrderInventorySuccess(List<MadeOrder> madeOrderList) {
    setState(() {
      this.madeOrderList = madeOrderList;
    });
  }

  Widget _getOrderObject(List<MadeOrder> madeOrderList, int index, int len) {
    String items = "";
    double total = 0.0;
    len = madeOrderList.length;
    String status = madeOrderList[index].status;
    Color statusColor;
    if (status == orderStatusList[0]) {
      statusColor = Colors.red;
    }
    if (status == orderStatusList[1]) {
      statusColor = Colors.yellow;
    } else if (status == orderStatusList[2]) {
      statusColor = Colors.green;
    }
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
    return ListTile(
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
            "Table Name",
            style: TextStyle(
              color: Color.fromRGBO(140, 140, 140, 1.0),
              fontSize: 11.0,
            ),
          ),
          Text("${madeOrderList[index].tableBooking.tableName.toString()}"),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Time",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createListView(BuildContext context, List<MadeOrder> madeOrderList) {
      int len = 1;
      String showStatus;
      if (len == 0 || madeOrderList == null) {
        len = 1;
        showStatus = "No Orders Yet!";
      }
      return new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
              padding: EdgeInsets.only(top: 20.0),
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
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: _getOrderObject(madeOrderList, index - 1, len),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
            ),
          );
        },
        itemCount: len + 1,
      );
    }

    Widget createListViewIOS(
        BuildContext context, List<MadeOrder> madeOrderList) {
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
                padding: EdgeInsets.only(top: 20.0),
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
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: _getOrderObject(madeOrderList, index - 1, len),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
            );
          },
          childCount: len + 1,
        ),
      );
    }

    return Container(
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
            Colors.red[100],
          ],
        ),
      ),
      child: _isLoading
          ? ShowProgress()
          : internetAccess
              ? widget.isIOS
                  ? new CustomScrollView(
                      slivers: <Widget>[
                        new CupertinoSliverRefreshControl(
                            onRefresh: getOrderInventory),
                        new SliverSafeArea(
                          top: false,
                          sliver: createListViewIOS(context, madeOrderList),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      key: refreshIndicatorKey,
                      child: createListView(context, madeOrderList),
                      onRefresh: getOrderInventory,
                    )
              : widget.isIOS
                  ? new CustomScrollView(
                      slivers: <Widget>[
                        new CupertinoSliverRefreshControl(
                            onRefresh: getOrderInventory),
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
                      onRefresh: getOrderInventory,
                    ),
    );
  }
}
