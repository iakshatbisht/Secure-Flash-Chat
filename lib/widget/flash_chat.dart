import 'package:flutter/material.dart';


class FlashChat extends StatefulWidget {
  @override
  _FlashChatState createState() => _FlashChatState();
}

class _FlashChatState extends State<FlashChat> with SingleTickerProviderStateMixin{
  AnimationController? controller;
  Animation? animation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    );
    animation = CurvedAnimation(parent: controller!, curve: Curves.easeInCubic);
    controller!.forward();
    controller!.addListener(() {
      setState(() {
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: width <360 ? MediaQuery.of(context).size.width/6 : MediaQuery.of(context).size.width/3,
          ),
          Expanded(
            child: Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset('assets/images/logo.png'),
                height: 100,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Flash \nChat',
              style: TextStyle(
                fontSize: width <360 ?controller!.value * 35:controller!.value * 40,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
