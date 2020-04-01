import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/core/utility.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:chatapp/ui/utility/default_title.dart';
import 'package:chatapp/ui/utility/progress_dialog.dart';
import 'package:chatapp/ui/utility/search_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SettingView extends StatefulWidget {
  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            middle: Text("Settings"),
            largeTitle: SearchInput(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildAccount(),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: DefaultTitle('Account information'.toUpperCase()),
              ),
              _buildItemCommon('Saved Messages',
                  icon: Icons.supervisor_account, onTap: () {}),
              _buildItemCommon(
                'Recent Calls',
                icon: MaterialCommunityIcons.file_document,
              ),
              _buildItemCommon('Devices',
                  icon: MaterialCommunityIcons.map_marker_radius, onTap: () {}),
              _buildItemCommon('Chat Folders',
                  icon: MaterialCommunityIcons.clipboard_text, hasLine: false),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: DefaultTitle('Settings'.toUpperCase()),
              ),
              _buildItemCommon('Notifications and Sounds',
                  icon: Icons.alarm, color: Colors.green, onTap: () {}),
              _buildItemCommon('Privacy and Security',
                  icon: Icons.lock_outline, color: Colors.green, onTap: () {}),
              _buildItemCommon('Data and Storage',
                  icon: Icons.storage, color: Colors.green, onTap: () {}),
              _buildItemCommon('Appearance',
                  icon: Icons.phone_android, color: Colors.green, onTap: () {}),
              _buildItemCommon('Language',
                  icon: Icons.language, color: Colors.green, onTap: () {}),
              _buildItemCommon('Stickers',
                  icon: Icons.mood,
                  color: Colors.green,
                  hasLine: false,
                  onTap: () {}),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: DefaultTitle('Suports'.toUpperCase()),
              ),
              _buildItemCommon('Hotline: 1234567890',
                  icon: MaterialCommunityIcons.phone_classic,
                  color: Colors.orange,
                  onTap: () {}),
              _buildItemCommon('Ask a Question',
                  icon: Icons.email, color: Colors.orange, onTap: () {}),
              _buildItemCommon('FAQs',
                  icon: MaterialCommunityIcons.comment_question,
                  color: Colors.orange,
                  onTap: () {}),
              _buildItemCommon(
                'About App Chat',
                icon: Icons.info,
                hasLine: false,
                color: Colors.orange,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlineButton(
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: _onLogout,
                ),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text('Version: 5.3.0+2'),
              ),
              const SizedBox(height: 30)
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCommon(String title,
      {IconData icon,
      Color color = Colors.blue,
      GestureTapCallback onTap,
      bool hasLine = true}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: hasLine
                ? Border(
                    bottom: BorderSide(
                        width: 1, color: Theme.of(context).dividerColor),
                  )
                : null,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.left,
                      ))),
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.blue,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccount() {
    final User user = GameData.instance.user;
    return InkWell(
      onTap: () async {
        Navigator.pushNamed(context, "/account-info");
      },
      child: Container(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(16),
              width: 50,
              height: 50,
              child: ClipOval(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: user.photoUrl,
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.nickname,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isNullOrEmpty(user.info)
                          ? "Update your information"
                          : user.info,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _onLogout() async {
    showLoading(context, message: "Logout");
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    hideLoading(context);

    Navigator.pushReplacementNamed(context, '/login');
  }
}
