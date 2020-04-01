import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:chatapp/repository/seach_provider.dart';
import 'package:chatapp/ui/utility/default_title.dart';
import 'package:chatapp/view/contacts/contact_ui.dart';
import 'package:chatapp/ui/utility/search_input.dart';
import 'package:chatapp/view/storys/story_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryView extends StatefulWidget {
  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider('')),
      ],
      child: CupertinoPageScaffold(
        child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              return CustomScrollView(
                slivers: <Widget>[
                  CupertinoSliverNavigationBar(
                    middle: Text("Story"),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    largeTitle: SearchInput(),
                  ),
                  _buildData(snapshot),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildData(snapshot) {
    if (!snapshot.hasData) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(10.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                height: 180,
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    const SizedBox(width: 20),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                NetworkImage(GameData.instance.user.photoUrl),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              left: 5, top: 5, child: Icon(Icons.add_circle)),
                          Positioned(
                            bottom: 10,
                            left: 5,
                            right: 5,
                            child: Text(
                              "Add to story",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    for (final document in snapshot.data.documents)
                      Provider<User>.value(
                        value: User.fromJson(document),
                        child: StoryUI(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: DefaultTitle("Recently".toUpperCase()),
              ),
              for (final document in snapshot.data.documents)
                Provider<User>.value(
                  value: User.fromJson(document),
                  child: ContactUI(),
                ),
            ],
          ),
        ),
      );
    }
  }
}
