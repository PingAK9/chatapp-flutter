import 'package:chatapp/model/user_info.dart';
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();

class GameData{
  static final GameData instance = GameData._internal();

  factory GameData() {
    return instance;
  }

  GameData._internal() {
    // init things inside this
    user = null;
  }

  User user;

}