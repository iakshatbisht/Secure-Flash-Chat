import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/auth_controller.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/controller/secure_functions.dart';
import 'package:flash_chat/screens/profile/view_photo.dart';
import 'package:flash_chat/screens/user_chats/chat_user_settings.dart';
import 'package:flash_chat/screens/video_call/video_chat.dart';
import 'package:flash_chat/widget/loading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class Chat extends StatelessWidget {
  final String? peerId;
  final String? peerAvatar;
  final String? userName;
  final String? deviceToken;
  Chat({
    Key? key,
    this.peerId,
    this.peerAvatar,
    this.userName,
    this.deviceToken
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 9.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoChat()));
            },
          ),
        ],
        title: StreamBuilder(
          stream: AuthController().getConnectionStatus(peerId: peerId),
            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot){
              DocumentSnapshot<Map<String,dynamic>>? ref = snapshot.data;
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          ChatUserSettings(name: userName!, url: peerAvatar!, status: ref!.data()!["aboutMe"].toString())));
                },
                child: Row(
                  children: <Widget>[
                    Material(
                      child: peerAvatar != null
                          ? CachedNetworkImage(
                        //run this in ur
                        placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Constants.themeColor),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                        imageUrl: peerAvatar!,
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.contain,
                      )
                          : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Constants.greyColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: snapshot.data == null || snapshot == null ?
                      Text(
                        userName!,
                        style: TextStyle(
                            color: Constants.primaryColor, fontWeight: FontWeight.bold),
                      ) : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userName!,
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          if (ref!.data()!["connectionStatus"] != null)
                            Text(
                              ref.data()!["connectionStatus"],
                              style: TextStyle(
                                  color: Colors.green, fontSize: 14.0),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
        ),
      ),
      body: ChatScreen(
        peerId: peerId!,
        peerAvatar: peerAvatar!,
        deviceToken: deviceToken!
      ),
    );
  }

}

