import 'package:chatapp/view/account_info.dart';
import 'package:chatapp/view/empty_view.dart';
import 'package:chatapp/view/home_view.dart';
import 'package:chatapp/view/init_view.dart';
import 'package:chatapp/view/login_view.dart';
import 'package:chatapp/view/message.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    /// add settings on MaterialPageRoute for which route you want to tracking
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => InitView(), settings: settings);
      case '/login':
        return MaterialPageRoute(
            builder: (_) => LoginView(), settings: settings);
      case '/home':
        return MaterialPageRoute(
            builder: (_) => HomeView(), settings: settings);
      case '/message':
        return MaterialPageRoute(
            builder: (_) => Message(settings.arguments), settings: settings);
      case '/account-info':
        return MaterialPageRoute(
            builder: (_) => AccountInfo(), settings: settings);
      default:
        return MaterialPageRoute(
            builder: (_) => EmptyView(title: settings.name));
    }
  }

  static String getNameExtractor(RouteSettings settings) {
    /// User for override route's name
    switch (settings.name) {
      case '/':
        return null;
      default:
        return settings.name;
    }
  }
}
