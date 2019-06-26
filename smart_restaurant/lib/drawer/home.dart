import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/show_internet_status.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/category_data.dart';
import 'package:smart_restaurant/models/booking_table_data.dart';
import 'package:smart_restaurant/drawer/menu_item.dart';
import 'package:smart_restaurant/models/order_data.dart';
import 'package:smart_restaurant/utils/custom_services.dart';
import 'dart:ui';

class Home extends StatefulWidget {
  final bool isIOS;
  final User user;
  final Function callbackOrder;
  final TableBooking tableBooking;
  Home({
    this.isIOS,
    this.user,
    this.callbackOrder,
    this.tableBooking,
  });
  @override
  _HomeState createState() => _HomeState(user, callbackOrder, tableBooking);
}

class _HomeState extends State<Home> implements CategoryContract {
  bool _isLoading = true;
  bool internetAccess = false;
  ShowDialog _showDialog;
  ShowInternetStatus _showInternetStatus;
  CustomService _customService;

  User user;
  TableBooking tableBooking;
  Order order;
  Function callbackOrder;

  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  List<Category> categoryList = new List<Category>();
  CategoryPresenter _categoryPresenter;

  _HomeState(user, callbackOrder, tableBooking) {
    this.user = user;
    this.callbackOrder = callbackOrder;
    this.tableBooking = tableBooking;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    _showInternetStatus = new ShowInternetStatus();
    _categoryPresenter = new CategoryPresenter(this);
    _customService = new CustomService();
    getCategoryList();
    super.initState();
  }

  @override
  void onCategorySuccess() {}

  @override
  void onCategoryError() {
    _showDialog.showDialogCustom(context, "Error", "Please try again!");
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

  Future getCategoryList() async {
    await getInternetAccessObject();
    if (internetAccess) {
      List<Category> categoryList =
          await _categoryPresenter.api.getCategoryList();
      if (categoryList != null) {
        this.categoryList = categoryList.toList();
      } else {
        this.categoryList = new List<Category>();
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _getCategoryObject(List<Category> categoryList, index, len) {
      return SizedBox(
        height: 190.0,
        child: RaisedButton(
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MenuItem(
                      isIOS: widget.isIOS,
                      user: this.user,
                      callbackOrder: this.callbackOrderThis,
                      category: categoryList[index],
                      tableBooking: this.tableBooking,
                    ),
              ),
            );
          },
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 25.0),
            child: Column(
              children: [
                FadeInImage.assetNetwork(
                  placeholder: 'assets/images/please_wait.gif',
                  placeholderScale: 3.0,
                  image: categoryList[index].image.toString(),
                  width: MediaQuery.of(context).size.width * 0.40,
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  "${_customService.ucFirst(categoryList[index].name)}",
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget createListView(BuildContext context, List<Category> categoryList) {
      int len = 1;
      int crossAxisCount = 1;
      String showStatus;
      len = categoryList.length;
      if (len == 0 || categoryList == null) {
        len = 1;
        crossAxisCount = 1;
        showStatus = "We will upload data soon!";
      } else {
        crossAxisCount = 2;
      }
      return new GridView.count(
        childAspectRatio: 0.9,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        // Generate 100 Widgets that display their index in the List
        children: List.generate(len, (index) {
          if (showStatus != null && len == 1) {
            return Container(
              child: Center(
                child: Text("$showStatus"),
              ),
            );
          }
          return _getCategoryObject(categoryList, index, len);
        }),
      );
    }

    Widget createListViewIOS(
        BuildContext context, List<Category> categoryList) {
      int len = 1;
      int crossAxisCount = 1;
      String showStatus;
      len = categoryList.length;
      if (len == 0 || categoryList == null) {
        len = 1;
        crossAxisCount = 1;
        showStatus = "We will upload data soon!";
      } else {
        crossAxisCount = 2;
      }
      return new SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.9,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (showStatus != null && len == 1) {
              return Container(
                child: Center(
                  child: Text("$showStatus"),
                ),
              );
            }
            return _getCategoryObject(categoryList, index, len);
          },
          childCount: len,
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
                            onRefresh: getCategoryList),
                        new SliverSafeArea(
                          top: false,
                          sliver: createListViewIOS(context, categoryList),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      key: refreshIndicatorKey,
                      child: createListView(context, categoryList),
                      onRefresh: getCategoryList,
                    )
              : widget.isIOS
                  ? new CustomScrollView(
                      slivers: <Widget>[
                        new CupertinoSliverRefreshControl(
                            onRefresh: getCategoryList),
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
                      onRefresh: getCategoryList,
                    ),
    );
  }
}
