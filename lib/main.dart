import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/splash.dart';
import 'package:flash_chat/screens/welcome.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Constants.cameraDescription = (await availableCameras()).first;
  getLoggedInState();
}

void getLoggedInState() async {
  bool? userIsLoggedIn = await HelperFunctions.getUserLoggedInSharedPreference();
  String? id = await HelperFunctions.getUserIdSharedPreference();
  if (userIsLoggedIn != null && id != null)
    runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen()),
    );
  else
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    ),
    );
}
