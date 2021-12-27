// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gifs/ui/gif_page.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  // ignore: prefer_final_fields
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search == '') {
      response = await http.get(
        Uri.parse(
            'https://api.giphy.com/v1/gifs/trending?api_key=MQS1RU7BQInjezsr98wkykvX3h8fxsaV&limit=30&rating=g'),
      );
    } else {
      response = await http.get(
        Uri.parse(
            'https://api.giphy.com/v1/gifs/search?api_key=MQS1RU7BQInjezsr98wkykvX3h8fxsaV&q=$_search&limit=29&offset=$_offset&rating=g&lang=en'),
      );
    }

    // Analisa a string e retorna o objeto Json resultante.
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                  _getGifs();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    // ignore: sized_box_for_whitespace
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: const Text(
                          'Algo de errado aconteceu, tente novamente mais tarde',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      );
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data['data']),
      // A cada vez que eu for colocar um gif na tela, ele chama essa função
      itemBuilder: (context, index) {
        if (_search == null ||
            _search == '' ||
            index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
                height: 300,
                fit: BoxFit.cover,
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']
                    ['url']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_box, color: Colors.white, size: 70),
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 29;
              });
            },
          );
        }
      },
    );
  }
}
