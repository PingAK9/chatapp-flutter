import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginRepository {
  static Future<FirebaseUser> handleSignIn({bool silently = false}) async {

    GoogleSignInAccount googleUser;
    if (silently) {
      googleUser = await googleSignIn.signInSilently();
    } else {
      googleUser = await googleSignIn.signIn();
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    return user;
  }

  static checkNewUser(FirebaseUser user) async {
    // Check is already sign up
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments();

    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      Firestore.instance.collection('users').document(user.uid).setData({
        'nickname': user.displayName,
        'photoUrl': user.photoUrl,
        'id': user.uid
      });
      GameData.instance.user = User(
          nickname: user.displayName,
          photoUrl: user.photoUrl,
          id: user.uid,
          info: '');
    } else {
      GameData.instance.user = User.fromJson(documents[0].data);
    }
  }
}
