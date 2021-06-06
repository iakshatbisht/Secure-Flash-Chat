
import 'package:flash_chat/const.dart';
import 'package:flutter/material.dart';
import 'text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  const RoundedPasswordField({
    this.onChanged,
  });

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool? _obscured;
  Icon? ic;
  @override
  void initState() {
    super.initState();
    _obscured = true;
    ic = Icon(
      Icons.visibility,
      color: Constants.kPrimaryColor,);
  }
  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: _obscured!,
        onChanged: widget.onChanged,
        cursorColor: Constants.kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: Constants.kPrimaryColor,
          ),
          suffixIcon: IconButton(
            icon: ic!,
            onPressed: (){
              this.setState(() {
                _obscured = ! _obscured!;
                if(_obscured!)
                    ic = Icon(
                      Icons.visibility,
                      color: Constants.kPrimaryColor,);
                else
                  ic = Icon(
                    Icons.visibility_off,
                    color: Constants.kPrimaryColor,);
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
