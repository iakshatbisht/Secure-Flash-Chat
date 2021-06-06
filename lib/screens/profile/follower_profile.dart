import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FollowerProfile extends StatelessWidget {
  final DocumentSnapshot? detail;
  const FollowerProfile({this.detail, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String date = DateFormat("dd/MM/yy").format(
      DateTime.fromMillisecondsSinceEpoch(
        int.parse(
          detail!['createdAt'],
        ),
      ),
    );
    var size = MediaQuery.of(context).size;
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Hero(
              tag: detail!.id,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 8.0,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(detail!['photoUrl']),
                  minRadius: size.width.ceil() / 6,
                  maxRadius: size.width.ceil() / 5,
                ),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text(
                detail!['nickname'],
                textAlign: TextAlign.center,
              ),
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Chip(
                        label: Text(
                          detail!["connectionStatus"],
                          textScaleFactor: 1.2,
                          style: TextStyle(color: Colors.white),
                        ),
                        deleteIcon: Container(),
                        onDeleted: () {},
                        avatar: Container(),
                        backgroundColor: detail!["connectionStatus"] == "Online"
                            ? Colors.green
                            : Constants.kPrimaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    _heading("About me"),
                    Text(detail!['aboutMe']),
                    SizedBox(
                      height: 20.0,
                    ),
                    _heading("Created at"),
                    Text(date),
                    SizedBox(
                      height: 20.0,
                    ),
                    _heading("Point of Contact"),
                    Text(detail!["email"]),
                  ],
              ),
            ),
          ],
      ),
    );
  }

  _heading(String text) {
    return Text(
      text,
      style: TextStyle(color: Constants.kPrimaryColor, fontSize: 15.0),
    );
  }
}
