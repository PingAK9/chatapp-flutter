
import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {

  String _text;
  SearchProvider(this._text);

  getText() => _text;

  void setText(String value)
  {
    _text = value;
    notifyListeners();
  }
}