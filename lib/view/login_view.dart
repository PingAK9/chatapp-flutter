import 'package:chatapp/repository/login_repository.dart';
import 'package:chatapp/ui/utility/my_snackbar.dart';
import 'package:chatapp/ui/utility/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        child: Center(
          child: RaisedButton(
            child: Text('Sign in with Google'),
            onPressed: () {
              _clickSignIn();
            },
          ),
        ),
      ),
    );
  }

  _clickSignIn() async {
    showLoading(context, message: "Check new Account");
    try {
      FirebaseUser user = await LoginRepository.handleSignIn();
      if (user != null) {
        await LoginRepository.checkNewUser(user);
        hideLoading(context);
        Navigator.pushReplacementNamed(context, '/home');
        return;
      } else {
        _scaffoldKey.currentState.showSnackBar(mySnackBar("Sign in fail"));
      }
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(mySnackBar("Sign in fail"));
    }
    hideLoading(context);
  }
}
