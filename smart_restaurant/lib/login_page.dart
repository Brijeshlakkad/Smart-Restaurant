import 'package:flutter/material.dart';
import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/auth.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/login_screen_presenter.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/colors.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/signup_page.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:smart_restaurant/select_table.dart';
import 'package:smart_restaurant/utils/check_platform.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>
    implements LoginScreenContract, AuthStateListener {
  bool _obscureText = true;
  bool _isLoadingValue = false;
  bool _isLoading = true;
  ShowDialog _showDialog;
  CheckPlatform _checkPlatform;

  String _password, _email;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _autoValidate = false;
  bool _showError = false;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  DatabaseHelper db = new DatabaseHelper();

  LoginScreenPresenter _presenter;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _showDialog = new ShowDialog();
    _presenter = new LoginScreenPresenter(this);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
    authStateProvider.initState();
    super.initState();
  }

  void _submit() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    if (await checkInternetAccess.check()) {
      final form = formKey.currentState;
      setState(() => _showError = false);
      if (form.validate()) {
        setState(() => _isLoadingValue = true);
        form.save();
        await _presenter.doLogin(_email, _password);
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    } else {
      _showSnackBar("Please check internet connection");
    }
  }

  @override
  onAuthStateChanged(AuthState state, User user) async {
    if (state == AuthState.LOGGED_IN) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SelectTable(isIOS: _checkPlatform.isIOS(), user: user),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid Email';
      else
        return null;
    }

    String validatePassword(String value) {
      if (value.isEmpty)
        return 'Please enter password';
      else
        return null;
    }

    void _toggle() {
      setState(() {
        _obscureText = !_obscureText;
      });
    }

    var loginBtn = new Container(
      padding: EdgeInsets.symmetric(horizontal: 50.0),
      width: 400.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(46.0)),
      ),
      child: new RaisedButton(
        color: lBlue300,
        onPressed: _submit,
        child: new Text("LOGIN"),
      ),
    );
    var loginForm = Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: new ListView(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.only(top: 30.0),
            child: Center(
              child: Text(
                "Smart Restaurant",
                style: TextStyle(color: Colors.indigo, fontSize: 30.0),
              ),
            ),
          ),
          SizedBox(
            height: 35.0,
          ),
          new Form(
            autovalidate: _autoValidate,
            key: formKey,
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => _email = val,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _emailFocus, _passwordFocus);
                    },
                    validator: validateEmail,
                    decoration: new InputDecoration(labelText: "Email"),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: new TextFormField(
                          onSaved: (val) => _password = val,
                          validator: validatePassword,
                          textInputAction: TextInputAction.next,
                          focusNode: _passwordFocus,
                          onFieldSubmitted: (term) {
                            _passwordFocus.unfocus();
                            _submit();
                          },
                          decoration: new InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: _toggle,
                            ),
                          ),
                          obscureText: _obscureText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: _showError
                  ? Container(
                      child: Text(
                        "Email id or Password is wrong",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Container(),
            ),
          ),
          Center(
            child: _isLoadingValue ? new ShowProgress() : loginBtn,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
              onPressed: () async {
                Map result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(),
                  ),
                );
                if (result != null && result['success'] != null) {
                  _showDialog.showDialogCustom(
                      context,
                      result['responseMessage'].toString(),
                      "You can now login");
                }
              },
              child: Text(
                'Sign Up?',
                textScaleFactor: 1,
                style: TextStyle(
                  color: lBlue50,
                ),
              ),
            ),
          )
        ],
      ),
    );

    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: new Scaffold(
        appBar: null,
        key: scaffoldKey,
        body: new Center(
          child: Container(
            child: _isLoading ? ShowProgress() : loginForm,
          ),
        ),
      ),
    );
  }

  @override
  void onLoginError(String errorTxt) {
    setState(() {
      _isLoadingValue = false;
      _showError = true;
    });
  }

  @override
  void onLoginSuccess(User user) async {
    setState(() => _isLoadingValue = false);
    var db = new DatabaseHelper();
    await db.saveUser(user);
    final form = formKey.currentState;
    form.reset();
    var authStateProvider = new AuthStateProvider();
    authStateProvider.notify(AuthState.LOGGED_IN, user);
  }
}
