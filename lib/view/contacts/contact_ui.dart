import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/model/message.dart';

class ContactUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (_, user, child) {
        var groupChatId = GameData.instance.user.groupChatID(user);

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/message', arguments: user);
          },
          child: Container(
            decoration: BoxDecoration(
              border: new Border(
                  bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
                style: BorderStyle.solid,
              )),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(6),
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: user.photoUrl,
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        user.nickname,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.body2,
                      ),
                      buildMessage(context, groupChatId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  buildMessage(context, groupChatId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 24,
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return Text(
              'Say hi to your new friend',
              maxLines: 1,
              style: TextStyle(fontSize: 12),
            );
          } else {
            return snapshot.data.documents[0].data['type'] ==
                    MessageType.text.index
                ? Text(
                    snapshot.data.documents[0].data['content'],
                    maxLines: 1,
                    style: TextStyle(fontSize: 12),
                  )
                : Icon(Icons.image);
          }
        }
      },
    );
  }
}
