import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mysample/model/placement_detail.dart';
import 'api/api_controller.dart';
import 'api/api_manger.dart';
import 'api/api_response.dart';
import 'http.dart'; // make dio as global top-level variable

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = "";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Page"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          FlatButton(
            child: const Text("Request"),
            onPressed: () {
              APIController.request<APIResponse<PlacementDetail>>(
                  apiType: APIType.placementDetail,
                  extraPath: "/2122",
                  createFrom: () => APIResponse<PlacementDetail>(data: PlacementDetail())).then((value) {
                setState(() {
                  _text = value.data.toJson().toString();
                });
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(_text),
            ),
          )
        ]),
      ),
    );
  }
}

