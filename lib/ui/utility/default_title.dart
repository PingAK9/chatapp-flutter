import 'package:flutter/material.dart';

class DefaultTitle extends StatelessWidget {
  const DefaultTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    ;
  }
}
