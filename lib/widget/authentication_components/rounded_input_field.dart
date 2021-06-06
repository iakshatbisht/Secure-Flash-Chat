import 'package:flash_chat/const.dart';
import 'package:flutter/material.dart';

import 'text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyBoardType;
  final ValueChanged<String>? onChanged;
  const RoundedInputField({
    this.keyBoardType,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return TextFieldContainer(
      child: TextField(
        keyboardType: keyBoardType,
        onChanged: onChanged,
        cursorColor: Constants.kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: Constants.kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
