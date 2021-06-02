import 'package:flutter/material.dart';
import 'package:share/share.dart';

class Gif_Page extends StatelessWidget {

  final Map _gifData;

  Gif_Page(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData["title"]),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: (){
            Share.share(_gifData["images"]["fixed_height"]["url"]);
          })
        ],
      ),
      body: Center(
        child: Image.network(_gifData["images"]["fixed_height"]["url"]),
      ),
      backgroundColor: Colors.black,
    );
  }
}
