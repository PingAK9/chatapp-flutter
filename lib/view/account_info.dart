import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:chatapp/ui/utility/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account info'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _handleSignOut();
            },
          )
        ],
      ),
      body: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topCenter,
          child: buildItem(context, GameData.instance.user)),
    );
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController =
      new TextEditingController(text: GameData.instance.user.nickname);
  TextEditingController infoController =
      new TextEditingController(text: GameData.instance.user.info);

  Widget buildItem(BuildContext context, User user) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 200,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: avatarImageFile == null
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: user.photoUrl,
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                        )
                      : Image.file(
                          avatarImageFile,
                          fit: BoxFit.cover,
                        ),
                ),
                Container(
                  width: 120,
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          TextFormField(
            controller: nameController,
            style: Theme.of(context).textTheme.body2,
            maxLines: 1,
            decoration: InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'Name *',
            ),
            onSaved: (String value) {
              print('on save name');
              // This optional block of code can be used to run
              // code when the user saves the form.
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Username can not empty.';
              }
              return null;
            },
          ),
          TextFormField(
            controller: infoController,
            style: Theme.of(context).textTheme.body2,
            maxLines: 5,
            decoration: InputDecoration(
              icon: Icon(Icons.description),
              labelText: 'Bio',
            ),
            onSaved: (String value) {
              print('on save bio');
              // This optional block of code can be used to run
              // code when the user saves the form.
            },
            validator: (value) {
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (isLoading == false && _formKey.currentState.validate()) {
                  // Process data.
                  uploadFile();
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    height: 45,
                    width: 45,
                    padding: EdgeInsets.all(10),
                    child: isLoading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 1,
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  var isLoading = false;

  Future uploadFile() async {
    User user = GameData.instance.user.clone();
    user.nickname = nameController.text;
    user.info = infoController.text;
    setState(() {
      isLoading = true;
    });

    if (avatarImageFile != null) {
      upLoadAvatar(onComplete: (url) {
        user.photoUrl = url;
        updateUserInfo(user);
      }, onError: () {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload image fail'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      });
    } else {
      updateUserInfo(user)();
    }
  }

  updateUserInfo(user) {
    Firestore.instance
        .collection('users')
        .document(user.id)
        .updateData(user.toJson())
        .then((data) async {
      GameData.instance.user = user.clone();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload success'),
        ),
      );
      if (avatarImageFile != null) {
        avatarImageFile = null;
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((err) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
      setState(() {
        isLoading = false;
      });
    });
  }

  File avatarImageFile;

  upLoadAvatar({onComplete, onError}) async {
    String fileName = GameData.instance.user.id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    uploadTask.onComplete.then((value) {
      print('uploadTask.onComplete ${value.ref}');
      if (value.error == null) {
        value = value;
        value.ref.getDownloadURL().then((downloadUrl) {
          print('downloadUrl $downloadUrl');
          onComplete(downloadUrl);
        });
      } else {
        onError();
      }
    }, onError: (error) {
      onError();
    });
  }

  Future getImage(source) async {
    var image = await ImagePicker.pickImage(source: source, imageQuality: 50);

    setState(() {
      avatarImageFile = image;
    });
  }

  Future<Null> _handleSignOut() async {
    showLoading(context, message: "Logout");
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    hideLoading(context);

    Navigator.pushReplacementNamed(context, '/login');
  }

}
