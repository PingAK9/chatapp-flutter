import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:chatapp/ui/button/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final User user = GameData.instance.user;
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                  largeTitle: Text("Update Account"),
                  previousPageTitle: "Settings"),
              SliverPadding(
                padding: EdgeInsets.all(32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      height: 160,
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: showSheetPickImage,
                        child: Container(
                          width: 160,
                          height: 160,
                          padding: const EdgeInsets.all(15),
                          child: ClipOval(
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
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Name *',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Username can not empty.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: infoController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        labelText: 'Bio',
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    MyButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (isLoading == false &&
                            _formKey.currentState.validate()) {
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
                  ]),
                ),
              )
            ],
          )),
    );
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController =
      new TextEditingController(text: GameData.instance.user.nickname);
  TextEditingController infoController =
      new TextEditingController(text: GameData.instance.user.info);

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
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Upload image fail'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      });
    } else {
      updateUserInfo(user);
    }
  }

  updateUserInfo(user) {
    Firestore.instance
        .collection('users')
        .document(user.id)
        .updateData(user.toJson())
        .then((data) async {
      GameData.instance.user = user.clone();
      _scaffoldKey.currentState.showSnackBar(
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
      _scaffoldKey.currentState.showSnackBar(SnackBar(
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

  Future showSheetPickImage() async {
    return showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
              title: Text("Pick your images"),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.camera,
                        color: Colors.grey,
                      ),
                      Text("Camera"),
                      SizedBox(width: 24),
                    ],
                  ),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.image, color: Colors.grey),
                      Text("Gallery"),
                      SizedBox(width: 24),
                    ],
                  ),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ));
        });
  }

  Future getImage(source) async {
    var image = await ImagePicker.pickImage(source: source, imageQuality: 50);

    setState(() {
      avatarImageFile = image;
    });
  }
}
