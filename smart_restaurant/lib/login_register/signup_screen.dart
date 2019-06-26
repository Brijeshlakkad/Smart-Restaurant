import 'package:flutter/material.dart';
import 'package:smart_restaurant/colors.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/signup_screen_presenter.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';

class SignupScreen extends StatefulWidget {
  final Color primaryColor;
  final Color backgroundColor;

  SignupScreen({
    Key key,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  SignupScreenState createState() {
    return new SignupScreenState();
  }
}

class SignupScreenState extends State<SignupScreen>
    implements SignupScreenContract {
  var scaffoldKey = new GlobalKey<ScaffoldState>();
  var formKey = new GlobalKey<FormState>();
  bool _isLoading = false, _isLoadingValue = false;
  bool _autoValidate = false;
  String _passwordValidText =
      "Password should contain at least one small and large alpha characters";
  String _name, _email, _password, _address, _city, _contact;
  ShowDialog _showDialog;
  FocusNode _nameNode = new FocusNode();
  FocusNode _emailNode = new FocusNode();
  FocusNode _passwordNode = new FocusNode();
  FocusNode _addressNode = new FocusNode();
  FocusNode _cityNode = new FocusNode();
  FocusNode _contactNode = new FocusNode();

  SignupScreenPresenter _presenter;
  @override
  void initState() {
    _presenter = new SignupScreenPresenter(this);
    _showDialog = new ShowDialog();
    super.initState();
  }

  void _submit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      setState(() => _isLoadingValue = true);
      form.save();
      await _presenter.doSignup(
          _name, _email, _password, _address, _city, _contact);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  void onSignupSuccess(Map res) async {
    Map result = new Map();
    result['success'] = true;
    result['responseMessage'] = res['responseMessage'];
    setState(() => _isLoadingValue = false);
    Navigator.of(context).pop(result);
  }

  @override
  void onSignupError(String errorTxt) {
    print("x");
    _showDialog.showDialogCustom(context, "Error", errorTxt,
        fontSize: 17.0, boxHeight: 58.0);
    setState(() {
      _isLoadingValue = false;
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  @override
  Widget build(BuildContext context) {
    String nameValidator(String value) {
      Pattern pattern = r'^[a-zA-Z0-9/s]+$';
      Pattern pattern2 = r'^([0-9])+[a-zA-Z0-9/s]+$';
      RegExp regex = new RegExp(pattern);
      RegExp regex2 = new RegExp(pattern2);
      if (value.isEmpty)
        return 'Name should not be empty';
      else if (!regex.hasMatch(value))
        return 'Name should not contain special character';
      else if (regex2.hasMatch(value))
        return 'Name should not start with alpanumerics';
      else if (value.length <= 3)
        return "Name should have more than 3 characters";
      else
        return null;
    }

    String emailValidator(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid email';
      else
        return null;
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

    String addressValidator(String value) {
      Pattern pattern = r'^[0-9a-zA-Z,/. ]+$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty)
        return 'Address should not be empty';
      else if (!regex.hasMatch(value))
        return 'Address should have only [,/. ] special characters';
      else if (value.length <= 8)
        return "Address should have more than 8 characters";
      else
        return null;
    }

    String cityValidator(String value) {
      Pattern pattern = r'^[a-zA-Z]+$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty)
        return 'City should not be empty';
      else if (!regex.hasMatch(value))
        return 'City should not contain special characters';
      else if (value.length <= 2)
        return "City should have more than 2 characters";
      else
        return null;
    }

    String contactValidator(String value) {
      Pattern pattern = r'^[0-9]{10}$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty)
        return 'Contact should not be empty';
      else if (!regex.hasMatch(value))
        return 'Contact should only 10 contain numbers';
      else
        return null;
    }

    Widget signupPage = new Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: this.widget.backgroundColor,
      ),
      child: new Form(
        autovalidate: _autoValidate,
        key: formKey,
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 43.0,
                        fontWeight: FontWeight.bold,
                        color: this.widget.primaryColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Name",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),
                  new Expanded(
                    child: new TextFormField(
                      onSaved: (val) {
                        _name = val;
                      },
                      autofocus: true,
                      focusNode: _nameNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onFieldSubmitted: (val) {
                        _fieldFocusChange(context, _nameNode, _emailNode);
                      },
                      validator: nameValidator,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your Name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Email",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.alternate_email,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),
                  new Expanded(
                    child: new TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => _email = val,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailNode,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, _emailNode, _passwordNode);
                      },
                      validator: emailValidator,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your Email',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Password",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.lock_open,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),
                  new Expanded(
                    child: new TextFormField(
                      onSaved: (val) => _password = val,
                      validator: passwordValidator,
                      textInputAction: TextInputAction.next,
                      focusNode: _passwordNode,
                      onFieldSubmitted: (val) {
                        _fieldFocusChange(context, _passwordNode, _addressNode);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: Tooltip(
                          message: _passwordValidText,
                          padding: EdgeInsets.all(20.0),
                          verticalOffset: 10.0,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () {},
                            child: Container(
                              child: Text("?"),
                            ),
                          ),
                        ),
                      ),
                      obscureText: true,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Address",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.home,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),
                  new Expanded(
                    child: new TextFormField(
                      onSaved: (val) {
                        _address = val;
                      },
                      focusNode: _addressNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      onFieldSubmitted: (val) {
                        _fieldFocusChange(context, _addressNode, _cityNode);
                      },
                      validator: addressValidator,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your Address',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "City",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.location_city,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),
                  new Expanded(
                    child: new TextFormField(
                      onSaved: (val) {
                        _city = val;
                      },
                      focusNode: _cityNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onFieldSubmitted: (val) {
                        _fieldFocusChange(context, _cityNode, _contactNode);
                      },
                      validator: cityValidator,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your City',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                "Contact",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.local_phone,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),
                  new Expanded(
                    child: new TextFormField(
                      onSaved: (val) {
                        _contact = val;
                      },
                      focusNode: _contactNode,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onFieldSubmitted: (val) {
                        _contactNode.unfocus();
                        _submit();
                      },
                      validator: contactValidator,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Your Contact',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
            _isLoadingValue
                ? ShowProgress()
                : Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: FlatButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            splashColor: this.widget.primaryColor,
                            color: this.widget.primaryColor,
                            child: new Row(
                              children: <Widget>[
                                new Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                new Expanded(
                                  child: Container(),
                                ),
                                new Transform.translate(
                                  offset: Offset(15.0, 0.0),
                                  child: new Container(
                                    padding: const EdgeInsets.all(5.0),
                                    child: FlatButton(
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(28.0)),
                                      splashColor: Colors.white,
                                      color: Colors.white,
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: this.widget.primaryColor,
                                      ),
                                      onPressed: _submit,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        alignment: Alignment.center,
                        child: Text(
                          "HAVE AN ACCOUNT?",
                          style: TextStyle(color: this.widget.primaryColor),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return new Scaffold(
      appBar: null,
      key: scaffoldKey,
      body: new Center(
        child: Container(
          child: _isLoading ? ShowProgress() : signupPage,
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(50.0, 10.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
