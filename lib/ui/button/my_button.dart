import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({@required this.child, @required this.onPressed, this.gradient});

  final Widget child;
  final VoidCallback onPressed;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withAlpha(50),
              offset: const Offset(1, 4),
              blurRadius: 3)
        ],
        gradient: gradient ??
            LinearGradient(
              colors: [
                Colors.orange[100],
                Colors.orange,
              ],
            ),
      ),
      child: FlatButton(
        shape: StadiumBorder(),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
