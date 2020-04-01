import 'package:chatapp/repository/login_repository.dart';
import 'package:chatapp/ui/button/my_button.dart';
import 'package:chatapp/ui/utility/my_snackbar.dart';
import 'package:chatapp/ui/utility/pattern.dart';
import 'package:chatapp/ui/utility/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PatternBottomRight(),
          PatternBottomLeft(),
          PatternTop(),
          SafeArea(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please signin to continue.",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: FlatButton(
                            child: Text(
                              "FORGOT",
                              style: TextStyle(color: Colors.orange),
                            ),
                          )),
                    ),
                    const SizedBox(height: 32),
                    MyButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          const SizedBox(),
                          Text(
                            "Login".toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          )
                        ],
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: MyButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  MaterialCommunityIcons.google,
                                  color: Colors.white,
                                ),
                                Text('Google'.toUpperCase(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            onPressed: () {
                              _clickSignIn();
                            },
                            gradient: LinearGradient(colors: [
                              Colors.redAccent[100],
                              Colors.redAccent
                            ]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  MaterialCommunityIcons.facebook,
                                  color: Colors.white,
                                ),
                                Text('Facebook'.toUpperCase(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            onPressed: () {},
                            gradient: LinearGradient(
                                colors: [Colors.blue[100], Colors.blue]),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
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
