import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/user_chats/chat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FriendsScreen extends StatelessWidget {
  final String? currentUserId;
  FriendsScreen({this.currentUserId});
  double? height, width, textFactor;
  List<String> friendIds = [];
  List<String> chtIds = [];
  String? connectionStatus;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  DateTime? currentBackPressTime;
  List<String> timeIds = [];
  String person = "", userPhtotoUrl = "";
  bool isLoading = false;
  void initialize()async{
    person = (await HelperFunctions.getUserNameSharedPreference())!;
    userPhtotoUrl = (await HelperFunctions.getUserPhotoUrlSharedPreference())!;
  }
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    textFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              initialize();
              return Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      'No Users Found',
                      textScaleFactor: 1.3,
                    ),
                  ),
                ),
              );
            } else {
              if(friendIds.isEmpty)
                for(dynamic item in snapshot.data!.data()!['followers']) {
                  String chatId="";
                  friendIds.add(item.toString());
                  if (currentUserId.hashCode <= item.toString().hashCode) {
                    chatId = '$currentUserId-${item.toString()}';
                  } else {
                    chatId = '${item.toString()}-$currentUserId';
                  }
                  chtIds.add(chatId);
                }
              if(friendIds.isNotEmpty)
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => buildItem(context, friendIds[index], chtIds[index]),
                itemCount: friendIds.length,
                shrinkWrap: true,
              );
              else
                return Container(
                  height: height,
                  child: Center(
                  child: Text('No friends Connected', textScaleFactor: 2, style: TextStyle(color: Colors.grey),),
            ),
            );
            }
          },
        ),
      ),
    );
  }
  Widget buildItem(BuildContext context,String friendId, String chatId) {
     return StreamBuilder(
       stream: FirebaseFirestore.instance.collection('users').doc(friendId).snapshots(),
       builder: (BuildContext context, AsyncSnapshot<dynamic> userSnapshot){
         if(userSnapshot.hasData && !userSnapshot.hasError){
           //my friend's document
           dynamic document = userSnapshot.data;
           return StreamBuilder(
               stream: FirebaseFirestore.instance
                   .collection('messages')
                   .doc(chatId)
                   .collection(chatId)
                   .orderBy('timestamp', descending: false)
                   .snapshots(),
               builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {
                 if (snapshot.hasData && !snapshot.hasError) {
                   print("friends.dart Line 98: ${snapshot.data}");
                   QuerySnapshot<Map<String,dynamic>>? dtum = snapshot.data;
                   print("friends.dart Line 100: ${dtum}");
                   String message = "";
                   String talkingTo = person;
                   List<QueryDocumentSnapshot<Map<String,dynamic>>> listMessage = dtum!.docs;
                   String lastDate = "";
                   bool isSeen = false;
                   int totalUnseenMessage = 0;
                   if (friendId != currentUserId) {
                     for (DocumentSnapshot<Map<String,dynamic>> d in listMessage) {
                       lastDate = DateFormat.jm().format(
                           DateTime.fromMillisecondsSinceEpoch(
                               int.parse(d.id.toString())));
                       if (d.data()!['idFrom'].toString() != currentUserId) {
                         talkingTo =
                             document['nickname'].toString().split(" ").elementAt(0);
                         if (d.data()!['isSeen'].toString() != "Read") {
                           isSeen = true;
                           totalUnseenMessage++;
                         } else
                           isSeen = false;
                       } else
                         talkingTo = person.toString().split(" ").elementAt(0);
                       /*
                  0   text
                  1   img
                  2   gif
                  3   video
                  4   audio
                  */
                       switch(d.data()!['type'].toString()){
                         case '0':  message = talkingTo + ": " + d.data()!['content'].toString();
                         break;
                         case '1': message = '$talkingTo: Photo';
                         break;
                         case '2': message = '$talkingTo: GIF';
                         break;
                         default: message = '';
                       }
                     }
                     return InkWell(
                       onTap: () {
                         Navigator.push(
                             context,
                             MaterialPageRoute(
                                 builder: (context) => Chat(
                                   peerId: document.id,
                                   peerAvatar: document['photoUrl'],
                                   //connectionStatus: document['connectionStatus'],
                                   userName: document['nickname'],
                                   deviceToken: document['pushToken'],
                                 ),
                             ),
                         );
                       },
                       child: Padding(
                         padding: const EdgeInsets.only(top: 2),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             ListTile(
                               leading: document['photoUrl'] != null
                                   ? CachedNetworkImage(
                                 imageUrl: document['photoUrl'],
                                 imageBuilder: (context, imageProvider) =>
                                     Container(
                                       width: 55.0,
                                       height: 55.0,
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         image: DecorationImage(
                                             image: imageProvider,
                                             fit: BoxFit.fill),
                                       ),
                                     ),
                                 placeholder: (context, url) =>
                                     CircularProgressIndicator(),
                                 errorWidget: (context, url, error) =>
                                     Icon(Icons.error),
                               )
                                   : Icon(
                                 Icons.account_circle,
                                 size: 60.0,
                                 color: Constants.greyColor,
                               ),
                               title: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: <Widget>[
                                   Text(
                                     '${document['nickname'][0].toUpperCase()}${document['nickname'].substring(1)}',
                                     textScaleFactor: 1.2,
                                     style: TextStyle(
                                         color: Constants.primaryColor,
                                         fontWeight: FontWeight.bold),
                                   ),
                                   Text(
                                     lastDate,
                                     style: TextStyle(
                                       color: Colors.grey,
                                     ),
                                   ),
                                 ],
                               ),
                               subtitle: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: <Widget>[
                                   Padding(
                                     padding:
                                     const EdgeInsets.symmetric(vertical: 5.0),
                                     child:Text(
                                       document['aboutMe'].toString(),
                                       style: TextStyle(
                                           color: Colors.grey,
                                           fontStyle: FontStyle.italic,
                                       ),
                                       overflow: TextOverflow.ellipsis,
                                       maxLines: 1,
                                     ),
                                     /*Text(
                                       message,
                                       style: TextStyle(
                                           color:
                                           isSeen ? Colors.black : Colors.grey,
                                           fontWeight: isSeen
                                               ? FontWeight.bold
                                               : FontWeight.normal),
                                     ),*/
                                   ),
                                   totalUnseenMessage > 0
                                       ? Container(
                                     decoration: BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: Colors.red,
                                     ),
                                     padding: EdgeInsets.all(5),
                                     child: Text(
                                       totalUnseenMessage.toString(),
                                       style: TextStyle(color: Colors.white),
                                     ),
                                   )
                                       : Container(),
                                 ],
                               ),
                             ),
                             Divider(
                               thickness: 1.2,
                               height: 5,
                               indent: 80,
                             )
                           ],
                         ),
                       ),
                     );
                   }
                   return Container();
                 } else
                   return Container();
               });
         }
         return Container(
           child: Center(
             child: Text('No Friends'),
           ),
         );
       },
     );
  }
}