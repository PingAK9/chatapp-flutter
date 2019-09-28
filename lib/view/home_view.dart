import 'package:chatapp/provider/value_update.dart';
import 'package:chatapp/view/account_info.dart';
import 'package:chatapp/view/search_friend.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = new TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ValueUpdate<int>>(
      builder: (_) => ValueUpdate(0),
      child: Consumer<ValueUpdate<int>>(
        builder: (context, value, child) {
          return WillPopScope(
            onWillPop: () async {
              if (tabController.index != 0) {
                tabController.animateTo(0);
              }
              value.valueNotifier.value = 0;
              return false;
            },
            child: Scaffold(
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: <Widget>[
                  SearchFriend(),
                  AccountInfo(),
                ],
              ),
              bottomNavigationBar: ValueListenableProvider<int>.value(
                value: value.valueNotifier,
                child: Consumer<int>(builder: (context, index, child) {
                  return BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_box),
                        title: Text('Friends'),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_box),
                        title: Text('Account'),
                      ),
                    ],
                    currentIndex: index,
                    selectedItemColor: Colors.amber[800],
                    onTap: (int index) {
                      value.valueNotifier.value = index;
                      tabController.animateTo(index);
                    },
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
