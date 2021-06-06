import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/controller/secure_functions.dart';
import 'package:flash_chat/screens/profile/follower_profile.dart';
import 'package:flash_chat/screens/user_chats/chat.dart';
import 'package:flash_chat/widget/flash_chat.dart';
import 'package:flash_chat/widget/home/sos_fab.dart';
import 'package:flash_chat/widget/loading.dart';
import 'package:flash_chat/widget/menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String? currentUserId;
  HomeScreen({Key? key, this.currentUserId}) : super(key: key);
  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  double? height, width, textFactor;
  String? connectionStatus;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  SecureFunctions? secureFunction;
  DateTime? currentBackPressTime;
  List<String> chtIds = [];
  List<String> timeIds = [];
  String person = "", userPhtotoUrl = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    getFromSharedPrefs();
    gettingTime();
    secureFunction = SecureFunctions();
    secureFunction!.getKeys();
    registerNotification();
    configLocalNotification();
  }

  void getFromSharedPrefs() async {
    person = (await HelperFunctions.getUserNameSharedPreference())!;
    userPhtotoUrl = (await HelperFunctions.getUserPhotoUrlSharedPreference())!;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("State in home:- $state");
    if (state == AppLifecycleState.resumed) {
      connectionStatus = 'Online';
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused)
      connectionStatus = 'Offline';
    else {
      connectionStatus = 'Offline';
    }
    print("mounted $mounted");
    if(mounted) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({'connectionStatus': connectionStatus}).whenComplete(() => setState(() {
        print("called due to offline/online");
      })).onError((error, stackTrace) => print("error ${error.toString()}"));

    }
  }

  void gettingTime() async {
    await FirebaseFirestore.instance.collection('users').snapshots().forEach((element) {
      List<DocumentSnapshot> liss = element.docs;
      for (DocumentSnapshot dd in liss) {
        if (dd.id != widget.currentUserId) {
          if (chtIds.length != 0)
            chtIds.add(
                '${widget.currentUserId.toString()}-${dd.id.toString()}');
        }
      }
    });
  }

  void registerNotification() async{
    NotificationSettings? sett = await firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Platform.isAndroid
          ? showNotification(message.data['notification'])
          : showNotification(message.data['aps']['alert']);
    });
    /**/
    /*firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message.['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    });*/

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({'pushToken': token});
    }).catchError((err) {
      print("home.dart Line 129 error :- ${err.toString()}");
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.food.chatsakki' : "",
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableLights: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
    );
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentAlert: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin!.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    textFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width / 6,
                width: MediaQuery.of(context).size.width,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.only(left: 30),
                  child: FlashChat(),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              widget.currentUserId != null
                  ? WillPopScope(
                      child: Container(
                        padding: EdgeInsets.all(0.0),
                        //can be done after pplying state management
                        /*showRail == true ? EdgeInsets.only(
                      left: MediaQuery.of(context).size.width /
                          6) : EdgeInsets.all(0.0),*/
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.currentUserId).snapshots(),
                          builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                            print("home.dart Line 211 :- Nothin ${widget.currentUserId}");
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Center(
                                child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      'No Contacts',
                                      textScaleFactor: 1.3,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              DocumentSnapshot<Map<String,dynamic>>? dat = snapshot.data;
                              print("home.dart Line 226 ${dat!.data()}");
                              List<dynamic>? followList = snapshot.data!.data()!['followers'];
                              if (followList != null && followList.isNotEmpty)
                                return ListView.builder(
                                  padding: EdgeInsets.all(10.0),
                                  itemBuilder: (context, index) => buildItem(context, followList[index], index),
                                  itemCount: followList.length,
                                  shrinkWrap: true,
                                );
                              else
                                return Container(
                                  height: height! / 2,
                                  child: Center(
                                    child: Text(
                                      'No friends',
                                      textScaleFactor: 2,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                            }
                          },
                        ),
                      ),
                      onWillPop: onWillPop,
                    )
                  : Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            'Network Issue. Kindly re-login',
                            textScaleFactor: 1.3,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
          MenuBar(
              userName: person,
              userPhotoUrl: userPhtotoUrl,
              userId: widget.currentUserId),
          Positioned(
            child: isLoading ? Loading() : Container(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SOSFab(),
    );
  }


  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      print("Press once again to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget buildItem(BuildContext context, dynamic followId, index) {
    String? chatId;
    print(followId.toString());
    if (followId.toString().hashCode <= widget.currentUserId.hashCode) {
      chatId = followId.toString() + "-" + widget.currentUserId!;
    } else
      chatId = widget.currentUserId! + "-" + followId.toString();
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(followId.toString())
          .snapshots(),
      builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshotUser) {
        if (snapshotUser.hasData) {
          DocumentSnapshot<Map<String,dynamic>>? document = snapshotUser.data;
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatId!)
                  .collection(chatId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  QuerySnapshot<Map<String,dynamic>>? dtum = snapshot.data;
                  String message = "";
                  String talkingTo = person;
                  List<DocumentSnapshot> listMessage = dtum!.docs;
                  String lastDate = "";
                  bool isSeen = false;
                  int totalUnseenMessage = 0;
                  for (DocumentSnapshot d in listMessage) {
                    lastDate = DateFormat.jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(d.id.toString())));
                    if (d['idFrom'].toString() != widget.currentUserId) {
                      talkingTo = document!['nickname']
                          .toString()
                          .split(" ")
                          .elementAt(0);
                      if (d['isSeen'].toString() != "Read") {
                        isSeen = true;
                        totalUnseenMessage++;
                      } else
                        isSeen = false;
                    } else
                      talkingTo = person.toString().split(" ").elementAt(0);
                    /*
                  0   text
                  1   img
                  2   gif
                  3   video
                  4   audio
                  */
                    switch (d['type'].toString()) {
                      case '0':
                        message =
                            talkingTo + ": " + secureFunction!.decryptMessage(d['content'].toString());
                        break;
                      case '1':
                        message = '$talkingTo: Photo';
                        break;
                      case '2':
                        message = '$talkingTo: GIF';
                        break;
                      default:
                        message = '';
                    }
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Chat(
                                    peerId: document!.id,
                                    peerAvatar: document.data()!['photoUrl'],
                                    //connectionStatus: document['connectionStatus'],
                                    userName: document['nickname'],
                                    deviceToken: document['pushToken'],
                                  )));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: document!.data()!['photoUrl'] != null
                                ? GestureDetector(
                              onTap: () => Navigator.push(context, HeroDialogRoute(builder: (context) {
                                return FollowerProfile(detail: document);
                              },)),
                                  child: Hero(
                                      tag: document.id,
                                      child: CachedNetworkImage(
                                        imageUrl: document.data()!['photoUrl'],
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          width: 55.0,
                                          height: 55.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                )
                                : Icon(
                                    Icons.account_circle,
                                    size: 60.0,
                                    color: Constants.greyColor,
                                  ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${document.data()!['nickname'][0].toUpperCase()}${document.data()!['nickname'].substring(1)}',
                                  textScaleFactor: 1.2,
                                  style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  lastDate,
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                        color:
                                            isSeen ? Colors.black : Colors.grey,
                                        fontWeight: isSeen
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ),
                                totalUnseenMessage > 0
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          totalUnseenMessage.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1.2,
                            height: 5,
                            indent: 80,
                          )
                        ],
                      ),
                    ),
                  );
                } else
                  return Container();
              });
        } else
          return Container(
            child: Center(
              child: Text(
                'fetching Results.....',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
      },
    );
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({ this.builder }) : super();
  final WidgetBuilder? builder;
  @override
  bool get opaque => false;
  @override
  bool get barrierDismissible => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  @override
  bool get maintainState => true;
  @override
  Color get barrierColor => Colors.black54;
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut
        ),
        child: child
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder!(context);
  }

  @override
  String get barrierLabel => "Profile Info";

}