class ChatScreen extends StatefulWidget {
  final String? peerId;
  final String? peerAvatar;
  final String? deviceToken;
  ChatScreen({Key? key, this.peerId, this.peerAvatar, this.deviceToken})
      : super(key: key);
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  FirebaseMessaging _fc = FirebaseMessaging.instance;
  SecureFunctions? secureFunctions;
  String? mesgStatus;
  String? id;
  List<QueryDocumentSnapshot<Map<String,dynamic>>>? listMessage;
  String? groupChatId;
  File? imageFile;
  bool? isLoading;
  bool? isShowSticker;
  String? imageUrl;
  String chattingWith = "";
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    print("init of cht.drt");
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    secureFunctions = SecureFunctions();
    secureFunctions!.getKeys();
    focusNode.addListener(onFocusChange);
    readLocal();
    groupChatId = '';
    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    mesgStatus = "Delivered";
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    id = await HelperFunctions
        .getUserIdSharedPreference(); //prefs.getString('id') ?? '';
    if (id.hashCode <= widget.peerId.hashCode) {
      groupChatId = '$id-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$id';
    }
    chattingWith = id!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': widget.peerId});
    setState(() {});
  }

  Future getImage() async {
   /* PickedFile imgFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(imgFile.path != null ? imgFile.path : '');
    });

    if (imageFile.existsSync()) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }*/
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      print("isShowSticker = $isShowSticker");
      isShowSticker = ! isShowSticker!;
    });
  }

  uploadFile(){
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);
    TaskSnapshot storageTaskSnapshot = uploadTask.snapshot;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl!, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
        print("this file is not an image!");
      });
    });
  }

  void onSendMessage(String content, int type) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String? input = secureFunctions!.encryptMessage(content);

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId!)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      await FirebaseFirestore.instance.runTransaction((transaction) async {
         transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': widget.peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': input,
            'type': type,
            'isSeen': 'Delivered'
          },
        );
      });

      // print("receiver's token :- ${widget.deviceToken}");
       //sendNotificationToUser(widget.deviceToken!,content);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print("Nothing to send on line 263");
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    var mq = MediaQuery.of(context).size;
    String content = secureFunctions!.decryptMessage(document['content']!);
    if (document['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          content,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document['timestamp']))),
                                style: TextStyle(
                                    color: Constants.greyColor,
                                    fontSize: 10.0,
                                    fontStyle: FontStyle.italic),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection('users').doc(widget.peerId).snapshots(),
                                  builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot) {
                                    if (snapshot.hasData &&
                                        !snapshot.hasError) {
                                      Map<String,dynamic>? dy = snapshot.data!.data();
                                      print("text chats......."+widget.peerId!+" " +dy!['chattingWith'].toString()+" "+id!);
                                      print(dy.toString());
                                      if (dy['chattingWith'].toString().contains(id!)) {
                                        FirebaseFirestore.instance
                                            .collection('messages')
                                            .doc(groupChatId)
                                            .collection(groupChatId!)
                                            .doc(document.id)
                                            .update({'isSeen': 'Read'});
                                      } else
                                        mesgStatus = 'Delivered';
                                      return Icon(
                                        Icons.done_all,
                                        color: document['isSeen'] == 'Read'
                                            ? Colors.blue
                                            : Constants.greyColor,
                                      );
                                    }
                                    return Container(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }),
                              SizedBox(
                                width: 3,
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: 5.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: mq.width / 2,
                  decoration: BoxDecoration(
                      /*gradient: LinearGradient(
                        colors: [Colors.deepPurpleAccent.withOpacity(0.5),Colors.deepPurpleAccent ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter
                      ),*/
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      color: Colors.deepPurpleAccent
                          .withOpacity(0.8), //Colors.deepPurple
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 20.0,
                            offset: Offset(10, 10),
                            color: Colors.black54)
                      ]),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 2
          // Sticker
                  ? StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.peerId).snapshots(),
              builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot) {
                if (snapshot.hasData &&
                    !snapshot.hasError) {
                  Map<String,dynamic>? dy = snapshot.data!.data();
                  print("text chats......."+ dy.toString());
                  print(dy.toString());
                  if (dy!["chattingWith"].toString().contains(id!)) {
                    FirebaseFirestore.instance
                        .collection('messages')
                        .doc(groupChatId)
                        .collection(groupChatId!)
                        .doc(document.id)
                        .update({'isSeen': 'Read'});
                  } else {
                    mesgStatus = 'Delivered';
                  }
                  return Container(
                    child: Image.asset(
                      'assets/images/${content}.gif',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  );
                }
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              })
          // Image
                  : Container(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          MaterialButton(
                            padding: EdgeInsets.all(0.0),
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Constants.themeColor),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: Constants.greyColor2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: content,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PhotoViewer(url: content)));
                            },
                            //padding: EdgeInsets.all(8),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    DateFormat('dd MMM kk:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(document['timestamp']))),
                                    style: TextStyle(
                                        color: Constants.greyColor,
                                        fontSize: 10.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection('users').doc(widget.peerId).snapshots(),
                                      builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot) {
                                        if (snapshot.hasData &&
                                            !snapshot.hasError) {
                                          Map<String,dynamic>? dy = snapshot.data!.data();
                                          print(dy.toString());
                                          if (dy!['chattingWith'].toString().contains(id!)) {
                                            FirebaseFirestore.instance
                                                .collection('messages')
                                                .doc(groupChatId)
                                                .collection(groupChatId!)
                                                .doc(document.id)
                                                .update({'isSeen': 'Read'});
                                          } else
                                            mesgStatus = 'Delivered';
                                          return Icon(
                                            Icons.done_all,
                                            color: document['isSeen'] == 'Read'
                                                ? Colors.blue
                                                : Constants.greyColor,
                                          );
                                        }
                                        return Container(
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }),
                                  SizedBox(
                                    width: 3,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(
                                top: 5.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        color: Colors.deepPurpleAccent
                            .withOpacity(0.8), //Colors.deepPurple
                      ),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Row(
          children: <Widget>[
            isLastMessageLeft(index)
                ? Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Constants.themeColor),
                        ),
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl: widget.peerAvatar!,
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  )
                : Container(width: 35.0),
            document['type'] == 0
                ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          content,
                          style: TextStyle(color: Colors.white),
                        ),
                        //isLastMessageLeft(index)
                        Container(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(document['timestamp']))),
                              style: TextStyle(
                                  color: Constants.greyColor,
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          margin: EdgeInsets.only(
                            top: 5.0,
                          ),
                        )
                        //: Container()
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: mq.width / 2,
                    decoration: BoxDecoration(
                        /*gradient: LinearGradient(
                          colors: [Color(0xff8a2be2).withOpacity(0.5), Color(0xff8A2BE2)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),*/
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        color: Colors.deepPurple.withOpacity(0.8),
                        //Color(0xffA67CFA),Color(0xff4AAEA4),Color(0xff52C7B0),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 20.0,
                              offset: Offset(10, 10),
                              color: Colors.black54),
                        ]),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0,
                        left: 5.0),
                  )
                : document['type'] == 1
                    ? Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            MaterialButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Constants.themeColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Constants.greyColor2,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: content,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoViewer(
                                            url: content)));
                              },
                              padding: EdgeInsets.all(8),
                            ),
                            /*isLastMessageLeft(index)
                                ?*/
                            Container(
                              child: Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document['timestamp']))),
                                style: TextStyle(
                                    color: Constants.greyColor,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                              margin: EdgeInsets.only(
                                  right: 15, top: 2.0, bottom: 5.0),
                            )
                          ],
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                        decoration: BoxDecoration(
                          /*gradient: LinearGradient(
                            colors: [kPrimaryLightColor.withOpacity(0.5), kPrimaryLightColor],
                          begin: Alignment.topCenter,
                          ),*/
                          color: Colors.deepPurple.withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          //color: kPrimaryLightColor.withOpacity(0.5),
                        ),
                      )
                    : Container(
                        child: Image.asset(
                          'assets/images/${content}.gif',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage![index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage![index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker != null && isShowSticker == true) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'chattingWith': ""});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              // Sticker
              (isShowSticker! ? buildSticker() : Container()),
              // Input content
              buildInput(),
            ],
          ),
          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              MaterialButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              MaterialButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              MaterialButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              MaterialButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              MaterialButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              MaterialButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              MaterialButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              MaterialButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              MaterialButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Constants.greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading! ? Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                    icon: Icon(Icons.perm_media), onPressed: showBtmSheet)),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Constants.primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Constants.greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Constants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Constants.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId! == '' || chattingWith == null
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Constants.themeColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId!)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {
                print("aaa gyiii chats:- .....$chattingWith");
                if (!snapshot.hasData || chattingWith != id) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Constants.themeColor)));
                } else {
                  listMessage = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data!.docs[index]),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
  void showBtmSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: (context),
        builder: (context) {
          return Container(
            height: 100,
            child: Row(
              children: <Widget>[
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.camera_enhance),
                      onPressed: () {
                        Navigator.pop(context);
                        openCamera();
                      },
                      color: Constants.primaryColor,
                    ),
                  ),
                  color: Colors.white,
                ),
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        Navigator.pop(context);
                        getImage();
                      },
                      color: Constants.primaryColor,
                    ),
                  ),
                  color: Colors.white,
                ),
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.face),
                      onPressed: () {
                        Navigator.pop(context);
                        getSticker();
                      },
                      color: Constants.primaryColor,
                    ),
                  ),
                  color: Colors.white,
                ),
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.audiotrack),
                      onPressed: () {},
                      color: Constants.primaryColor,
                    ),
                  ),
                  color: Colors.white,
                ),
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.contacts),
                      onPressed: () {},
                      color: Constants.primaryColor,
                    ),
                  ),
                  color: Colors.white,
                ),
              ],
            ),
          );
        });
  }

  void openCamera() async {
    /*PickedFile imgFile =
        await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      imageFile = File(imgFile.path != null ? imgFile.path : '');
    });

    if (imageFile.existsSync()) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }*/
  }

 /* sendNotificationToUser(String pushToken, String content) async{
    String? myName = await HelperFunctions.getUserNameSharedPreference();
    *//*Map<String, dynamic> message = {
      "title": myName,
      "body": content
    };*//*
    try{
      var response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type' :' application/json',
            'Authorization': 'key='+Constants.PROJECT_SERVER_KEY
          },
          body: jsonEncode({
            "notification": jsonEncode({
              "title": myName,
              "body": content
            }),
            "to": pushToken,
            "collapse_key" : myName,
            "priority": "high",
          }));
      print("message delivered");
      return true;
    }catch(error){
        print("message failed to reach user");
    }
  }*/
}
