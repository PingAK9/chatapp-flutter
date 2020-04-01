import 'package:chatapp/model/user_info.dart';
import 'package:chatapp/repository/seach_provider.dart';
import 'package:chatapp/view/contacts/contact_ui.dart';
import 'package:chatapp/ui/utility/search_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactView extends StatefulWidget {
  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
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
                    middle: Text("Contacts"),
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
              _buildTitleButton(
                  title: "Find People Nearby", icon: Icons.location_on),
              _buildDivider(),
              _buildTitleButton(title: "Invite Friends", icon: Icons.group_add),
              _buildDivider(),
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

  Widget _buildTitleButton({String title, IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
            width: 40, height: 46, child: Icon(icon, color: Colors.blueAccent)),
        Text(
          title,
          style: TextStyle(color: Colors.blueAccent),
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(left: 40),
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
