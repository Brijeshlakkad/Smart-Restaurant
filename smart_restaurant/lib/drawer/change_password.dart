import 'package:flutter/material.dart';
import 'package:smart_restaurant/colors.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/utils/internet_access.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';
import 'package:flutter/services.dart';
import 'package:smart_restaurant/utils/show_internet_status.dart';
import 'package:smart_restaurant/utils/check_platform.dart';
import 'package:flutter/cupertino.dart';

class ChangePassword extends StatefulWidget {
  final User user;
  final Function callbackUser;
  ChangePassword({this.user, this.callbackUser});
  @override
  ChangePasswordState createState() {
    return ChangePasswordState(user, callbackUser);
  }
}

class ChangePasswordState extends State<ChangePassword>
    implements UserUpdateContract {
  bool _isLoading = false;
  bool _isLoadingValue = false;
  bool internetAccess = false;
  CheckPlatform _checkPlatform;

  User user;
  Function callbackUser;
  ShowDialog showDialog;
  ShowInternetStatus _showInternetStatus;

  bool _isError = false;
  String _showError;
  String _oldPassword, _newPassword, _newCPassword;
  FocusNode _oldPasswordFocus = new FocusNode();
  FocusNode _newPasswordFocus = new FocusNode();
  FocusNode _newCPasswordFocus = new FocusNode();
  UserUpdatePresenter _userUpdatePresenter;

  var scaffoldKey = new GlobalKey<ScaffoldState>();
  var formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  Function callbackThis(User userDetails) {
    this.callbackUser(userDetails);
    setState(() {
      this.user = userDetails;
    });
  }

  ChangePasswordState(User user, Function callbackUser) {
    this.user = user;
    this.callbackUser = callbackUser;
  }

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showInternetStatus = new ShowInternetStatus();
    _userUpdatePresenter = new UserUpdatePresenter(this);
    _checkPlatform = new CheckPlatform(context: context);
    getInternetAccessObject();
    showDialog = new ShowDialog();
    super.initState();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  @override
  void onUserUpdateError(String errorString) {
    setState(() {
      _isLoadingValue = false;
    });
    this.showDialog.showDialogCustom(context, "Error", errorString);
  }

  @override
  void onUserUpdateSuccess(User userDetails) {
    this.callbackThis(userDetails);
    setState(() {
      _isLoadingValue = false;
    });
    this.showDialog.showDialogCustom(context, "Success", "Password Changed");
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  Future _changePassword() async {
    await getInternetAccessObject();
    if (internetAccess) {
      var form = formKey.currentState;
      if (form.validate()) {
        form.save();
        if (_newPassword == _newCPassword) {
          this._isError = false;
          setState(() {
            _isLoadingValue = true;
          });
          await _userUpdatePresenter.doChangePassword(
              this.user.email, _oldPassword, _newPassword);
          form.reset();
        } else {
          this._isError = true;
          this._showError = "New passwords do not match";
        }
      } else {
        _autoValidate = true;
      }
    } else {
      this.showDialog.showDialogCustom(context, "Internet Connection Problem",
          "Please check your internet connection",
          fontSize: 17.0, boxHeight: 58.0);
    }
  }

  String passwordValidator(String value) {
    Pattern pattern =
        r'^(((?=.*[a-z])(?=.*[A-Z]))|((?=.*[a-z])(?=.*[0-9]))|((?=.*[A-Z])(?=.*[0-9])))(?=.{6,})';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter valid password';
    else
      return null;
  }

  String oldPasswordValidator(String value) {
    if (value == "" || value == null) {
      return "Please enter old password";
    }
    return null;
  }

  Widget _showBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Form(
        key: formKey,
        autovalidate: _autoValidate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Old Password",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.7),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: new TextFormField(
                        onSaved: (value) {
                          _oldPassword = value;
                        },
                        validator: oldPasswordValidator,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        focusNode: _oldPasswordFocus,
                        onFieldSubmitted: (value) {
                          _fieldFocusChange(
                              context, _oldPasswordFocus, _newPasswordFocus);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Your Old Password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "New Password",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.7),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: new TextFormField(
                        onSaved: (value) {
                          _newPassword = value;
                        },
                        validator: passwordValidator,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        focusNode: _newPasswordFocus,
                        onFieldSubmitted: (value) {
                          _fieldFocusChange(
                              context, _newPasswordFocus, _newCPasswordFocus);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Your New Password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Confirm New Password",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.7),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: new TextFormField(
                        onSaved: (value) {
                          _newCPassword = value;
                        },
                        validator: passwordValidator,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        focusNode: _newCPasswordFocus,
                        onFieldSubmitted: (value) async {
                          await _changePassword();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Confirm Your New Password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _isError
                ? Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          child: Text(
                            "$_showError",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: _isLoadingValue
                  ? ShowProgress()
                  : FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      color: lBlue300,
                      onPressed: () async {
                        await _changePassword();
                      },
                      child: Text('Change Password'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return internetAccess
        ? _isLoading ? ShowProgress() : _showBody(context)
        : _checkPlatform.isIOS()
            ? new CustomScrollView(
                slivers: <Widget>[
                  new CupertinoSliverRefreshControl(
                    onRefresh: getInternetAccessObject,
                  ),
                  new SliverSafeArea(
                      top: false,
                      sliver: _showInternetStatus
                          .showInternetStatus(_checkPlatform.isIOS())),
                ],
              )
            : RefreshIndicator(
                child: _showInternetStatus
                    .showInternetStatus(_checkPlatform.isIOS()),
                onRefresh: getInternetAccessObject,
              );
  }
}
