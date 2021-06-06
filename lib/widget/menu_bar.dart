import 'dart:async';
import 'dart:math';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/auth_controller.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/all_users/user_tab_screen.dart';
import 'package:flash_chat/screens/profile/update_my_profile.dart';
import 'package:flash_chat/screens/splash.dart';
import 'package:flash_chat/screens/welcome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MenuBar extends StatefulWidget {
  final String? userPhotoUrl;
  final String? userName;
  final String? userId;
  MenuBar({this.userName, this.userPhotoUrl, this.userId,});
  @override
  _MenuBarState createState() => _MenuBarState();
}

class _MenuBarState extends State<MenuBar> with SingleTickerProviderStateMixin{
  Animation? _arrowAnimation;
  AnimationController? _arrowAnimationController;
  double? profileRadius;
  bool? showRail, visibility;
  int? _selectedIndex;
  Color? unselectedColor, selectedColor;
  List<Color>? icColor ;
  String id="",name = "", photoUrl = "";
  @override
  void initState() {
    super.initState();
    
    showRail = false;
    visibility = false;
    profileRadius = 0.0;
    _selectedIndex = 0;
    _arrowAnimationController =
        AnimationController(duration: Duration(milliseconds: 300),vsync: this);
    _arrowAnimation =
        Tween(begin: 0.0, end: pi).animate(_arrowAnimationController!);
  icColor = [
    Constants.kPrimaryLightColor,
    Constants.kPrimaryLightColor,
    Constants.kPrimaryLightColor,
    Constants.kPrimaryLightColor,
    Constants.kPrimaryLightColor
  ];
  getUser();
  }
  getUser()async {
    id = (await HelperFunctions.getUserIdSharedPreference())!;
    name = (await HelperFunctions.getUserNameSharedPreference())!;
    photoUrl = (await HelperFunctions.getUserPhotoUrlSharedPreference())!;
  }
  FutureOr onGoBack(dynamic value) {
    getUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var textFactor = MediaQuery.of(context).textScaleFactor;
    var iconSize = width<360 ? textFactor*30 : textFactor * 35;
    return Row(
      children: <Widget>[
        showRail == true
            ? NavigationRail(
            backgroundColor: Constants.kPrimaryColor,
            elevation: 5.0,
            minExtendedWidth: width / 2,
            minWidth: width / 6,
            extended: visibility!,
            labelType: NavigationRailLabelType.none,
            selectedIndex: _selectedIndex!,
            leading: Container(
              height: height / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: profileRadius == 0.0
                          ? width / 15 + 2
                          : profileRadius! + 2,
                      backgroundColor: Constants.kPrimaryLightColor,
                      child:
                      photoUrl == null || photoUrl == ""
                          ? Container()
                          : CircleAvatar(
                        backgroundImage:
                        NetworkImage(photoUrl),
                        radius: profileRadius == 0.0
                            ? width / 15
                            : profileRadius,
                      ),
                    ),
                  ),
                  visibility == true
                      ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                     name,
                      textScaleFactor: textFactor * 1.5,
                      style:
                      TextStyle(color: Constants.kPrimaryLightColor),
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
            trailing:  Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height/3,
                child: FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                        return Hero(
                          tag: "log out",
                          child: CupertinoAlertDialog(
                            title:
                            Text('Are you sure you want to log out from Flash Chat'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('Yes'),
                                onPressed: () {
                                  handleSignOut();
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                        },
                        );
                  },
                  elevation: 0.0,
                  mini: true,
                  heroTag: "log out",
                  child: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                icColor = [
                  Constants.kPrimaryLightColor,
                  Constants.kPrimaryLightColor,
                  Constants.kPrimaryLightColor,
                  Constants.kPrimaryLightColor,
                  Constants.kPrimaryLightColor
                ];
                icColor![_selectedIndex!] = Colors.white;
                print("index is = $_selectedIndex");
              });
            },
            destinations: [
              NavigationRailDestination(
                icon: IconButton(icon: Icon(Icons.camera),
                    iconSize: iconSize,
                    color: icColor![0],
                onPressed: (){
                },),
                selectedIcon: IconButton(icon: Icon(Icons.camera),
                  iconSize: iconSize,
                  color: icColor![0],
                  onPressed: (){
                    //ImagePicker().getImage(source: ImageSource.camera);
                  },),
                label: GestureDetector(
                  child: Text(
                    'Camera',
                    style: TextStyle(color: icColor![0]),
                  ),
                  onTap: (){

                  },
                ),
              ),
              NavigationRailDestination(
                  icon: IconButton(
                    icon: Icon(Icons.supervisor_account),
                    iconSize: iconSize,
                    color: icColor![1],
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen(userId: widget.userId)));
                    },
                  ),
                selectedIcon: IconButton(icon: Icon(Icons.supervisor_account),
                  iconSize: iconSize,
                  color: icColor![1],
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen(userId: widget.userId)));
                  },),
                label: Text(
                  'See Users',
                  style: TextStyle(color: icColor![1]),
                ),
              ),
              /*NavigationRailDestination(
                icon: IconButton(
                  icon: Icon(Icons.camera_roll),
                  iconSize: iconSize,
                  color: icColor[2],
                  onPressed: () {},
                ),
                selectedIcon: IconButton(
                  icon: Icon(Icons.camera_roll),
                  iconSize: iconSize,
                  color: icColor[2],
                  onPressed: () {},
                ),
                label: Text(
                  'Status',
                  style: TextStyle(color: icColor[2]),
                ),
              ),
              NavigationRailDestination(
                icon: IconButton(
                  icon: Icon(Icons.call),
                  iconSize: iconSize,
                  color: icColor[3],
                  onPressed: () {
*//* Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => WelcomeScreen()));*//*
                  },
                ),
                selectedIcon: IconButton(
                  icon: Icon(Icons.call),
                  iconSize: iconSize,
                  color: icColor[3],
                  onPressed: () {

                  },
                ),
                label: Text(
                  'Calls',
                  style: TextStyle(color: icColor[3]),
                ),
              ),*/
              NavigationRailDestination(
                icon: IconButton(
                  icon: Icon(Icons.settings),
                  iconSize: iconSize,
                  color: icColor![4],
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settings())).then(onGoBack);
                  },
                ),
                selectedIcon: IconButton(
                  icon: Icon(Icons.settings),
                  iconSize: iconSize,
                  color: icColor![4],
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settings()));
                  },
                ),
                label: GestureDetector(
                  child: Text(
                    'Settings',
                    style: TextStyle(color: icColor![4]),
                  ),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settings()));
                  },
                ),
              ),
            ],
            )
            : Container(),
        VerticalDivider(
          thickness: 1,
          width: 1,
        ),
        AnimatedBuilder(
          animation: _arrowAnimationController!,
          builder: (context, child) => GestureDetector(
            child: Transform.rotate(
              angle: _arrowAnimation!.value,
              child: Icon(
                Icons.chevron_right,
                size: 50.0,
                color: Colors.black,
              ),
            ),
            onTap: () {
              _arrowAnimationController!.isCompleted
                  ? _arrowAnimationController!.reverse()
                  : _arrowAnimationController!.forward();
              setState(() {
                visibility = ! visibility!;
                if (profileRadius == 0.0)
                  profileRadius = width / 7;
                else if (profileRadius == width / 7)
                  profileRadius = width / 15;
                else
                  profileRadius = width / 7;
              });
            },
            onPanUpdate: (details) {
              if (details.delta.dx < 0) {
                setState(() {
                  showRail = false;
                });
              } else if (details.delta.dx > 0) {
                setState(() {
                  showRail = true;
                });
              }
            },
          ),
        ),
      ],
    );
  }
  Future<Null> handleSignOut() async {

    await AuthController().signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
            (Route<dynamic> route) => false);
  }

}
