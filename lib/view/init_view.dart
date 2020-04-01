import 'dart:async';

import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/repository/login_repository.dart';
import 'package:chatapp/ui/utility/pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class InitView extends StatefulWidget {
  @override
  _InitViewState createState() => _InitViewState();
}

class _InitViewState extends State<InitView> {
  @override
  void initState() {
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PatternBottomRight(),
          PatternBottomLeft(),
          PatternTop(),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: 128,
                child: Image.asset("assets/images/ui/chat-icon.png")),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            height: 40,
            child: Center(
              child: CupertinoActivityIndicator(
                radius: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
