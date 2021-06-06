import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/home/home.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  String? id,connectionStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    id = "";
    connectionStatus = "";
    startTime();
  }
  Future<Timer> startTime() async{
    id = await HelperFunctions.getUserIdSharedPreference();
    Duration _duration = Duration(seconds: 2);
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'connectionStatus': 'Online'});
    return Timer(_duration, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: id,))));
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        child: Center(
          child: Hero(tag: 'logo', child: Image.asset("assets/images/logo.png",),),
        ),
      ),
    );
  }
}
