import 'package:flash_chat/screens/profile/view_photo.dart';
import 'package:flutter/material.dart';

class FullPhoto extends StatelessWidget {
  final String? url;

  FullPhoto({Key? key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsIconTheme: IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent.withOpacity(0.9),
        title: Text(
          'Profile Image',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.edit), onPressed: (){}),
          IconButton(icon: Icon(Icons.share), onPressed: (){}),
        ],
      ),
      body: FullPhotoScreen(url: url!),
      backgroundColor: Colors.black,
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String? url;

  FullPhotoScreen({Key? key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState();
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(child: PhotoViewer(url: widget.url!)));
  }
}
