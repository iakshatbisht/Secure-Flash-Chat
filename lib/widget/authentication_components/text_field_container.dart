import 'package:flash_chat/const.dart';
import 'package:flutter/material.dart';


class TextFieldContainer extends StatelessWidget {
  final Widget? child;
  const TextFieldContainer({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      width: size.width * 0.7,
      decoration: BoxDecoration(
        color: Constants.kPrimaryLightColor,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
