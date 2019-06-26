import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_waiter/models/user_data.dart';
import 'package:smart_waiter/utils/internet_access.dart';
import 'package:smart_waiter/data/database_helper.dart';
import 'package:smart_waiter/utils/check_platform.dart';
import 'package:smart_waiter/models/booking_table_data.dart';
import 'package:smart_waiter/models/order_data.dart';
import 'package:smart_waiter/orders.dart';
import 'package:smart_waiter/previous_orders.dart';

class HomePage extends StatefulWidget {
  final drawerItems = [
    new DrawerItem("Today's Orders", Icons.view_list),
    new DrawerItem("Previous Orders", Icons.history),
  ];
  final callbackUser;
  final TableBooking tableBooking;
  HomePage({Key key, this.user, this.callbackUser, this.tableBooking})
      : super(key: key);
  final User user;
  _HomePageState createState() =>
      _HomePageState(user, callbackUser, tableBooking);
}

class _HomePageState extends State<HomePage> {
  bool internetAccess = false;
  CheckPlatform _checkPlatform;

  User user;
  Function callbackUser;
  TableBooking tableBooking;
  Order order;
  Function callbackOrder;
  var scaffoldKey = new GlobalKey<ScaffoldState>();

  _HomePageState(User user, callbackUser, tableBooking) {
    this.user = user;
    this.callbackUser = callbackUser;
    this.tableBooking = tableBooking;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    super.initState();
  }

  void callbackThis(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
  }

  void callbackOrderThis(Order order) {
    setState(() {
      this.order = order;
    });
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new TodayOrder(
          isIOS: _checkPlatform.isIOS(),
          user: this.user,
        );
      case 1:
        return new PreviousOrder(
          isIOS: _checkPlatform.isIOS(),
          user: this.user,
        );
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(
          d.icon,
          color: Color.fromRGBO(10, 10, 10, 1.0),
        ),
        title: new Text(
          d.title,
          style: TextStyle(
            color: Color.fromRGBO(10, 10, 10, 1.0),
          ),
        ),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    drawerOptions.add(
      new ListTile(
        leading: new Icon(
          Icons.close,
          color: Color.fromRGBO(10, 10, 10, 1.0),
        ),
        title: new Text(
          "Logout",
          style: TextStyle(
            color: Color.fromRGBO(10, 10, 10, 1.0),
          ),
        ),
        onTap: () async {
          var db = new DatabaseHelper();
          await db.deleteUsers();
          print("logout");
          Navigator.pushNamed(context, "/");
        },
      ),
    );
    Widget getTitle() {
//      switch (_selectedDrawerIndex) {
//        case 0:
//          return Text("Home");
//        case 0:
//          return Text("Home");
//      }
      return Text("${widget.drawerItems[_selectedDrawerIndex].title}");
    }

    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: getTitle(),
        ),
        drawer: new Drawer(
          child: new Column(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/user.jpeg"),
                      fit: BoxFit.cover),
                ),
                accountName: new Text(
                  "${this.user.name}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                accountEmail: new Text(
                  "${this.user.email}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
              new Column(children: drawerOptions)
            ],
          ),
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      ),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}
