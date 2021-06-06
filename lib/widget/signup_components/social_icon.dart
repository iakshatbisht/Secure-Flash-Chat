import 'package:flash_chat/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SocalIcon extends StatelessWidget {
  final String? iconSrc;
  final Color? colors;
  final void Function()? press;
  const SocalIcon({
    this.iconSrc,
    this.press,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colors,
          border: Border.all(
            width: 2,
            color: Constants.kPrimaryLightColor,
          ),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconSrc!,
          height: 15,
          width: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
