import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SOSFab extends StatefulWidget {
  const SOSFab({Key? key}) : super(key: key);

  @override
  _SOSFabState createState() => _SOSFabState();
}

class _SOSFabState extends State<SOSFab> with SingleTickerProviderStateMixin{
  Animation? animation;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller =  AnimationController(
        duration: Duration(seconds: 2),
        vsync: this
    );
    controller!.addListener(() {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(angle: controller!.value * pi,
      child: FloatingActionButton(
        backgroundColor: Constants.kPrimaryColor,
        child: Text(
          "SOS",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if(controller!.isCompleted)
            controller!.reverse();
          else
            controller!.forward();
          String? myId = await HelperFunctions.getUserIdSharedPreference();
          List<String> pushTokens = [];
          await FirebaseFirestore.instance
              .collection('users')
              .doc(myId)
              .get()
              .then((value) {
            Map<String,dynamic>? myFollowers = value.data();
            print(myFollowers.toString());
            myFollowers!["followers"].forEach((element) async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(element.toString())
                  .get()
                  .then((val) {
                print(val.data()!['pushToken']);
                String? x = val.data()!['pushToken'].toString();
                pushTokens.add(x);
              });
            });
          });
          print(pushTokens);
          await sendSOSNotification(pushTokens);
        },
      ),
    );
  }
  Future<bool> sendSOSNotification(List<String> pushTokens) async {
    String? myName = await HelperFunctions.getUserNameSharedPreference();
    try {
      print(" my follower ids = $pushTokens");
      var response = await http.post(Uri.parse('http://localhost:2552'),
          body: jsonEncode({
            "for": "SOS",
            "nickname": myName,
            "content": "",
            "pushTokens": pushTokens
          }));
      return true;
    } catch (error) {
      print("message failed to reach user");
    }
    return false;
  }
}
