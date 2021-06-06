import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/const.dart';
import 'package:flash_chat/controller/helper_functions.dart';
import 'package:flash_chat/screens/profile/view_photo.dart';
import 'package:flutter/material.dart';

class ChatUserSettings extends StatefulWidget {
  String? name;
  String? url;
  String? status;
  ChatUserSettings({this.name="",this.status="",this.url=""});

  @override
  _ChatUserSettingsState createState() => _ChatUserSettingsState();
}

class _ChatUserSettingsState extends State<ChatUserSettings> {
  Color? bgColor;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updatePalette();
  }
  _updatePalette() async{
    //final PaletteGenerator pg = PaletteGenerator.fromImageProvider(NetworkImage(widget.url));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD0D3D4),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 400.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.name!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Container(
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white,Colors.black],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,),
                    ),
                    child: Image.network(
                      widget.url!,
                      fit: BoxFit.cover,
                    ),
                  ),
              titlePadding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
              ),
              centerTitle: false,
            ),
          ];
        },
        body: Center(
          child: Text(widget.status!),
        ),
      ),
    );
  }
}

class ChatUserSettingsScreen extends StatefulWidget {
  @override
  State createState() => ChatUserSettingsScreenState();
}

class ChatUserSettingsScreenState extends State<ChatUserSettingsScreen> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;

  //SharedPreferences prefs;

  String? id = '';
  String? nickname = '';
  String? aboutMe = '';
  String? photoUrl = '';

  bool? isLoading = false;
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
    print("in settings wht we get is......");
    print("$id --> $nickname --> $aboutMe --> $photoUrl");
    // Force refresh input
    setState(() {});
  }

  Future gettingImage() async {
    /*PickedFile imgs = await ImagePicker().getImage(source: ImageSource.gallery);
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
    uploadFile();*/
  }

  Future uploadFile() async {
    String? fileName = id;
    Reference reference = FirebaseStorage.instance.ref().child(fileName!);
    UploadTask uploadTask = reference.putFile(avatarImageFile!);
    TaskSnapshot storageTaskSnapshot = uploadTask.snapshot;
    uploadTask.whenComplete(() {
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        photoUrl = downloadUrl;
        FirebaseFirestore.instance.collection('users').doc(id).update({
          'nickname': nickname,
          'aboutMe': aboutMe,
          'photoUrl': photoUrl
        }).then((data) async {
          await HelperFunctions.saveUserPhotoUrlSharedPreference(
              photoUrl!); //prefs.setString('photoUrl', photoUrl);
          setState(() {
            isLoading = false;
          });
          print("chat user settings.dart Line 154:  Success!");
        });
      }).catchError((err) {
          setState(() {
            isLoading = false;
          });
          print("chat user settings.dart Line 160: ${err.toString()}");
        });
    }).catchError((error){
      setState(() {
    isLoading = false;
    });
      print("chat user settings.dart Line 166:  ${error.toString()}");
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
          nickname!); //prefs.setString('nickname', nickname);
      await HelperFunctions.saveUserAboutMeSharedPreference(
          aboutMe!); //prefs.setString('aboutMe', aboutMe);
      await HelperFunctions.saveUserPhotoUrlSharedPreference(
          photoUrl!); //prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      print("chat user settings.dart Line 194:  Success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      print("chat user settings.dart Line 199:  ${err.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Avatar
              Center(
                child: Container(
                  height: 300.0,
                  margin: EdgeInsets.only(top: 50.0),
                  // color: Colors.green,
                  width: 300.0,
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                          ? MaterialButton(
                        splashColor: Colors.white,
                        child: Material(
                          color: Colors.transparent,
                          type: MaterialType.circle,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Constants.themeColor),
                              ),
                              width: 500.0,
                              height: 500.0,
                              //padding: EdgeInsets.all(20.0),
                            ),
                            imageUrl: photoUrl!,
                            width: 500.0,
                            height: 500.0,
                            fit: BoxFit.cover,
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PhotoViewer(url: photoUrl)));
                        },
                      )
                          : IconButton(
                        icon: Icon(
                          Icons.account_circle,
                          size: 90.0,
                          color: Constants.greyColor,
                        ),
                        onPressed: () {
                          print("chat user settings.dart Line 264:  no photo");
                        },
                      ))
                          : MaterialButton(
                        // color: Colors.pink,
                        splashColor: Colors.white,
                        child: Material(
                          color: Colors.transparent,
                          type: MaterialType.circle,
                          child: Image.file(
                            avatarImageFile!,
                            width: 500.0,
                            height: 500.0,
                            fit: BoxFit.cover,
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PhotoViewer(url: photoUrl)));
                        },
                      ),
                      Align(
                        widthFactor: 4.5,
                        heightFactor: 4.75,
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 60.0,
                          width: 60.0,
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
                            splashColor: Colors.transparent,
                            highlightColor: Constants.greyColor,
                            iconSize: 25.0,
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 100.0,),
              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'Nickname',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Constants.primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Sweetie',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Constants.greyColor),
                        ),
                        controller: controllerNickname,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // About me
                  Container(
                    child: Text(
                      'About me',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Constants.primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Fun, like travel and play PES...',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Constants.greyColor),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: focusNodeAboutMe,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Container(
                child: MaterialButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Constants.primaryColor,
                  highlightColor: Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading!
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
}
