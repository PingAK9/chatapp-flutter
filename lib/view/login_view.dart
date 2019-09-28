import 'package:chatapp/repository/login_repository.dart';
import 'package:chatapp/ui/progress_dialog.dart';
import 'package:chatapp/ui/ui_manager.dart';
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
    ProgressDialog loading =
        ProgressDialog(context, message: 'Check new \nAccount');
    loading.show();
    try {
      FirebaseUser user = await LoginRepository.handleSignIn();
      if (user != null) {
        await LoginRepository.checkNewUser(user);
        loading.hide();
        Navigator.pushReplacementNamed(context, '/home');
        return;
      } else {
        UIManager.showSnackBar(_scaffoldKey, 'Sign in fail');
      }
    } catch (e) {
      UIManager.showSnackBar(_scaffoldKey, 'Sign in fail');
    }
    loading.hide();
  }
}
