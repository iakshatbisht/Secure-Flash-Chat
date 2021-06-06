import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/widget/follow_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllUserScreen extends StatelessWidget {
  final String? currentUserId;
  AllUserScreen({Key? key, @required this.currentUserId}) : super(key: key);
  double? height, width, textFactor;
  bool isLoading = false;
  List<String> followerIds = [];
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    textFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Container(
                  height: height,
                  width: width,
                  child: Center(
                    child: Text(
                      'No Users Found',
                      textScaleFactor: 1.3,
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => buildItem(context, snapshot, index),
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
              );
            }
          },
        ),
      ),
    );
  }
  Widget buildItem(BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshotUser, index) {
    DocumentSnapshot document = snapshotUser.data!.docs[index];
    if (document.id
        .toString()
        .contains(currentUserId.toString())){
      return Container();
    }
    else {
     return StreamBuilder(
         stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
         builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot){
           if(snapshot.hasData && snapshot.data != null){
           String lastDate = DateFormat("dd/MM/yy")
               .format(DateTime.fromMicrosecondsSinceEpoch(
               int.parse(snapshot.data!['createdAt'].toString()) * 1000));
           if(followerIds.isEmpty)
             for(dynamic item in snapshot.data!['followers'])
               followerIds.add(item.toString());
           return InkWell(
             onTap: () {},
             child: Padding(
               padding: const EdgeInsets.all(5.0),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   ListTile(
                     contentPadding: EdgeInsets.all(0.0),
                     leading: document['photoUrl'] != null
                         ? CachedNetworkImage(
                       imageUrl: document['photoUrl'],
                       imageBuilder: (context, imageProvider) =>
                           Container(
                             width: MediaQuery.of(context).size.width<360? 45:55.0,
                             height:MediaQuery.of(context).size.width<360? 45:55.0,
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
                     title: Text(
                       '${document['nickname'][0].toUpperCase()}${document['nickname'].substring(1)}',
                       textScaleFactor: 1.2,
                       style: TextStyle(
                           color: Constants.primaryColor,
                           fontWeight: FontWeight.bold),
                     ),
                     subtitle: Text("created on: $lastDate", style: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic),),
                     trailing: Container(child: FollowButton(currentUserId: currentUserId,followerIds: followerIds,followerId: document.id,))
                   ),
                   Divider(
                     thickness: 1.2,
                     height: 5,
                     indent: 50,
                   )
                 ],
               ),
             ),
           );
           }
          return Container();
     });
    }
  }
}
