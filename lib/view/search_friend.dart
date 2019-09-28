import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:chatapp/provider/seach_provider.dart';
import 'package:chatapp/view/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchFriend extends StatefulWidget {
  @override
  _SearchFriendState createState() => _SearchFriendState();
}

class _SearchFriendState extends State<SearchFriend> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => SearchProvider('')),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: SearchInput(),
        ),
        body: Container(
          child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) {
                    return MultiProvider(
                      providers: [
                        Provider<User>.value(
                          value: User.fromJson(snapshot.data.documents[index]),
                        ),
                      ],
                      child: FriendItem(),
                    );
                  },
                  itemCount: snapshot.data.documents.length,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class SearchInput extends StatefulWidget {
  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  TextEditingController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: TextField(
              controller: controller,
              style: Theme
                  .of(context)
                  .textTheme
                  .body2
                  .merge(
                TextStyle(color: Colors.white),
              ),
              decoration: InputDecoration(
                icon: Container(
                  width: 35,
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  alignment: AlignmentDirectional.centerEnd,
                ),
                contentPadding: EdgeInsets.only(top: 1),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                hintText: 'Search Friend',
                hintStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (text) {
                Provider.of<SearchProvider>(context).setText(text);
              }),
        ),
        Container(
          alignment: AlignmentDirectional.center,
          width: 40,
          child: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                controller.text = '';
                Provider.of<SearchProvider>(context).setText('');
              });
            },
          ),
        ),
      ],
    );
  }
}

class FriendItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Consumer<User>(
      builder: (_, user, child) {
        var groupChatId = GameData.instance.user.groupChatID(user);

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/message', arguments: user);
          },
          child: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: new Border.all(
                color: Color(0xFFEDEDED),
                width: 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(15),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.nickname,
                        maxLines: 1,
                        style: Theme
                            .of(context)
                            .textTheme
                            .body2,
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
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return Text(
              'Say hi to your new friend',
              maxLines: 1,
              style: Theme
                  .of(context)
                  .textTheme
                  .body1,
            );
          } else {
            return snapshot.data.documents[0].data['type'] == messageType.text.index
                ? Text(
              snapshot.data.documents[0].data['content'],
              maxLines: 1,
              style: Theme
                  .of(context)
                  .textTheme
                  .body1,
            ): Icon(Icons.image);
          }
        }
      },
    );
  }
}
