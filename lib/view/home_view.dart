import 'package:chatapp/repository/value_update.dart';
import 'package:chatapp/view/account_info.dart';
import 'package:chatapp/view/contacts/contact_view.dart';
import 'package:chatapp/view/settings/setting_view.dart';
import 'package:chatapp/view/storys/story_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> homeTap = [
    ContactView(),
    StoryView(),
    SettingView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Provider<ValueUpdate<int>>(
      create: (_) => ValueUpdate(0),
      child: Consumer<ValueUpdate<int>>(
        builder: (context, value, child) {
          return ValueListenableProvider<int>.value(
            value: value.valueNotifier,
            child: Consumer<int>(
              builder: (context, index, child) {
                return WillPopScope(
                  onWillPop: () async {
                    value.valueNotifier.value = 0;
                    return false;
                  },
                  child: Scaffold(
                    body: homeTap.elementAt(index),
                    bottomNavigationBar: CupertinoTabBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Ionicons.ios_chatbubbles),
                          title: Text('Chats'),
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.burst_mode),
                          title: Text('Storys'),
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Ionicons.ios_settings),
                          title: Text('Settings'),
                        ),
                      ],
                      currentIndex: index,
                      onTap: (index) {
                        value.valueNotifier.value = index;
                      },
                      border : Border(
                        top: BorderSide(
                          color: Colors.grey,
                          width: 1.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
