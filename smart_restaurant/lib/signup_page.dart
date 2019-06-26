import "package:flutter/material.dart";
import 'package:smart_restaurant/colors.dart';
import 'package:smart_restaurant/utils/show_progress.dart';
import 'package:smart_restaurant/signup_screen_presenter.dart';
import 'package:smart_restaurant/utils/show_dialog.dart';

class SignupScreen extends StatefulWidget {
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

    var _showRegisterForm = new ListView(
      children: <Widget>[
        new Container(
          padding:
              EdgeInsets.only(top: 20.0, bottom: 10.0, left: 20.0, right: 20.0),
          child: Text(
            'Signup',
            textScaleFactor: 2.0,
          ),
        ),
        new Container(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
          child: new Form(
            autovalidate: _autoValidate,
            key: formKey,
            child: Column(
              children: <Widget>[
                new TextFormField(
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
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                new TextFormField(
                  onSaved: (val) {
                    _email = val;
                  },
                  focusNode: _emailNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _emailNode, _passwordNode);
                  },
                  validator: emailValidator,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                new TextFormField(
                  onSaved: (val) {
                    _password = val;
                  },
                  validator: passwordValidator,
                  obscureText: true,
                  focusNode: _passwordNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _passwordNode, _addressNode);
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                ),
                new TextFormField(
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
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                new TextFormField(
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
                  decoration: InputDecoration(labelText: 'City'),
                ),
                new TextFormField(
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
                  decoration: InputDecoration(labelText: 'Contact'),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.0),
                  child: _isLoadingValue
                      ? ShowProgress()
                      : new RaisedButton(
                          onPressed: _submit,
                          child: Text('Signup'),
                        ),
                ),
                Container(
                  child: new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Login?',
                      style: TextStyle(color: lBlue50),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Home Autmation"),
      ),
      body: _isLoading ? ShowProgress() : _showRegisterForm,
    );
  }
}
