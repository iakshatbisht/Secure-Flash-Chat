
import 'package:flash_chat/const.dart';
import 'package:flash_chat/screens/all_users/friends.dart';
import 'package:flash_chat/screens/all_users/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class UsersScreen extends StatefulWidget {
  final String? userId;
  UsersScreen({this.userId});
  @override
  _UsersScreenState createState() => _UsersScreenState();
}
class _UsersScreenState extends State<UsersScreen> {
  static var textFactor = 1.0;
  Widget? appBarTitle;
  bool? isSearching;
  Icon? actionIcon;
  TextEditingController? serchText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSearching = false;
    //appBarTitle = titles();
    actionIcon = Icon(Icons.search);
    serchText = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    textFactor = MediaQuery.of(context).textScaleFactor;
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            actions: <Widget>[
              /*IconButton(
                  icon: actionIcon,
                  onPressed: () {
                    setState(() {
                      if (actionIcon.icon == Icons.search) {
                        actionIcon = Icon(Icons.close);
                        isSearching = true;
                      } else {
                        actionIcon = Icon(Icons.search);
                        isSearching = false;
                      }
                    });
                  }),*/
            ],
            title: isSearching == true ? Container(
              padding: EdgeInsets.only(left: 50),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                controller: serchText,
                style: TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.white)),
              ),
            ):Row(
              children: <Widget>[
                Icon(Icons.flash_on),
                Text(
                  'Chat App',
                  textScaleFactor: textFactor < 1.0 ? textFactor * 1.2 : textFactor,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Constants.kPrimaryColor,
            bottom: PreferredSize(
              preferredSize: isSearching == true ? Size.fromHeight(100): Size.fromHeight(50.0),
              child: Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  isSearching == true ? Container(
                    padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.flash_on,color: Colors.white,),
                          Text(
                            'Chat App',
                            textScaleFactor: textFactor < 0.5 ? textFactor * 1.2 : textFactor,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ):Container(),
                  TabBar(
                    labelStyle: TextStyle(
                        fontSize: textFactor < 1.0 ? textFactor * 20 : textFactor * 15),
                    indicatorColor: Colors.white,
                    indicatorWeight: 4.0,
                    tabs: [
                      Tab(
                        text: 'All Users',
                      ),
                      Tab(
                        text: 'Friends',
                      ),
                    ],
                  ),
                ],
                  ),
              ),
            ),
          body: TabBarView(
            children: [
              AllUserScreen(currentUserId: widget.userId),
              FriendsScreen(currentUserId: widget.userId),
            ],
          ),
        ),
      ),
    );
  }
}
