import 'dart:async';

import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/repository/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class InitView extends StatefulWidget {
  @override
  _InitViewState createState() => _InitViewState();
}

class _InitViewState extends State<InitView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      new Timer(Duration(microseconds: 200), () {
        checkLogin();
      });
    });
  }

  checkLogin() async {
    try {
      FirebaseUser user = await LoginRepository.handleSignIn(silently: true);
      if (user != null) {
        await LoginRepository.checkNewUser(user);
        Navigator.pushReplacementNamed(context, '/home');
        return;
      } else {}
    } catch (e) {}
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white12,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}
