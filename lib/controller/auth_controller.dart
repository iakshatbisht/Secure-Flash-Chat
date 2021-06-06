import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/firebase_methods/usersDB.dart';
import 'package:flash_chat/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'helper_functions.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  //final TwitterLogin _twitterLogin = TwitterLogin(consumerKey: Constants.twitterConsumerKey, consumerSecret: Constants.twitterConsumerSecret);
  //final FacebookLogin _facebookLogin = FacebookLogin();

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential? result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      Map<String, dynamic>? details = (await FirebaseFirestore.instance.collection('users').doc(user!.uid).get()).data();
      user.updateDisplayName(details!["nickname"]);
      user.updatePhotoURL(details["photoUrl"]);
      await user.reload();
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({'connectionStatus' : 'Online'});
      await HelperFunctions.saveUserLoggedInSharedPreference(true);
      await HelperFunctions.saveUserEmailSharedPreference(user.email!);
      await HelperFunctions.saveUserIdSharedPreference(user.uid);
      await HelperFunctions.saveUserNameSharedPreference(details["nickname"]);
      await HelperFunctions.saveUserPhotoUrlSharedPreference(details["photoUrl"]);
      await HelperFunctions.saveUserAboutMeSharedPreference(details['aboutMe']);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  signUpWithEmailAndPassword(String email, String password, String nickname) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User firebaseUser = authResult.user!;
    final DocumentSnapshot<Map<String,dynamic>> result = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
    if (!result.exists) {
        List followers = [];
        Map<String,dynamic> map = {
          'aboutMe':"Hey there! I am on Flash Chat",
          'followers': followers,
          'email': email,
          'nickname': nickname,
          'photoUrl': firebaseUser.photoURL,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        };
        UserModel? userM = UserModel().fromMap(map);
        userM.id = firebaseUser.uid;
        userM.aboutMe = "Hey there! I am on Flash Chat";
        userM.nickname = firebaseUser.displayName;
        userM.email = firebaseUser.email;
        userM.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userM.photoUrl = firebaseUser.photoURL;
        userM.followers = followers;
        UsersDB.createUser(userM);
        await HelperFunctions.saveUserLoggedInSharedPreference(true);
        await HelperFunctions.saveUserEmailSharedPreference(userM.email!); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserIdSharedPreference(userM.id!); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserNameSharedPreference(userM.nickname!); //prefs.setString('nickname', currentUser.displayName);
        await HelperFunctions.saveUserPhotoUrlSharedPreference(userM.photoUrl!);
        await HelperFunctions.saveUserAboutMeSharedPreference(userM.aboutMe!);
      }else {
        await HelperFunctions.saveUserLoggedInSharedPreference(true);
        await HelperFunctions.saveUserEmailSharedPreference(result['email']); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserIdSharedPreference(result['id']); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserNameSharedPreference(result['nickname']); //prefs.setString('nickname', currentUser.displayName);
        await HelperFunctions.saveUserPhotoUrlSharedPreference(result['photoUrl']); //prefs.setString('photoUrl', currentUser.photoUrl);
        await HelperFunctions.saveUserAboutMeSharedPreference(result['aboutMe']);
      }
      return firebaseUser;
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    UserCredential authResult = await _auth.signInWithCredential(credential);
    User firebaseUser = authResult.user!;
      // Check is already sign up
      final DocumentSnapshot<Map<String,dynamic>> result = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      if (!result.exists) {
        List followers = [];
        UserModel? userM = UserModel();
        userM.id = firebaseUser.uid;
        userM.aboutMe = "Hey there! I am on Flash Chat";
        userM.nickname = firebaseUser.displayName;
        userM.email = firebaseUser.email;
        userM.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userM.photoUrl = firebaseUser.photoURL;
        userM.followers = followers;
        UsersDB.createUser(userM);
        await HelperFunctions.saveUserLoggedInSharedPreference(true);
        await HelperFunctions.saveUserEmailSharedPreference(userM.email!); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserIdSharedPreference(userM.id!); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserNameSharedPreference(userM.nickname!); //prefs.setString('nickname', currentUser.displayName);
        await HelperFunctions.saveUserPhotoUrlSharedPreference(userM.photoUrl!);
        await HelperFunctions.saveUserAboutMeSharedPreference(userM.aboutMe!);
      } else {
        FirebaseFirestore.instance.collection('users')
            .doc(firebaseUser.uid)
            .update({
          'connectionStatus' : "Online"
        });
        // Write data to local
        await HelperFunctions.saveUserLoggedInSharedPreference(true);
        await HelperFunctions.saveUserEmailSharedPreference(
            result['email']); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserIdSharedPreference(
            result['id']); //prefs.setString('id', currentUser.uid);
        await HelperFunctions.saveUserNameSharedPreference(
            result['nickname']); //prefs.setString('nickname', currentUser.displayName);
        await HelperFunctions.saveUserPhotoUrlSharedPreference(
            result['photoUrl']); //prefs.setString('photoUrl', currentUser.photoUrl);
        await HelperFunctions.saveUserAboutMeSharedPreference(
            result['aboutMe']);
      }
      return firebaseUser;
  }

  signInWithTwitter(BuildContext context) async {
    /*final TwitterLoginResult twitterLoginResult = await _twitterLogin.authorize();
    switch(twitterLoginResult.status){
      case TwitterLoginStatus.loggedIn:
        final AuthCredential credential = TwitterAuthProvider.credential(accessToken: twitterLoginResult.session.token, secret: twitterLoginResult.session.secret);
        UserCredential authResult = await _auth.signInWithCredential(credential);
        User? firebaseUser = authResult.user;
        if (firebaseUser != null) {
          final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('users').where(
              'id', isEqualTo: firebaseUser.uid).get();
          final List<DocumentSnapshot> documents = result.docs;
          if (documents.length == 0) {
            // Update data to server if new user
            List followers = [];
            FirebaseFirestore.instance.collection('users')
                .doc(firebaseUser.uid)
                .set({
              'aboutMe':"Hey there! I am on Flash Chat",
              'followers': followers,
              'email': authResult.additionalUserInfo!.profile!['screen_name'].toString(),
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoURL,
              'id': firebaseUser.uid,
              'createdAt': DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString(),
              'chattingWith': "",
              'connectionStatus' : "Online"
            });
            await HelperFunctions.saveUserLoggedInSharedPreference(true);
            await HelperFunctions.saveUserEmailSharedPreference(
                firebaseUser.email!); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserIdSharedPreference(
                firebaseUser.uid); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserNameSharedPreference(firebaseUser
                .displayName!); //prefs.setString('nickname', currentUser.displayName);
            await HelperFunctions.saveUserPhotoUrlSharedPreference(firebaseUser
                .photoURL!); //prefs.setString('photoUrl', currentUser.photoUrl);
            await HelperFunctions.saveUserAboutMeSharedPreference("Hey there! I am on Flash Chat");
          } else {
            // Write data to local
            await HelperFunctions.saveUserLoggedInSharedPreference(true);
            await HelperFunctions.saveUserEmailSharedPreference(
                documents[0]['email']); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserIdSharedPreference(
                documents[0]['id']); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserNameSharedPreference(
                documents[0]['nickname']); //prefs.setString('nickname', currentUser.displayName);
            await HelperFunctions.saveUserPhotoUrlSharedPreference(
                documents[0]['photoUrl']); //prefs.setString('photoUrl', currentUser.photoUrl);
            await HelperFunctions.saveUserAboutMeSharedPreference(
                documents[0]['aboutMe']);
          }
          return firebaseUser;
        }else{
          return null;
        }
        break;
      case TwitterLoginStatus.cancelledByUser:
        return null;
        break;
      case TwitterLoginStatus.error:
        print(twitterLoginResult.errorMessage);
        return null;
        break;
    }
    */
    return null;
  }

  /*Future<FirebaseUser> signInWithFacebook(BuildContext context) async {
    final FacebookLoginResult facebookLoginResult = await _facebookLogin.logInWithReadPermissions(['email']);
    switch(facebookLoginResult.status){
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
        final AuthCredential credential =  FacebookAuthProvider.getCredential(accessToken: facebookAccessToken.token);
        AuthResult authResult = await _auth.signInWithCredential(credential);
        FirebaseUser firebaseUser = authResult.user;
        if (firebaseUser != null) {
          // Check is already sign up
          final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('users').where(
              'id', isEqualTo: firebaseUser.uid).getDocuments();
          final List<DocumentSnapshot> documents = result.documents;
          if (documents.length == 0) {
            // Update data to server if new user
            List followers = [];
            FirebaseFirestore.instance.collection('users')
                .document(firebaseUser.uid)
                .setData({
              'followers': followers,
              'email': firebaseUser.email,
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoUrl,
              'id': firebaseUser.uid,
              'createdAt': DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString(),
              'chattingWith': "",
              'connectionStatus' : "Online"
            });
            await HelperFunctions.saveUserLoggedInSharedPreference(true);
            await HelperFunctions.saveUserEmailSharedPreference(
                firebaseUser.email); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserIdSharedPreference(
                firebaseUser.uid); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserNameSharedPreference(firebaseUser
                .displayName); //prefs.setString('nickname', currentUser.displayName);
            await HelperFunctions.saveUserPhotoUrlSharedPreference(firebaseUser
                .photoUrl); //prefs.setString('photoUrl', currentUser.photoUrl);
          } else {
            // Write data to local
            await HelperFunctions.saveUserLoggedInSharedPreference(true);
            await HelperFunctions.saveUserEmailSharedPreference(
                documents[0]['email']); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserIdSharedPreference(
                documents[0]['id']); //prefs.setString('id', currentUser.uid);
            await HelperFunctions.saveUserNameSharedPreference(
                documents[0]['nickname']); //prefs.setString('nickname', currentUser.displayName);
            await HelperFunctions.saveUserPhotoUrlSharedPreference(
                documents[0]['photoUrl']); //prefs.setString('photoUrl', currentUser.photoUrl);
            await HelperFunctions.saveUserAboutMeSharedPreference(
                documents[0]['aboutMe']);
          }
          return firebaseUser;
        }else{
          return null;
        }
        break;
      case FacebookLoginStatus.error:
        print(facebookLoginResult.errorMessage);
        break;
      case FacebookLoginStatus.cancelledByUser:
        return null;
    }
  }*/

  Future signOut() async {
    try {
      String? id = await HelperFunctions.getUserIdSharedPreference();
      await _auth.signOut();
      //await _facebookLogin.logOut();
      //await _twitterLogin.logOut();
      await _googleSignIn.signOut();
      FirebaseFirestore.instance.collection('users').doc(id).update({'connectionStatus' : 'Offline'});
      await HelperFunctions.deleteUserFromSharedPrefs();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  deleteAccount() async {
    try {
      User user = _auth.currentUser!;
      bool ans = await _googleSignIn.isSignedIn();
      if (ans) {
        _googleSignIn.disconnect();
      }
      user.delete();
    }catch(e){
      print("delete error :- "+ e.toString());

    }
  }

  Stream<DocumentSnapshot<Map<String,dynamic>>> getConnectionStatus({@required peerId}) => FirebaseFirestore.instance.collection('users').doc(peerId).snapshots();
}
