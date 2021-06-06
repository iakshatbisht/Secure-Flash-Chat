
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
 List<String>? followerIds;
 final String? currentUserId;
 final String? followerId;
 FollowButton({this.followerIds, this.currentUserId, this.followerId});
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  IconData? ic;
  String? text ="";
  Color? buttonColor, textColor;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.followerIds!.contains(widget.followerId)){
      ic = Icons.check;
      text = "Following";
      buttonColor = Colors.white;
      textColor = Constants.kPrimaryColor;
    }else {
      ic = Icons.add;
      text = "Follow";
      buttonColor = Constants.kPrimaryColor;
      textColor = Colors.white;
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: (){
        addFollower(widget.followerId!);
      },
      color: buttonColor,
      textColor: textColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
            color: textColor!,
            width: 1,
            style: BorderStyle.solid
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(0.0),
        padding: buttonColor == Constants.kPrimaryColor? EdgeInsets.all(8.0) : EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(ic, color: textColor),
            Text(text!, textScaleFactor: 1.2,),
          ],
        ),
      ),
    );
  }
  void addFollower(String idToAdd) async {
    if(!widget.followerIds!.contains(widget.followerId)) {
      widget.followerIds!.add(idToAdd);
      await FirebaseFirestore.instance.collection("users").doc(
          widget.currentUserId).update({"followers": widget.followerIds});
    }
    setState(() {
        ic = Icons.check;
        text = "Following";
        buttonColor = Colors.white;
        textColor = Constants.kPrimaryColor;
    });
  }
}
