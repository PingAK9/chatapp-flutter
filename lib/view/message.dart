import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/core/game_data.dart';
import 'package:chatapp/model/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/model/message.dart';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();

  Message(this.friend);

  final User friend;
}

class _MessageState extends State<Message> {
  User friend;
  User user;
  final background = Colors.black12;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friend = widget.friend;
    user = GameData.instance.user;
    groupChatId = user.groupChatID(friend);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Message'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: background,
                child: buildListMessage(context),
              ),
            ),
            currentImage == null
                ? Container()
                : Container(
                    color: background,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: 60,
                    child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 40,
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            ),
                            Text('Upload image ...'),
                          ],
                        )
                    ),
                  ),
            buildInput(context),
          ],
        ),
      ),
    );
  }

  Future<bool> onBackPress() {
    return Future.value(true);
  }

  TextEditingController textEditingController = new TextEditingController();

  buildInput(context) {
    return Container(
      height: 50,
      width: double.infinity,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.photo,
              color: Colors.black87,
            ),
            onPressed: () {
              getImage(ImageSource.gallery);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.camera,
              color: Colors.black87,
            ),
            onPressed: () {
              getImage(ImageSource.camera);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.face,
              color: Colors.black87,
            ),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 1),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                hintText: 'Type your message.',
              ),
              onChanged: (text) {},
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.black87,
            ),
            onPressed: () {
              onSendMessage(textEditingController.text, MessageType.text);
            },
          ),
        ],
      ),
    );
  }

  var groupChatId;
  var listScrollController;

  buildListMessage(context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          var listMessage = snapshot.data.documents;
          return ListView.builder(
            itemBuilder: (context, index) {
              return buildItem(index, listMessage[index]);
            },
            itemCount: listMessage.length,
            reverse: true,
            controller: listScrollController,
          );
        }
      },
    );
  }

  var currentImage;

  Future getImage(source) async {
    var image = await ImagePicker.pickImage(source: source, imageQuality: 50);
    setState(() {
      currentImage = image;
    });
    if (currentImage != null) {
      upLoadImage(
        currentImage,
        onComplete: (url) {
          setState(() {
            currentImage = null;
          });
          onSendMessage(url, MessageType.image);
        },
        onError: () {
          setState(() {
            currentImage = null;
          });
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload image fail!'),
            ),
          );
        },
      );
    }
  }

  upLoadImage(image, {onComplete, onError}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(image);
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        value = value;
        value.ref.getDownloadURL().then((downloadUrl) {
          onComplete(downloadUrl);
        });
      } else {
        onError();
      }
    }, onError: (error) {
      onError();
    });
  }

  void onSendMessage(String content, MessageType type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': GameData.instance.user.id,
            'idTo': widget.friend.id,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type.index
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {}
  }

  buildItem(index, DocumentSnapshot data) {
    print(data.data);
    User own = user;
    bool current = true;
    if (data.data['idFrom'] == friend.id) {
      own = friend;
      current = false;
    }
    List<Widget> children = new List();
    var avatar = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: own.photoUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => new Icon(Icons.error),
        ),
      ),
    );
    var message = Expanded(
      flex: 1,
      child: Container(
        alignment: current ? Alignment.centerRight : Alignment.centerLeft,
        child: buildItemData(data),
      ),
    );

    if (current) {
      children.add(message);
      children.add(avatar);
    } else {
      children.add(avatar);
      children.add(message);
    }

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: children,
      ),
    );
  }

  buildItemData(DocumentSnapshot data) {
    var type = MessageType.values[int.parse(data.data['type'].toString())];

    switch (type) {
      case MessageType.image:
        return Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.all(10),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: data.data['content'],
            placeholder: (BuildContext context, String url) {
              return Container(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                ),
              );
            },
            errorWidget: (context, url, error) => new Icon(Icons.error),
          ),
        );
        break;
      case MessageType.sticker:
        break;
      default:
        return Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.black.withAlpha(50),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Text(data.data['content'] ?? ''));
        break;
    }
  }
}

