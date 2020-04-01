
import 'package:chatapp/repository/seach_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchInput extends StatefulWidget {
  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  TextEditingController controller;

  @override
  void initState() {
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
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CupertinoTextField(
        controller: controller,
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        placeholder: "Search",
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            Icons.search,
            color: Colors.grey,
          ),
        ),
        suffix: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        ),
        onChanged: (text) {
          Provider.of<SearchProvider>(context).setText(text);
        },
      ),
    );
  }
}
