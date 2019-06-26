import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/menu_item_data.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/drawer/payment.dart';
import 'package:smart_restaurant/models/order_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';

class OrderList extends StatefulWidget {
  final bool isIOS;
  final User user;
  final bool fromMenu;
  final TableBooking tableBooking;
  final Function changePage;
  OrderList(
      {this.isIOS,
      this.user,
      this.fromMenu,
      this.tableBooking,
      this.changePage});
  @override
  _OrderListState createState() =>
      _OrderListState(user, tableBooking, changePage);
}

class _OrderListState extends State<OrderList> implements OrderContract {
  bool _isLoading = true;
  bool internetAccess = false;
  ShowDialog _showDialog;

  User user;
  Function changePage;
  List<Order> orderList = new List<Order>();
  List<int> quantity = new List<int>();
  TableBooking tableBooking;
  int totalPrice = 0;
  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var scaffoldKey = new GlobalKey<ScaffoldState>();

  List<MenuItemC> menuItemCList = new List<MenuItemC>();
  DatabaseHelper db = new DatabaseHelper();

  OrderPresenter _orderPresenter;

  _OrderListState(user, tableBooking, changePage) {
    this.user = user;
    this.tableBooking = tableBooking;
    this.changePage = changePage;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _orderPresenter = new OrderPresenter(this);
    _showDialog = new ShowDialog();
    getOrderList();
    super.initState();
  }

  Future getOrderList() async {
    this.orderList = await db.getOrderDetails();
    for (int i = 0; i < orderList.length; i++) {
      quantity.add(orderList[i].quantity);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future makeOrder(List<Order> orderList) async {
    setState(() {
      _isLoading = true;
    });
    await _orderPresenter.doOrder(this.user, orderList, this.tableBooking);
  }

  @override
  void onSuccess(String message) async {
    _showDialog.showDialogCustom(context, "Success", message);
    await db.deleteAllOrders();
    await getOrderList();
    if (changePage != null) {
      this.changePage(3);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
  }

  @override
  onOrderInventorySuccess(List<MadeOrder> madeOrderList) {}

  @override
  Widget build(BuildContext context) {
    List<TableCell> getTableCell(Order order, int index) {
      int price = int.parse(order.menuItemC.price.toString());
      List<TableCell> cellList = new List<TableCell>();
      cellList.add(
        TableCell(
          child: Text(
            "${order.menuItemC.name}",
            style: TextStyle(height: 3.0),
            textAlign: TextAlign.left,
          ),
        ),
      );
      cellList.add(
        TableCell(
          child: Text(
            "${order.menuItemC.price}",
            style: TextStyle(height: 3.0),
            textAlign: TextAlign.center,
          ),
        ),
      );
      cellList.add(
        TableCell(
          child: Row(
            children: <Widget>[
              Container(
                width: 35.0,
                child: RaisedButton(
                  onPressed: () async {
                    if (quantity[index] > 0) {
                      setState(() {
                        quantity[index]--;
                      });
                      await db.updateOrder(order, quantity[index]);
                      await getOrderList();
                    }
                  },
                  child: Text(
                    "-",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                width: 50.0,
                child: RaisedButton(
                  disabledColor: Colors.white,
                  disabledTextColor: Colors.black,
                  onPressed: null,
                  child: Text(
                    "${quantity[index]}",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                width: 35.0,
                child: RaisedButton(
                  onPressed: () async {
                    if (quantity[index] < 10) {
                      setState(() {
                        quantity[index]++;
                      });
                      await db.updateOrder(order, quantity[index]);
                      await getOrderList();
                    }
                  },
                  child: Text(
                    "+",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      cellList.add(
        TableCell(
          child: Text(
            "\u20b9 ${price * order.quantity}",
            style: TextStyle(height: 3.0),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return cellList;
    }

    List<TableRow> getTableRows(List<Order> orderList) {
      totalPrice = 0;
      List<TableRow> rowList = new List<TableRow>();
      rowList.add(
        TableRow(children: [
          TableCell(
            child: Text(
              "Name",
              style: TextStyle(
                height: 3.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          TableCell(
            child: Text(
              "Price",
              style: TextStyle(
                height: 3.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TableCell(
            child: Text(
              "Quantity",
              style: TextStyle(
                height: 3.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TableCell(
            child: Text(
              "Total",
              style: TextStyle(
                height: 3.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      );
      for (int i = 0; i < orderList.length; i++) {
        totalPrice +=
            int.parse(orderList[i].menuItemC.price.toString()) * quantity[i];
        rowList.add(
          TableRow(
            children: getTableCell(orderList[i], i),
          ),
        );
      }
      setState(() {});
      return rowList;
    }

    Map<int, TableColumnWidth> widthMap = new Map<int, TableColumnWidth>();
    widthMap[0] = FlexColumnWidth(8.0);
    widthMap[1] = FlexColumnWidth(3.0);
    widthMap[2] = FlexColumnWidth(7.0);
    widthMap[3] = FlexColumnWidth(3.0);
    Widget showOrderList(List<Order> orderList) {
      if (orderList.length == 0) {
        return Container(
          child: Center(
            child: Text(
              "Please make an order",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        );
      }
      return ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Table(
              columnWidths: widthMap,
              children: getTableRows(orderList),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Total ",
                        style: TextStyle(fontSize: 19.0),
                      ),
                      SizedBox(
                        width: 3.0,
                      ),
                      Text(
                        "\u20b9 $totalPrice",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19.0),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: RaisedButton(
                    onPressed: () async {
                      Map realResponse = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Payment(
                                isIOS: widget.isIOS,
                                user: this.user,
                                amount: this.totalPrice,
                              ),
                        ),
                      );
                      if (realResponse['success'] == true) {
                        await makeOrder(this.orderList);
                      } else {
                        _showDialog.showDialogCustom(
                            context, "FAILED", "PAYMENT FAILED");
                      }
                    },
                    color: Colors.black,
                    child: Text(
                      "Order",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
//      return ListView.builder(
//        itemBuilder: (BuildContext context, int index) {
//          return ListTile(
//            title: Text("${orderList[index].menuItemC.name}"),
//            trailing: Column(
//              children: <Widget>[
//                Text("${orderList[index].quantity}"),
//                Text("Total ${orderList[index].menuItemC.price * }")
//              ],
//            ),
//            subtitle: Text("${orderList[index].category.name}"),
//          );
//        },
//        itemCount: orderList.length,
//      );
    }

    return widget.fromMenu
        ? _isLoading ? ShowProgress() : showOrderList(this.orderList)
        : Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text("Order List"),
            ),
            body: _isLoading ? ShowProgress() : showOrderList(this.orderList),
          );
  }
}
