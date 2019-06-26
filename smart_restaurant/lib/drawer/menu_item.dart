import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/show_internet_status.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/category_data.dart';
import 'package:smart_restaurant/models/menu_item_data.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/drawer/order_list.dart';
import 'package:smart_restaurant/models/order_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';
import 'package:smart_restaurant/utils/custom_services.dart';

class MenuItem extends StatefulWidget {
  final bool isIOS;
  final User user;
  final Function callbackOrder;
  final Category category;
  final TableBooking tableBooking;
  MenuItem(
      {this.isIOS,
      this.user,
      this.callbackOrder,
      this.category,
      this.tableBooking});
  @override
  _MenuItemState createState() =>
      _MenuItemState(user, callbackOrder, category, tableBooking);
}

class _MenuItemState extends State<MenuItem> implements MenuItemCContract {
  bool _isLoading = true;
  bool internetAccess = false;
  ShowDialog _showDialog;
  ShowInternetStatus _showInternetStatus;
  CustomService _customService;

  User user;
  Function callbackOrder;
  Category category;
  TableBooking tableBooking;

  int price;
  int quantity = 1;
  List<Order> orderList = new List<Order>();
  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  List<MenuItemC> menuItemCList = new List<MenuItemC>();
  MenuItemCPresenter _menuItemCPresenter;
  DatabaseHelper db = new DatabaseHelper();

  _MenuItemState(user, callbackOrder, category, tableBooking) {
    this.user = user;
    this.callbackOrder = callbackOrder;
    this.category = category;
    this.tableBooking = tableBooking;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    _showInternetStatus = new ShowInternetStatus();
    _menuItemCPresenter = new MenuItemCPresenter(this);
    _customService = new CustomService();
    getMenuItemCList();
    super.initState();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  Future getMenuItemCList() async {
    await getInternetAccessObject();
    if (internetAccess) {
      List menuItemCList =
          await _menuItemCPresenter.api.getMenuItemCList(this.category);
      if (menuItemCList != null) {
        this.menuItemCList = menuItemCList.toList();
      } else {
        this.menuItemCList = new List<MenuItemC>();
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future addToCart(
      User user, Category category, MenuItemC menuItem, int quantity) async {
    Order order = Order(category, menuItem, quantity);
    int res = await db.saveOrder(order);
    if (res == null) {
      onMenuItemCError("Order couldn't ne saved");
    }
  }

  @override
  void onMenuItemCSuccess(Map result) {
    _showDialog.showDialogCustom(context, "Success", result['message']);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onMenuItemCError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
  }

  void callbackThis(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
  }

  void callbackOrderThis(List<Order> orderList) {
    setState(() {
      this.orderList = orderList;
    });
    this.callbackOrder(orderList);
  }

  getQuantityDialog(MenuItemC menuItem) async {
    setState(() {
      price = int.parse(menuItem.price);
    });
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: Container(
              height: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/images/please_wait.gif',
                    placeholderScale: 3.0,
                    image: menuItem.image.toString(),
                    width: 120.0,
                    height: 120.0,
                  ),
                  Text(
                    "${menuItem.name}",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 21.0),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    "in ${this.category.name}",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "\u20b9 ${menuItem.price}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        color: Colors.blue,
                        child: Container(
                          padding: EdgeInsets.all(9.0),
                          child: Text(
                            "\u20b9 ${price * quantity}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 45.0,
                              child: RaisedButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                    Navigator.pop(context);
                                    getQuantityDialog(menuItem);
                                  }
                                },
                                child: Text("-"),
                              ),
                            ),
                            Container(
                              width: 49.0,
                              child: RaisedButton(
                                onPressed: () {},
                                child: Text("$quantity"),
                              ),
                            ),
                            Container(
                              width: 45.0,
                              child: RaisedButton(
                                onPressed: () {
                                  if (quantity < 9) {
                                    setState(() {
                                      quantity++;
                                    });
                                    Navigator.pop(context);
                                    getQuantityDialog(menuItem);
                                  }
                                },
                                child: Text("+"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                  quantity = 1;
                  price = 0;
                },
              ),
              new FlatButton(
                child: const Text('ADD TO CART'),
                onPressed: () async {
                  Navigator.pop(context);
                  addToCart(this.user, this.category, menuItem, this.quantity);
                  quantity = 1;
                  price = 0;
                },
              ),
            ],
          ),
    );
  }

  Widget _getMenuItemObject(List<MenuItemC> menuItemCList, int index, int len) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.only(top: 10.0),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/images/please_wait.gif',
          placeholderScale: 3.0,
          image: menuItemCList[index].image.toString(),
          width: MediaQuery.of(context).size.width * 0.23,
          height: 100.0,
        ),
      ),
      title: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "${menuItemCList[index].name}",
              style: TextStyle(fontSize: 15.0),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
      subtitle: menuItemCList[index].description.length > 60
          ? Text(
              "${menuItemCList[index].description.substring(0, 60)}..",
              style: TextStyle(fontSize: 13.0),
            )
          : Text(
              "${menuItemCList[index].description}",
              style: TextStyle(fontSize: 13.0),
            ),
      trailing: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: RaisedButton(
                onPressed: () async {
                  await getQuantityDialog(menuItemCList[index]);
                },
                child: Text("+ Add"),
              ),
            ),
            Text(
              "\u20b9 ${menuItemCList[index].price}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createListView(BuildContext context, List<MenuItemC> menuList) {
      int len = 1;
      String showStatus;
      len = menuList.length;
      if (len == 0 || menuItemCList == null) {
        len = 1;
        showStatus = "We will upload data soon!";
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
            padding: EdgeInsets.only(bottom: 10.0),
            child: _getMenuItemObject(menuItemCList, index - 1, len),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
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

    Widget createListViewIOS(BuildContext context, List<MenuItemC> menuList) {
      int len = 1;
      String showStatus;
      len = menuList.length;
      if (len == 0 || menuItemCList == null) {
        len = 1;
        showStatus = "We will upload data soon!";
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
              padding: EdgeInsets.only(bottom: 10.0),
              child: _getMenuItemObject(menuItemCList, index - 1, len),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
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

    return Scaffold(
      appBar: AppBar(
        title: Text("${_customService.ucFirst(category.name)}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => OrderList(
                        isIOS: widget.isIOS,
                        user: this.user,
                        fromMenu: false,
                        tableBooking: this.tableBooking,
                        changePage: null,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
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
        child: _isLoading
            ? ShowProgress()
            : internetAccess
                ? widget.isIOS
                    ? new CustomScrollView(
                        slivers: <Widget>[
                          new CupertinoSliverRefreshControl(
                              onRefresh: getMenuItemCList),
                          new SliverSafeArea(
                            top: false,
                            sliver: createListViewIOS(context, menuItemCList),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        key: refreshIndicatorKey,
                        child: createListView(context, menuItemCList),
                        onRefresh: getMenuItemCList,
                      )
                : widget.isIOS
                    ? new CustomScrollView(
                        slivers: <Widget>[
                          new CupertinoSliverRefreshControl(
                              onRefresh: getMenuItemCList),
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
                        onRefresh: getMenuItemCList,
                      ),
      ),
    );
  }
}
