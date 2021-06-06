import 'package:flash_chat/const.dart';
import 'package:flash_chat/screens/auth/signup_screen.dart';
import 'package:flash_chat/widget/authentication_components/rounded_button.dart';
import 'package:flash_chat/widget/welcome_page_components/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'auth/login_screen.dart';


class WelcomeScreen extends StatelessWidget{
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
              "WELCOME TO FLASH CHAT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.1),
            SvgPicture.asset(
              "assets/icons/chat.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.1),
            RoundedButton(
              text: "LOGIN",
              color: Constants.kPrimaryColor,
              press: () {
                print("tapped login");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            RoundedButton(
              text: "SIGN UP",
              color: Constants.kPrimaryLightColor,
              textColor: Colors.black,
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
          ],
        ),
    ),
      ),
    );
  }
}
/*
class LogoScreen extends StatefulWidget {
  const LogoScreen({Key key}) : super(key: key);

  @override
  _LogoScreenState createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(
        controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  child: Image.asset('assets/images/logo.png'),
                  height: controller.value*80,
                ),
              ),
              Text(
                'Flash Chat',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 48.0,
          ),
          IconButton(icon: Icon(Icons.login),color: Colors.white,),
        ],
      ),
    );
  }
}
*/
