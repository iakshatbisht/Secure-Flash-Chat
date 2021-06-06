import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/auth_controller.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/auth/signup_screen.dart';
import 'package:flash_chat/screens/home/home.dart';
import 'package:flash_chat/widget/authentication_components/already_have_an_account_acheck.dart';
import 'package:flash_chat/widget/authentication_components/rounded_button.dart';
import 'package:flash_chat/widget/authentication_components/rounded_input_field.dart';
import 'package:flash_chat/widget/authentication_components/rounded_password_field.dart';
import 'package:flash_chat/widget/login_components/background.dart';
import 'package:flash_chat/widget/signup_components/or_divider.dart';
import 'package:flash_chat/widget/signup_components/social_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  //final FacebookLogin facebookLogin = FacebookLogin();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? currentUser;
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  bool isLoading = false;
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    isSignedIn();
  }
  void isSignedIn() async {
   this.setState(() {
      isLoading = true;
    });
   String? id = await HelperFunctions.getUserIdSharedPreference();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: id)),
      );
    }
    this.setState(() {
      isLoading = false;
    });
  }
  Future<Null> handleSignIn() async{
    try{
      User? firebaseUser = await AuthController().signInWithEmailAndPassword(emailEditingController.text, passwordEditingController.text);
      if(firebaseUser != null){
        print("Sign in success");
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      } else {
        this.setState(() {
          isLoading = false;
        });
       print("User doesn\'t exist");
      }
    }catch (e) {
      this.setState(() {
        isLoading = false;
      });
      print("Sign in fail");
    }
  }
  Future<Null> handleGoogleSignIn() async {
    //prefs = await SharedPreferences.getInstance();
    try {
      User firebaseUser = await AuthController().signInWithGoogle(context);
      if(firebaseUser != null){
        print("Sign in success");
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      } else {
         this.setState(() {
           isLoading = false;
         });
         print("User doesn\'t exist");
      }
    } catch (e) {
      this.setState(() {
        isLoading = false;
      });
      print("Sign in fail");
      print("error thrown in login page is :   ${e.toString()}");
    }
  }
  Future<Null> handleTwitterSignIn() async {
    try {
      User? firebaseUser = await AuthController().signInWithTwitter(context);
      if(firebaseUser != null){
        print("Sign in success");
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      } else {
        this.setState(() {
          isLoading = false;
        });
       print("Sign in fail");
      }
    } catch (e) {
      this.setState(() {
        isLoading = false;
      });
      //Fluttertoast.showToast(msg: "Sign in fail", backgroundColor: kPrimaryColor,textColor: kPrimaryLightColor);
      print("error thrown in login page is :   ${e.toString()}");
    }
  }
  Future<Null> handleFacebookSignIn() async {
    try {
      /*FirebaseUser firebaseUser = await AuthController().signInWithFacebook(context);
      print("firebase user using facebook sign in is:.......$firebaseUser");
      if(firebaseUser != null){
        Fluttertoast.showToast(msg: "Sign in success");
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      } else {
        this.setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Sign in fail");
      }*/
    } catch (e) {
      this.setState(() {
        isLoading = false;
      });
      print("error thrown in login page is :   ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.02),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.25,
              ),
              SizedBox(height: size.height * 0.05),
              RoundedInputField(
                keyBoardType: TextInputType.emailAddress,
                hintText: "Your Email",
                onChanged: (value) {
                  emailEditingController.text = value;
                },
              ),
              RoundedPasswordField(
                onChanged: (value) {
                  passwordEditingController.text = value;
                },
              ),
              isLoading
                  ? Container(
                child: Center(child: CircularProgressIndicator()),
              ): RoundedButton(
                text: "LOGIN",
                color: Constants.kPrimaryColor,
                press: (){
                  handleSignIn();
                  this.setState(() { isLoading = true;});
                },
              ),
              SizedBox(height: size.height * 0.06),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
              OrDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SocalIcon(
                    colors: Colors.indigo,
                    iconSrc: "assets/icons/facebook.svg",
                    press: () {
                      handleFacebookSignIn();
                      this.setState(() {
                        isLoading = true;
                      });
                    },
                  ),
                  SocalIcon(
                    colors: Colors.blue,
                    iconSrc: "assets/icons/twitter.svg",
                    press: () {
                      handleTwitterSignIn();
                      this.setState(() { isLoading = true; });
                    },
                  ),
                  SocalIcon(
                    colors: Colors.red,
                    iconSrc: "assets/icons/google-plus.svg",
                    press: (){
                      handleGoogleSignIn();
                      this.setState(() { isLoading = true;});
                    },//,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
