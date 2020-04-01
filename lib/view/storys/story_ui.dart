import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (_, user, child) {
        return Container(
          width: 100,
          height: 180,
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(user.photoUrl), fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 5,
                top: 5,
                width: 40,
                height: 40,
                child: ClipOval(
                  child: Image.network(user.photoUrl),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 5,
                right: 5,
                child: Text(
                  user.nickname,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
