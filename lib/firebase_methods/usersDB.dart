import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/model/user_model.dart';

class UsersDB{
  //CRUD
  //create
  static createUser(UserModel user) async{
   try{
     FirebaseFirestore.instance.collection('users')
         .doc(user.id)
         .set({
       'aboutMe':"Hey there! I am on Flash Chat",
       'followers': user.followers,
       'email': user.email,
       'nickname': user.nickname,
       'photoUrl': user..photoUrl,
       'id': user.id,
       'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
       'chattingWith': '',
       'connectionStatus' : 'Online'
     });
   }catch (error){
     print("user creation error ${error.toString()}");
   }
  }

  //read
  static readUser(String id) async{
    try{
      DocumentSnapshot<Map<String,dynamic>> document = await FirebaseFirestore.instance.collection('users').doc(id).get();
      return document;
    }catch (error){
      print("user read error ${error.toString()}");
    }
  }

  //update
  static updateUser(map,id) async{
    try{
      FirebaseFirestore.instance.collection('users')
          .doc(id)
          .set({
        'aboutMe':map['aboutMe'],
        'followers': map['followers'],
        'email': map['email'],
        'nickname': map['nickname'],
        'photoUrl': map['photoUrl'],
        'id': id,
        'chattingWith': map['chattingWith'],
        'connectionStatus' : map['status']
      });
    }catch (error){
      print("user update error ${error.toString()}");
    }
  }
  //delete
  static deleteUser(String id) async{
    try{
      FirebaseFirestore.instance.collection('users').doc(id).delete();
    }catch (error){
      print("user creation error ${error.toString()}");
    }
  }
}