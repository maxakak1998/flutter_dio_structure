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

  _buildButton(String title, Function callback) {
    title ??= "";
    return FlatButton(
      color: Colors.amber,
      child: Text(title),
      onPressed: () {
        if (callback != null) callback();
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Page"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildButton("Request with primitive type", () {
            APIController.request<String>(apiType: APIType.testPost)
                .then((value) {
              setState(() {
                _text = value;
              });
            });
          }),
          _buildButton("Request with primitive type wrapped by APIResponse",
              () {
            APIController.request<APIResponse<String>>(
                apiType: APIType.testPost,
                createFrom: (response) => APIResponse(response: response)).then((value) {
              setState(() {
                _text = value.data;
              });
            });
          }),
          _buildButton("Request GET with class implementing BaseAPIWrapper",
              () {
            APIController.request<APIResponse<PlacementDetail>>(
                    apiType: APIType.placementDetail,
                    extraPath: "/2122",
                    createFrom: (response) => APIResponse(data: PlacementDetail(),response: response))
                .then((value) {
              setState(() {
                _text = value.response.data.toString();
              });
            });
          }),
          _buildButton(
              "Request GET with class implementing BaseAPIWrapper and convert the response to the list",
              () {
            APIController.request<APIListResponse<Owner>>(
                apiType: APIType.allOwners,
                createFrom: (response) =>
                    APIListResponse(createBy: Owner(),response: response)).then((value) {
              setState(() {
                _text = value.data.toString();
              });
            });
          }),
          _buildButton(
              "Request GET with class implementing BaseAPIWrapper in fail case ",
              () {
            APIController.request<APIResponse<PlacementDetail>>(
                    apiType: APIType.placementDetail,
                    extraPath: "/22122",
                    createFrom: (response) => APIResponse(data: PlacementDetail()))
                .then((value) {
              setState(() {
                _text = value.data.toJson().toString();
              });
            }).catchError((e) {
              _text = e.data.toString();
              setState(() {});
            });
          }),
          _buildButton("Request POST", () {
            APIController.request<String>(
                apiType: APIType.testPost,
                body: {"my message": "hello"}).then((value) {
              setState(() {
                _text = value;
              });
            });
          }),
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
