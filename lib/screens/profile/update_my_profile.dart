import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/profile/view_photo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        automaticallyImplyLeading: true,
        backgroundColor: Constants.kPrimaryColor,
        title: Text(
          'Profile',
          style: TextStyle(color: Constants.kPrimaryLightColor),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;
  String id = '', nickname = '', aboutMe = '', photoUrl = '', createDate = '';
  bool isLoading = false;
  File? avatarImageFile;
  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();
  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    //prefs = await SharedPreferences.getInstance();
    id = await HelperFunctions.getUserIdSharedPreference() ??
        ''; //prefs.getString('id') ?? '';
    nickname = await HelperFunctions.getUserNameSharedPreference() ??
        ''; //prefs.getString('nickname') ?? '';
    aboutMe = await HelperFunctions.getUserAboutMeSharedPreference() ??
        ''; //prefs.getString('aboutMe') ?? '';
    photoUrl = await HelperFunctions.getUserPhotoUrlSharedPreference() ??
        ''; //prefs.getString('photoUrl') ?? '';

    controllerNickname = TextEditingController(text: nickname);
    controllerAboutMe = TextEditingController(text: aboutMe);
    String getDate = (await FirebaseFirestore.instance.collection('users').doc(id).get()).data()!["createdAt"].toString();
    createDate = DateFormat("dd/MM/yy").format(
      DateTime.fromMillisecondsSinceEpoch(
        int.parse(
          getDate,
        ),
      ),
    ) +" at " + DateFormat.jm().format(
      DateTime.fromMillisecondsSinceEpoch(int.parse(
          getDate),
      ),
    );
    print("in settings wht we get is......");
    print("$id --> $nickname --> $aboutMe --> $photoUrl");
    // Force refresh input
    setState(() {});
  }

  Future gettingImage() async {
   /* PickedFile imgs = await ImagePicker().getImage(source: ImageSource.gallery);
    File image;
    setState(() {
      image = File(imgs.path);
    });
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    print("called gettingImage method");
    uploadProfPic();*/
  }

  Future uploadProfPic() async {
    String? fileName = id;
    Reference? reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask? uploadTask = reference.putFile(avatarImageFile!);
    TaskSnapshot? storageTaskSnapshot;
    uploadTask.then((value) {
      storageTaskSnapshot = value;
        storageTaskSnapshot!.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .update({'photoUrl': photoUrl}).then((data) async {
            await HelperFunctions.saveUserPhotoUrlSharedPreference(
                photoUrl); //prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });

          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            print("update_my_profile.dart Line 106 ${err.toString()}");
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          print('update_my_profile.dart Line 112 : This file is not an image');
        });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      print("update_my_profile.dart Line 118 ${err.toString()}");
    });
  }

  Future uploadFile() async {
    String fileName = id;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(avatarImageFile!);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          FirebaseFirestore.instance.collection('users').doc(id).update({
            'nickname': nickname,
            'aboutMe': aboutMe,
            'photoUrl': photoUrl
          }).then((data) async {
            await HelperFunctions.saveUserPhotoUrlSharedPreference(
                photoUrl); //prefs.setString('photoUrl', photoUrl);
            await HelperFunctions.saveUserNameSharedPreference(
                nickname); //prefs.setString('nickname', nickname);
            await HelperFunctions.saveUserAboutMeSharedPreference(
                aboutMe); //prefs.setString('aboutMe', aboutMe);
            setState(() {
              isLoading = false;
            });
            print("Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            print(err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          print('This file is not an image');
        });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();
    setState(() {
      isLoading = true;
    });
    FirebaseFirestore.instance.collection('users').doc(id).update({
      'nickname': nickname,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl
    }).then((data) async {
      await HelperFunctions.saveUserNameSharedPreference(
          nickname); //prefs.setString('nickname', nickname);
      await HelperFunctions.saveUserAboutMeSharedPreference(
          aboutMe); //prefs.setString('aboutMe', aboutMe);
      await HelperFunctions.saveUserPhotoUrlSharedPreference(
          photoUrl); //prefs.setString('photoUrl', photoUrl);
      setState(() {
        isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
       SingleChildScrollView(
         padding: EdgeInsets.only(top: 50.0,left: 15.0, right: 15.0),
         child: Column(
           children: <Widget>[
                Center(
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        (avatarImageFile == null)
                            ? (photoUrl != ''
                                ? MaterialButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PhotoViewer(url: photoUrl)));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                          border: Border.all(
                                              color: Colors.white, width: 8.0),
                                          shape: BoxShape.circle),
                                      child: Center(
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(photoUrl),
                                          minRadius: 50.0,
                                          maxRadius: 80.0,
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.account_circle,
                                      size: 90.0,
                                      color: Constants.greyColor,
                                    ),
                                    onPressed: () {
                                      print('No Profile Photo');
                                    },
                                  ))
                            : MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoViewer(url: photoUrl)));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      border: Border.all(
                                          color: Colors.white, width: 8.0),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: FileImage(avatarImageFile!),
                                      minRadius: 50.0,
                                      maxRadius: 80.0,
                                    ),
                                  ),
                                ),
                              ),
                        Align(
                          widthFactor: 4.85,
                          heightFactor: 3.5,
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 50.0,
                            width: 50.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              onPressed: gettingImage,
                              iconSize: 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.08),
                Column(
                  children: <Widget>[
                    _heading('Nickname'),
                    _buildTextField(controllerNickname, focusNodeNickname, nickname),
                   _heading('About me'),
                    _buildTextField(controllerAboutMe, focusNodeAboutMe, aboutMe),
                    _heading('Created on'),
                    _buildText(createDate),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                // Button

             Container(
               margin: EdgeInsets.symmetric(horizontal: size.width*0.1, vertical: size.height*0.05),
               child: TextButton(
                 onPressed: handleUpdateData,
                 child: Text(
                   'UPDATE',
                   textScaleFactor: 1.3,
                   style: TextStyle(fontSize: 15.0,color: Constants.kPrimaryColor,),
                 ),
               ),
             ),
              ],
            ),
       ),
        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Constants.themeColor)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),
      ],
    );
  }
  _heading(text){
    return Container(
      child: Text(
       text,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor),
      ),
      margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
    );
  }
  _buildTextField(textFieldController,focusNode, text){
    return Container(
      child: Theme(
        data: Theme.of(context)
            .copyWith(primaryColor: Constants.primaryColor),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Fun, like travel and play PES...',
            contentPadding: EdgeInsets.all(5.0),
            hintStyle: TextStyle(color: Constants.greyColor),
          ),
          controller: textFieldController,
          onChanged: (value) {
            text = value;
          },
          focusNode: focusNode,
        ),
      ),
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
    );
  }
  _buildText(text){
    return Container(
      child: Theme(
        data: Theme.of(context)
            .copyWith(primaryColor: Constants.primaryColor),
        child: Text(
          text,
          style: TextStyle(decorationStyle: TextDecorationStyle.wavy),
        ),
      ),
      margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 10.0),
    );
  }
}
