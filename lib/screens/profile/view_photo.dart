import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PhotoViewer extends StatelessWidget {
  final String? url;
  const PhotoViewer({this.url});

  @override
  Widget build(BuildContext context) {
    var size =MediaQuery.of(context).size;
    AppBar appBar = AppBar(
      title: Text('abc'),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: true,
    );
    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: size.height/2 - appBar.preferredSize.height,
          width: size.width,
          child: CachedNetworkImage(imageUrl: url!),
        ),
      ),
    );
  }
}
