import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _search;
  int _offset = 0;
  int _limit = 19;
  int _notificacao;

  final _pesquisa_controller = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == "" || _search == null){
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=mqluIqpGZH41X0F4dJbEolEVzkj1Shhi&limit=$_limit&offset=$_offset&rating=g&lang=en"));
    }else{
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=mqluIqpGZH41X0F4dJbEolEVzkj1Shhi&q=$_search&limit=$_limit&offset=$_offset&rating=g&lang=en"));
    }

    return json.decode(response.body);
  }

  void _Pesquisar(text){
    setState(() {
      text = _pesquisa_controller.text;
      if(text.isEmpty || text == null){
        _search = null;
      }else {
        _search = text;
        _offset = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()
            ),
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
            controller: _pesquisa_controller,
            onChanged: _Pesquisar,
          ),
          ),
          Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3.0,
                        ),
                      );
                    default:
                      if(snapshot.hasError) {
                        return Container();
                      }else{
                        return _createGiftTable(context, snapshot);
                      }
                  }
                },
              )
          )
        ],
      ),
    );
  }

  int _getcount(List data){
    if(_notificacao == null){
      return data.length + 1;
    }
      return data.length + 2;
  }

  Widget _createGiftTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0
        ),
        itemCount: _getcount(snapshot.data["data"]),
        itemBuilder: (context, index){
          if(index < snapshot.data["data"].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Gif_Page(snapshot.data["data"][index])));
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          }else if(index == 20){
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.subdirectory_arrow_left, color: Colors.white, size: 70.0),
                    Text("Anterior...", style: TextStyle(color: Colors.white, fontSize: 20.0),)
                  ],
                ),
                onTap: (){ // Click do Button
                  setState(() {
                    if(_offset > 20) {
                      _offset -= 20;
                    }else{
                      _limit = 19;
                      _offset=0;
                      _notificacao=null;
                    }
                  });
                },
              ),
            );
          }else{
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text("Carregar mais...", style: TextStyle(color: Colors.white, fontSize: 20.0),)
                  ],
                ),
                onTap: (){ // Click do Button
                  setState(() {
                    _offset += 20;
                    _limit = 20;
                    _notificacao=1;
                  });
                },
              ),
            );
          }
        }
    );
  }
}
