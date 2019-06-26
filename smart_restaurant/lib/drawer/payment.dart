import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/models/menu_item_data.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  final bool isIOS;
  final User user;
  final int amount;
  Payment({this.isIOS, this.user, this.amount});
  @override
  _PaymentState createState() => _PaymentState(user, amount);
}

class _PaymentState extends State<Payment> {
  bool _isLoading = true;
  bool internetAccess = false;

  User user;
  int amount;
  var refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var scaffoldKey = new GlobalKey<ScaffoldState>();

  List<MenuItemC> menuItemCList = new List<MenuItemC>();
  DatabaseHelper db = new DatabaseHelper();

  _PaymentState(user, amount) {
    this.user = user;
    this.amount = amount;
  }

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  String kAndroidUserAgent =
      "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36";

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  String selectedURL;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        if (url.contains(
            'http://www.smartrestaurant.ml/server_files/pay/thankyou.php')) {
          Uri uri = Uri.parse(url);
          String paymentRequestId = uri.queryParameters['payment_id'];
          _checkPaymentStatus(paymentRequestId);
        }
      }
    });
    getURL(this.user.name, this.user.email, this.user.mobile, this.amount);
    super.initState();
  }

  @override
  void dispose() {
    flutterWebviewPlugin.close();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  Future createRequest(
      String name, String email, String mobile, int amount) async {
    Map<String, String> body = {
      "amount": amount.toString(), //amount to be paid
      "purpose": "Order Placed",
      "buyer_name": name,
      "email": email,
      "phone": mobile,
      "allow_repeated_payments": "true",
      "send_email": "true",
      "send_sms": "true",
      "redirect_url":
          "http://www.smartrestaurant.ml/server_files/pay/thankyou.php",
      "webhook": "http://www.smartrestaurant.ml/server_files/pay/thankyou.php",
    };
    var resp = await http.post(
      Uri.encodeFull("https://test.instamojo.com/api/1.1/payment-requests/"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-Api-Key": "test_550b0550370a1b1fe563209db6a",
        "X-Auth-Token": "test_598752318eb88d0352a5b472c6b"
      },
      body: body,
    );
    Map result;
    try {
      result = json.decode(resp.body);
      return result;
    } on Exception catch (e) {
      result['error'] = true;
      result['errorMessage'] = "Error while catching data";
      return result;
    }
  }

  _checkPaymentStatus(String id) async {
    var response = await http.get(
        Uri.encodeFull("https://test.instamojo.com/api/1.1/payments/$id/"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-Api-Key": "test_550b0550370a1b1fe563209db6a",
          "X-Auth-Token": "test_598752318eb88d0352a5b472c6b"
        });
    var realResponse = json.decode(response.body);
    print(realResponse);
    Navigator.pop(context, realResponse);
  }

  Future getURL(String name, String email, String mobile, int amount) async {
    Map result = await createRequest(name, email, mobile, amount);
    print(result.toString());
    if (result['error'] == null || result['error'] == false) {
      if (result['success'] == true) {
        setState(() {
          selectedURL =
              result["payment_request"]['longurl'].toString() + "?embed=form";
          _isLoading = false;
          flutterWebviewPlugin.launch(
            selectedURL,
            supportMultipleWindows: true,
            appCacheEnabled: true,
            hidden: false,
            enableAppScheme: true,
            rect: new Rect.fromLTRB(
                0.0,
                MediaQuery.of(context).size.height / 7,
                MediaQuery.of(context).size.width - 5.0,
                7 * MediaQuery.of(context).size.height / 7),
          );
        });
      } else {
        _showSnackBar(result['message'].toString());
      }
    } else {
      _showSnackBar(result['message'].toString());
      // Navigator.pop(context, result['errorMessage']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: _isLoading ? ShowProgress() : Container(),
    );
  }
}
